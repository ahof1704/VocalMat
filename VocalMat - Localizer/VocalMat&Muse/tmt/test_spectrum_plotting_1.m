% set some params
NW=6;  % time-bandwidth product (higher is smoother)
f_max_keep=1;  % Hz, max freq to keep in spectra
conf_level=0.68;  % P val for confidence intervals, approx 1 sigma
f_star=0.13; % Hz, main frequency of interest
alpha_threshold=0.05;  % single comparison type 1 error rate for coh mag

% load the data
load('stefan_data.mat');
  % introduces t, roi, roi_label into namespace
  % t: 2500x1, in s
  % roi: 2500x4, four signals, pure, fractional change in fluorescence
  % roi_label: 4x1, a cell array of strings, label for each signal 

% trim to a subrange
t0=0;  % s
tf=135;  % s
keep=(t0<=t)&(t<tf);
t=t(keep);
roi=roi(keep,:);
clear keep;

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
set_figure_size([13 9]);
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
% subplot(n_plot,1,n_plot);
% set_axes_size_fixed_center([1 1.35].*get_axes_size());
% % line(t,ref,'color','k');
% % ylim(ylim_tight(ref));
% line(t_e,e_phys(:,strcmp('nerve',e_phys_name)),'color','k');
% ylim(ylim_tight(e_phys(:,strcmp('nerve',e_phys_name))));
% ylabel('ref (V)');
xlabel('Time (s)');
% tl(t(1),t(end));

% calc f resolution
T=dt*n_t  % s
f_res_diam=2*NW/T

% center things
ref_cent=ref-mean(ref);
roi_cent=roi-repmat(mean(roi,1),[n_t 1]);

% estimate the spectra
[f_ref,P_ref,N_fft,f_res_diam,K]=...
  pow_mt(dt,ref_cent,NW,[],f_max_keep);
n_f=length(P_ref);
P_roi=nan(n_f,n_roi);
for j=1:n_roi
  roi_cent_this=roi_cent(:,j);
  [f_roi,P_roi(:,j)]=...
    pow_mt(dt,roi_cent_this,NW,[],f_max_keep);
end

% estimate the coherence
C_mag=nan(n_f,n_roi);
C_phase=nan(n_f,n_roi);
C_mag_ci=nan(n_f,n_roi,2);
C_phase_ci=nan(n_f,n_roi,2);
for j=1:n_roi
  [f,C_mag(:,j),C_phase(:,j),dummy,dummy,K,...
   C_mag_ci_this,C_phase_ci_this]=...
    coh_mt(dt,ref,roi(:,j),NW,[],f_max_keep,[],...
           conf_level);
  C_mag_ci(:,j,:)=C_mag_ci_this;
  C_phase_ci(:,j,:)=C_phase_ci_this;
end

% calc the coherence magnitude threshold
C_mag_thresh=coh_mt_control_analytical(1,K,alpha_threshold);

% extract the coherence and CIs for f=f_star
C_mag_star=interp1(f,C_mag,f_star,'*linear');
C_phase_star=interp1(f,C_phase,f_star,'*linear');
C_mag_ci_star=interp1(f,C_mag_ci,f_star,'*linear');
C_phase_ci_star=interp1(f,C_phase_ci,f_star,'*linear');

% reshape for convenience
C_mag_star=reshape(C_mag_star,[n_roi 1]);
C_phase_star=reshape(C_phase_star,[n_roi 1]);
C_mag_ci_star=reshape(C_mag_ci_star,[n_roi 2]);
C_phase_ci_star=reshape(C_phase_ci_star,[n_roi 2]);

% do the polar plot of coherence at f_star
% figure_coh_polar(C_mag_star,C_phase_star,...
%                  C_mag_ci_star,C_phase_ci_star,...
%                  1:n_roi,roi_label,...
%                  0,C_mag_thresh,...
%                  1,...
%                  'l75_border_of_r_theta',[0 0 0]);    

%            
% plot the spectra
%

% figure out how many total plots there will be
n_plots=n_roi;

% generate the plots
% setup
f_min=0;
f_max=f_roi(end);
plot_index=1;

% actually plot them
max_plots_per_page=5;
for j=1:n_roi
  P_roi_this=P_roi(:,j);
  plot_index_this_page=mod(plot_index-1,max_plots_per_page)+1;
  if plot_index_this_page==1
    if n_plots-plot_index+1>max_plots_per_page
      n_plots_this_page=max_plots_per_page;
    else
      n_plots_this_page=n_plots-plot_index+1;
    end
    fig_height=8.5/max_plots_per_page*n_plots_this_page;
    figure;
    set_figure_size([6.5 fig_height]);
    %set(gcf,'PaperPosition',[1 1.25 6.5 fig_height]);
  end
  subplot(n_plots_this_page,1,plot_index_this_page);
  % this is where the actually plotting happens  
  hs=plot(f_ref,100*sqrt(P_ref/sum(P_ref)*sum(P_roi_this)),...
          f_roi,100*sqrt(P_roi_this));
  set(hs(1),'Color',[0.75 0.75 0.75]);
  set(hs(2),'Color',[0 0 0]);    
  % this is where the plotting ends
  if plot_index_this_page==1
    title(title_str);
  end
  if plot_index_this_page==n_plots_this_page
    xlabel('Frequency (Hz)');
  else
    set(gca,'XTickLabel',{});
  end
  xlim([f_min f_max]);
  ylim(100*sqrt([min(P_roi_this) max(P_roi_this)]));
  %set(gca,'YScale','log');
  ylabel(sprintf('%s (%%/Hz^{0.5})',roi_label{j}));
  plot_index=plot_index+1;
end

%
% plot the coherence
%

% setup
f_min=0;
f_max=f(end);  

% ROI coherences
for j=1:n_roi
  figure;

  subplot(2,1,1);
  patch_eb(f,...
           C_mag_ci(:,j,:),...
           [0.75 0.75 0.75],...
           'EdgeColor','none');
  line(f,C_mag(:,j),zeros(size(f)),'Color',[0 0 0]);
  xlim([f_min f_max]);
  ylim([0 1.1]);
  set(gca,'Layer','Top');
  set(gca,'Box','on');
  set(gca,'XTickLabel',[]);
  ylabel('Mag');
  title(sprintf('ROI %s Coherence',roi_label{j}));

  subplot(2,1,2);
  patch_eb_wrap(f,...
                180/pi*C_phase(:,j),...
                180/pi*reshape(C_phase_ci(:,j,:),[n_f 2]),...
                [-180 +180],...
                0.75*[1 1 1]);
  line_wrap(f,180/pi*C_phase(:,j),...
            [-180 +180],...
            'Color',[0 0 0]);
  xlim([f_min f_max]);
  ylim([-180 +180]);
  set(gca,'Layer','Top');
  set(gca,'Box','on');
  set(gca,'YTick',[-180 -90 0 +90 +180]);
  ylabel('Phase');
  xlabel('Freq (Hz)');    
end


