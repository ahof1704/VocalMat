function figure_handle=fig_spectrogram_ssl_power(exp_dir_name, ...
                                                 letter_str, ...
                                                 fs, ...
                                                 i_start, ...
                                                 i_end, ...
                                                 f_plot_low, ...
                                                 f_plot_high, ...
                                                 S_plot_high)
% fs in Hz
                                         
% process args
if ~exist('f_plot_low','var') || isempty(f_plot_low) ,
  f_plot_low=0;  % Hz
end
if ~exist('f_plot_high','var') ,
  f_plot_high=[];  % Hz
end
if ~exist('S_plot_high','var') ,
  S_plot_high=[];  % V^2/Hz
end

% These are good spectrogram parameters
T_window_want=0.002;  % s 
dt_window_want=T_window_want/10;
NW=2;
K=3;
f_max_keep=100e3;  % Hz
p_FFT_extra=2;

% Sanity-check f_plot_high
if isempty(f_plot_high) || f_plot_high>f_max_keep ,
  f_plot_high=f_max_keep;
end

% read the data from disk                                         
[v,t] = ...
  read_voc_audio_trace(exp_dir_name,letter_str, ...
                       i_start,i_end);
[N,n_mics]=size(v);  %#ok

% calc spectrograms
dt=1/fs;  % s
for i_mic=1:n_mics
  [f_S,t_S,~,S_this,~,~,N_fft,W_smear_fw]=...
    powgram_mt(dt,v(:,i_mic),...
               T_window_want,dt_window_want,...
               NW,K,f_max_keep,...
               p_FFT_extra);  
  if i_mic==1 , 
    S=zeros(length(f_S),length(t_S),n_mics);
  end
  S(:,:,i_mic)=S_this;  % V^2/Hz
end
N_fft  %#ok
W_smear_fw  %#ok
t_S=t_S+t(1);  % powgram_mt only knows dt, so have to do this           
%S_log=log(S);  % Spectrogram expects this
%var_est=std(data_short_cent)^2;

% set up the figure and place all the axes                                   
w_fig=3; % in
h_fig=3.5; % in
n_row=n_mics;
n_col=1;
w_axes=1.5;  % in
h_axes=0.5;  % in
w_space=1;  % in (not used)
h_space=0;  % in                              
[figure_handle,subplot_handles]= ...
  layout_axes_grid(w_fig,h_fig,...
                   n_row,n_col,...
                   w_axes,h_axes,...
                   w_space,h_space);
set(figure_handle,'color','w');                               

% figure out the plot max
S_max=max(max(max(S)))  %#ok
%A_max=sqrt(S_max);
if isempty(S_plot_high) ,
  S_plot_high=S_max;
end

% plot the spectrograms
title_str='';
for i_mic=1:n_mics ,
  subplot_handle=subplot_handles(i_mic);
  axes(subplot_handle);  %#ok
  plot_powgram(1000*t_S,1e-3*f_S,1e9*S(:,:,i_mic),...
               [],1e-3*[f_plot_low f_plot_high],[],...
               'power', ...
               [0 1e9*S_plot_high],...
               title_str);  % convert to mV^2/kHz
  set(subplot_handle,'fontsize',7);
  %ylim(ylim_tight(1000*v(:,i_mic)));
  %ylabel(sprintf('Mic %d',i_mic),'fontsize',7);
  %set(subplot_handle,'yAxisLocation','right');
  ylabel(subplot_handle,'');
  set(subplot_handle,'ytick',1e-3*[f_plot_low f_plot_high]);
  if i_mic~=n_mics ,
    set(subplot_handle,'xticklabel',{});
    set(subplot_handle,'yticklabel',{});
  else
    ylabel(subplot_handle,'Frequency (kHz)');
    colorbar_handle=add_colorbar(subplot_handle,0.1,0.075);
    set(colorbar_handle,'fontsize',7);
    ylabel(colorbar_handle,'Power density (mV^2/kHz)');
    set(colorbar_handle,'ytick',[0 1e9*S_plot_high]);
  end
end
colormap(subplot_handle,flipud(gray(256)));
xlabel(subplot_handle,'Time (ms)','fontsize',7);
%ylim_all_same();
%tl(1000*t(1),1000*t(end));

end
