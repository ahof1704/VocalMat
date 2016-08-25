% load the data
load('stefan_data.mat');
  % introduces t, roi, roi_label into namespace
  % t: 2500x1, in s
  % roi: 2500x4, four signals, pure, fractional change in fluorescence
  % roi_label: 4x1, a cell array of strings, label for each signal 

% get dims, etc
n_t=length(t);
dt=(t(end)-t(1))/(n_t-1);
n_roi=size(roi,2);

% extract the ref signal at optical time scale
i_ref=1;
ref=roi(:,1);
ref_label=roi_label{i_ref};

% plot the roi signals, and the ref signal
title_str='Data!';
figure;
set_figure_size([6.75 3.28]);
%set_figure_size([13 9]);
n_plot=n_roi;
for i=1:n_roi
  subplot(n_plot,1,i);
  set_axes_size_fixed_center([1 1.35].*get_axes_size());
  line(t,100*roi(:,i),'color','k');
  ylabel(sprintf('%s (%%)',roi_label{i}));
  ylim(ylim_tight(100*roi(:,i)));
  if i<n_roi
    set(gca,'xticklabel',{});
    set(gca,'xcolor','w');
  end  
  if i==1
    title(title_str,'interpreter','none');
  end
end
xlabel('Time (s)');
tl(t(1),t(end));

% center the signals
ref_cent=ref-mean(ref);
roi_cent=roi-repmat(mean(roi,1),[n_t 1]);

% z-score the signals
ref_z=ref_cent./std(ref);
roi_z=roi_cent./repmat(std(roi,[],1),[n_t 1]);

%
% calc spectrograms
%

% pick NW, K, etc
NW=3;
K=2*NW-1;
f_max_keep=2;  % Hz, max freq to keep in spectra
T_window_want=50;  % s
dt_window_want=5;  % s

% estimate the spectrograms
[f_ref,t_win_ref,ref_z_win_mean,P_ref]=...
  powgram_mt(dt,ref_z,T_window_want,dt_window_want,...
             NW,K,f_max_keep);
n_f=length(f_ref);
n_t_win=length(t_win_ref);
P_roi=nan(n_f,n_t_win,n_roi);
for j=1:n_roi
  roi_z_this=roi_z(:,j);
  [f_roi,t_win_roi,~,P_roi(:,:,j)]=...
    powgram_mt(dt,roi_z_this,...
               T_window_want,dt_window_want,...
               NW,K,f_max_keep);
end

% plot the spectrograms
f_max_plot=0.4;  % Hz
% figure_spectrogram_amp(t_win_ref,f_ref,A_ref,...
%                        [t_win_ref(1  )-T_window_want/2 ...
%                         t_win_ref(end)+T_window_want/2],...
%                        [0 f_max_plot],...
%                        [0 4],... 
%                        ref_label,...
%                        '1');
% set_figure_size([5.1 2.16]);                     
for j=1:n_roi
  figure_powgram(t_win_roi,f_roi,P_roi(:,:,j),...
                 [t_win_roi(1  )-T_window_want/2 ...
                  t_win_roi(end)+T_window_want/2],...
                 [0 f_max_plot],...
                 [],...
                 'amplitude',[0 4],...
                 roi_label{j},...
                 '1');
  set_figure_size([5.1 2.16]);                                          
end

%
% calc cohereograms
%

% estimate the cohereograms
for j=1:n_roi
  [f_roi,t_win_roi,C_mag_this,C_phase_this]=...
    cohgram_mt(dt,ref_z,roi_z(:,j),...
               T_window_want,dt_window_want,...
               NW,K,f_max_keep);
  if j==1
    n_f=length(f_roi);
    n_t_win=length(t_win_roi);
    C_mag_roi=nan(n_f,n_t_win,n_roi);
    C_phase_roi=nan(n_f,n_t_win,n_roi);
  end
  C_mag_roi(:,:,j)=C_mag_this;
  C_phase_roi(:,:,j)=C_phase_this;
end

% calc the coherence magnitude threshold
alpha_threshold=0.05;
C_mag_thresh=coh_mt_control_analytical(1,K,alpha_threshold);

% plot the cohereograms
f_max_plot=0.4;  % Hz
for j=1:n_roi
  figure_cohgram(t_win_roi,f_roi,...
                 C_mag_roi(:,:,j),C_phase_roi(:,:,j),...
                 [t_win_roi(1  )-T_window_want/2 ...
                  t_win_roi(end)+T_window_want/2],...
                 [0 f_max_plot],...
                 roi_label{j},...
                 C_mag_thresh);
  set_figure_size([5.1 2.16]);
end

% plot the full cohereogram colorscale
figure;
set_figure_size([3 3]);
plot_coh2l75_border_legend(C_mag_thresh);
