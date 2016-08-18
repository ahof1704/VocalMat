function [figure_handle,subplot_handles]= ...
  fig_spectrogram_ssl_dB(exp_dir_name, ...
                         letter_str, ...
                         fs, ...
                         i_start, ...
                         i_end, ...
                         f_plot_low, ...
                         f_plot_high, ...
                         S_dB_plot_low, ...
                         S_dB_plot_high, ...
                         i_origin)

% A function to plot a spectrogram of SSL data.
%
% exp_dir_name is a string giving the name of the directory holding the
% 'demuxed' audio data.  The files read have names of the form
% <exp_dir_name>/demux/Test_<letter_str>.ch<channel index>
%
% letter_str is a single-character string, used to determine the files to
% read (see above).
%
% fs is the sampling rate of the audio data, in Hz.
%
% i_start is the index of the first audio sample returned (the first sample
% in the file is index 1).
%
% i_end is the index of the last audio sample returned.
%
% f_plot_low is the lowest frequency to plot in the spectrogram, in Hz.  It
% is optional, and can be left empty, in which case the default of 0 Hz is
% used.
%
% f_plot_high is the highest frequency to plot in the spectrogram, in Hz.  It
% is optional, and can be left empty, in which case the default of 100,000 Hz is
% used.
%
% S_dB_plot_low is the lowest power density to plot in the spectrogram, in
% "10*log10(V^2/Hz)".  That is, if you want the color scale to bottom out
% at 1000 V^2/Hz, this should be 10*log10(1000)==30.  It is optional, and
% can be left empty, in which case the lowest power density in the
% spectrogram is used.
%
% S_dB_plot_high is the highest power density to plot in the spectrogram, in
% "10*log10(V^2/Hz)".  (See above.)  It is optional, and
% can be left empty, in which case the highest power density in the
% spectrogram is used.
%
% i_origin is the sample index to be used as the time origin in the
% spectrogram figure.  It is optional, and can be empty, in which case it
% defaults to i_start.
%
%
% On return:
%
% figure_handle is the handle of the spectrogram figure.
%
% subplot_handles is a column vector of axes handles, one per channel in
% the data.


% process args
if ~exist('f_plot_low','var') || isempty(f_plot_low) ,
  f_plot_low=0;  % Hz
end
if ~exist('f_plot_high','var') ,
  f_plot_high=[];  % Hz
end
if ~exist('S_dB_plot_low','var') ,
  S_dB_plot_low=[];  % "10*log10 V^2/Hz"
end
if ~exist('S_dB_plot_high','var') ,
  S_dB_plot_high=[];  % "10*log10 V^2/Hz"
end
if ~exist('i_origin','var') || isempty(i_origin) ,
  i_origin=i_start;
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
%t_S=t_S+t(1);  % powgram_mt only knows dt, so have to do this
t_S=t_S-dt*(i_origin-i_start);  % shift the time base, if requested
%S_log=log(S);  % Spectrogram expects this
%var_est=std(data_short_cent)^2;

% set up the figure and place all the axes                                   
w_fig=3.5; % in
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

% figure out the plot min/max
S_dB=10*log10(S);
%S_dB_max=max(max(max(S_dB)));
%S_dB_min=min(min(min(S_dB)));

S_dB_max=quantile(S_dB(:),0.98);
S_dB_min=quantile(S_dB(:),0.02);

if isempty(S_dB_plot_high) ,
  S_dB_plot_high=S_dB_max;
end
if isempty(S_dB_plot_low) ,
  S_dB_plot_low=S_dB_min;
end

% plot the spectrograms
title_str='';
for i_mic=1:n_mics ,
  subplot_handle=subplot_handles(i_mic);
  axes(subplot_handle);  %#ok
  plot_powgram(1000*t_S,1e-3*f_S,1e9*S(:,:,i_mic),...
               [],1e-3*[f_plot_low f_plot_high],[],...
               'db', ...
               [90+S_dB_plot_low 90+S_dB_plot_high],...
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
    ylabel(subplot_handle,{'Frequency';'(kHz)'});
    colorbar_handle=add_colorbar(subplot_handle,0.1,0.075);
    set(colorbar_handle,'fontsize',7);
    ylabel(colorbar_handle,{'Power';'density';'(dB)'});
    set(colorbar_handle,'ytick',[90+S_dB_plot_low 90+S_dB_plot_high]);
  end
end
colormap(subplot_handle,flipud(gray(256)));
xlabel(subplot_handle,'Time (ms)','fontsize',7);
%ylim_all_same();
%tl(1000*t(1),1000*t(end));

end
