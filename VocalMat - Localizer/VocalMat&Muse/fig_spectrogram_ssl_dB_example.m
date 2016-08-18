exp_dir_name='E:\Ultrasounds_Tracks\2016_05_16_Pups_test(P9)\T03';
letter_str='';
clr_mike=zeros(4,3);

i_start=100000; 
i_end=300000;

[v,t] = ...
  read_voc_audio_trace( exp_dir_name, letter_str, ...
                        i_start,i_end);
[N,n_mics]=size(v);                      

% returned t starts at zero, want zero to be segment start
dt=(t(end)-t(1))/(length(t)-1);  % s

% set up the figure and place all the axes                                   
w_fig=2.5; % in
h_fig=3; % in
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

% plot the filtered clips with raw in background
white_fraction=0.75;
%figure_handle=figure('color','w');
%set_figure_size_explicit(figure_handle,[3 6]);
for i_mic=1:n_mics
  subplot_handle=subplot_handles(i_mic);
  axes(subplot_handle);  %#ok
  %plot(1000*t,1000*v(:,i_mic)     ,'color',(1-white_fraction)*clr_mike(i_mic,:)+white_fraction*[1 1 1]);
  plot(1000*t,1000*v(:,i_mic)     ,'color',clr_mike(i_mic,:));
  %hold on
  %plot(1000*t,1000*v_filt(:,i_mic),'color',clr_mike(i_mic,:));
  %hold off
  set(subplot_handle,'fontsize',7);
  ylim(ylim_tight(1000*v(:,i_mic)));
  %ylabel(sprintf('Mic %d',i_mic),'fontsize',7);
  if i_mic~=n_mics ,
    set(subplot_handle,'xticklabel',{});
    set(subplot_handle,'yticklabel',{});
  else
    set(subplot_handle,'yAxisLocation','right');
  end
end
xlabel('Time (ms)','fontsize',7);
ylim_all_same();
% tl(1000*t(1),1000*t(end));

% % add brackets to show the actual segment
% t_segment_start_relative=0;
% t_segment_end_relative=(i_segment_end-i_segment_start)*dt;
% drawnow;
% for i_mic=1:n_mics
%   subplot_handle=subplot_handles(i_mic);
%   yl=get(subplot_handle,'ylim');
%   line('parent',subplot_handle, ...
%        'xdata',1000*t_segment_start_relative*[1 1], ...
%        'ydata',yl, ...
%        'color','k');
%   line('parent',subplot_handle, ...
%        'xdata',1000*t_segment_end_relative*[1 1], ...
%        'ydata',yl, ...
%        'color','k');
% end






% % try this
% f_plot_low=50e3;  % Hz
% f_plot_high=[];  % Hz
% A_plot_high=sqrt(1e-9)*40;  % V/Hz^0.5
% figure_handle=fig_spectrogram_ssl(exp_dir_name, ...
%                                   letter_str, ...
%                                   fs, ...
%                                   i_start, ...
%                                   i_end, ...
%                                   f_plot_low, ...
%                                   f_plot_high, ...
%                                   A_plot_high);




%
% The actual call to fig_spectrogram_ssl_dB():
%
fs=1/dt;  % Hz
f_plot_low=50e3;  % Hz
f_plot_high=[];  % Hz
S_db_plot_low=+5-90;  % "10*log10 V^2/Hz"
S_db_plot_high=+20-90;  % "10*log10 V^2/Hz"
% S_db_plot_low=[];  % "10*log10 V^2/Hz"
% S_db_plot_high=[];  % "10*log10 V^2/Hz"
[figure_handle,subplot_handles]= ...
  fig_spectrogram_ssl_dB(exp_dir_name, ...
                         letter_str, ...
                         fs, ...
                         i_start, ...
                         i_end, ...
                         f_plot_low, ...
                         f_plot_high, ...
                         S_db_plot_low, ...
                         S_db_plot_high);

                       
                       
                       
                       
% f_plot_low=50e3;  % Hz
% f_plot_high=[];  % Hz
% S_plot_high=1e-9*80^2;  % V^2/Hz
% figure_handle=fig_spectrogram_ssl_power(exp_dir_name, ...
%                                         letter_str, ...
%                                         fs, ...
%                                         i_start, ...
%                                         i_end, ...
%                                         f_plot_low, ...
%                                         f_plot_high, ...
%                                         S_plot_high);
%                                    
       
