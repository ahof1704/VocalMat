if ispc()
  exp_dir_name='//dm11/egnorlab/Neunuebel/ssl_vocal_structure/08212012';
else
  exp_dir_name='/groups/egnor/egnorlab/Neunuebel/ssl_vocal_structure/08212012';
end
letter_str='B';
data_analysis_dir_name='Data_analysis10';
%session_base_name=sprintf('Test_%s_1',letter_str);
fs=450450;  % Hz, happen to know this a priori
%fs_video=29;  % Hz, ditto
start_pad_duration_want=0.010;  % s
end_pad_duration_want=0.010;  % s
% clr_mike=[1 0 0 ; ...
%           0 0.7 0 ; ...
%           0 0 1 ; ...
%           0 0.8 0.8 ];
%associated_video_frame_method = 'close'; %options are begin or close

% figure out the name of the stupid ax output file
demuxed_data_dir_name = fullfile(exp_dir_name,'demux');
ax_output_parent_dir_name=fullfile(demuxed_data_dir_name,'no_merge_only_har');
ax_output_dir_name_pattern = sprintf('*_%s_*',letter_str);
ax_output_parent_dir_listing_struct = dir(fullfile(ax_output_parent_dir_name,ax_output_dir_name_pattern));
ax_output_dir_name=ax_output_parent_dir_listing_struct.name;
ax_output_mat_file_name = sprintf('Test_%s_1_voc_list_no_mer_har.mat',letter_str);
ax_output_mat_file_name_abs=fullfile(ax_output_parent_dir_name,ax_output_dir_name,ax_output_mat_file_name)

% % read the video frame pulse data
% yn_load_time_stamps = 'y';
% video_pulse_start_ts = ...
%   fn_video_pulse_start_ts(demuxed_data_dir_name, ...
%                           exp_dir_name, ...
%                           session_base_name, ...
%                           session_base_name, ...
%                           yn_load_time_stamps, ...
%                           fs, ...
%                           fs_video);

% load the raw ax output
mouse_from_ax=load_ax_segments(ax_output_mat_file_name_abs);
%mouse_from_ax=load_ax_segments_and_append_frame_number(file_name,video_pulse_start_ts,associated_video_frame_method);

% extract the voc we want
example_segment_name='Voc3508';
is_example_segment=strcmp(example_segment_name,{mouse_from_ax.syl_name});
mouse_from_ax_example_segment=mouse_from_ax(is_example_segment)

% work out the segment start indices, with padding
i_segment_start=mouse_from_ax_example_segment.start_sample_fine
i_segment_end=mouse_from_ax_example_segment.stop_sample_fine
f_lo_segment=mouse_from_ax_example_segment.lf_fine
f_hi_segment=mouse_from_ax_example_segment.hf_fine
%i_segment_start=10547488;  % Voc130 from ax, voc51 after snippetization
%i_segment_end=10558880;  % these are both matlab-style indices
dt=1/fs;  % s
samples_in_start_pad=ceil(start_pad_duration_want/dt);
samples_in_end_pad=ceil(end_pad_duration_want/dt);
i_start=i_segment_start-samples_in_start_pad; 
i_end=i_segment_end+samples_in_end_pad;

[v,t] = ...
  read_voc_audio_trace( exp_dir_name, letter_str, ...
                        i_start,i_end);
[N,n_mics]=size(v);                      

% returned t starts at zero, want zero to be segment start
t=t-dt*samples_in_start_pad;

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
  plot(1000*t,1000*v(:,i_mic)     ,'color','k');
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
tl(1000*t(1),1000*t(end));

% add brackets to show the actual segment
t_segment_start_relative=0;
t_segment_end_relative=(i_segment_end-i_segment_start)*dt;
drawnow;
for i_mic=1:n_mics
  subplot_handle=subplot_handles(i_mic);
  yl=get(subplot_handle,'ylim');
  line('parent',subplot_handle, ...
       'xdata',1000*t_segment_start_relative*[1 1], ...
       'ydata',yl, ...
       'color','k');
  line('parent',subplot_handle, ...
       'xdata',1000*t_segment_end_relative*[1 1], ...
       'ydata',yl, ...
       'color','k');
end
set(figure_handle,'name','traces');

% % write to a .tcs file
% name=cell(n_mics,1);
% units=cell(n_mics,1);
% for i_mic=1:n_mics
%   name{i_mic}=sprintf('Mic %d',i_mic);
%   units{i_mic}='mV';
% end
% write_tcs_common_timeline('example_voc.tcs',name,t,1000*v,units);










% % played around in Groundswell, found good Spectrogram params
% T_window_want=0.002;  % s 
% dt_window_want=T_window_want/10;
% NW=2;
% K=3;
% f_max_keep=100e3;  % Hz
% p_FFT_extra=2;
% 
% % calc spectrogram
% for i_mic=1:n_mics
%   [f_S,t_S,~,S_this,~,~,N_fft,W_smear_fw]=...
%     powgram_mt(dt,v(:,i_mic),...
%                T_window_want,dt_window_want,...
%                NW,K,f_max_keep,...
%                p_FFT_extra);  
%   if i_mic==1 , 
%     S=zeros(length(f_S),length(t_S),n_mics);
%   end
%   S(:,:,i_mic)=S_this;  % V^2/Hz
% end
% N_fft  %#ok
% W_smear_fw  %#ok
% t_S=t_S+t(1);  % powgram_mt only knows dt, so have to do this           
% S_log=log(S);  % Spectrogram expects this
% %var_est=std(data_short_cent)^2;
% 
% % set up the figure and place all the axes                                   
% w_fig=2.5; % in
% h_fig=3; % in
% n_row=n_mics;
% n_col=1;
% w_axes=1.5;  % in
% h_axes=0.5;  % in
% w_space=1;  % in (not used)
% h_space=0;  % in                              
% [figure_handle,subplot_handles]= ...
%   layout_axes_grid(w_fig,h_fig,...
%                    n_row,n_col,...
%                    w_axes,h_axes,...
%                    w_space,h_space);
% set(figure_handle,'color','w');                               
% 
% % plot the spectrograms
% S_max=max(max(max(S)))  %#ok
% title_str='';
% for i_mic=1:n_mics ,
%   subplot_handle=subplot_handles(i_mic);
%   axes(subplot_handle);  %#ok
%   plot_powgram(1000*t_S,f_S,1e9*S(:,:,i_mic),...
%                [],[50000 f_max_keep],[],...
%                'amplitude',[0 80],...
%                title_str);  % convert to mV^2/kHz
%   set(subplot_handle,'fontsize',7);
%   %ylim(ylim_tight(1000*v(:,i_mic)));
%   %ylabel(sprintf('Mic %d',i_mic),'fontsize',7);
%   set(subplot_handle,'yAxisLocation','right');
%   set(subplot_handle,'yticklabel',{});
%   ylabel(subplot_handle,'');
%   if i_mic~=n_mics ,
%     set(subplot_handle,'xticklabel',{});
%   else
%     colorbar_handle=add_colorbar(subplot_handle,0.1,0.075);
%     set(colorbar_handle,'fontsize',7);
%     ylabel(colorbar_handle,'Amp density (mV/kHz^{0.5})');
%     set(colorbar_handle,'ytick',[0 80]);
%   end
% end
% colormap(subplot_handle,flipud(gray(256)));
% xlabel(subplot_handle,'Time (ms)','fontsize',7);
% %ylim_all_same();
% %tl(1000*t(1),1000*t(end));
% 
% % load the snippets determined by Josh's code
% snippet_file_name=fullfile(exp_dir_name, ...
%                            data_analysis_dir_name, ...
%                            sprintf('Test_%s_1_Mouse.mat',letter_str));
% snippet_file_contents=load(snippet_file_name);
% snippets=snippet_file_contents.mouse;
% i_example_segment=51;  % 
% is_example_segment= ([snippets.index]==i_example_segment) ;
% example_snippets=snippets(is_example_segment);
% 
% % draw a rect showing the ax segment bound
% i_mic_to_show_snippets_on=4;
% t_segment_start=dt*(i_segment_start-1);
% t_segment_end=dt*(i_segment_end-1);
% t_segment_end_rel=t_segment_end-t_segment_start;
% line('parent',subplot_handles(i_mic_to_show_snippets_on), ...
%      'xdata',1000*[0 t_segment_end_rel t_segment_end_rel 0 0], ...
%      'ydata',[f_lo_segment f_lo_segment f_hi_segment f_hi_segment f_lo_segment], ...
%      'linewidth',0.25, ...
%      'color',[0 0.7 0]);
% 
% % get info about outliers by running more_panels_for_methods_figure_1.m
% indices_of_outliers=[7 10 11 12]';
% n_example_snippets=length(example_snippets);
% is_outlier=false(n_example_snippets);
% is_outlier(indices_of_outliers)=true;
% 
% % draw rectangles for each snippet on all the spectrograms
% for i_example_snippet=1:n_example_snippets
%   this_snippet=example_snippets(i_example_snippet);
%   t_lo=dt*(this_snippet.start_sample_fine-1);  %s
%   t_hi=dt*(this_snippet.stop_sample_fine-1);  %s
%   t_lo_rel=t_lo-t_segment_start;  %s
%   t_hi_rel=t_hi-t_segment_start;  %s
%   f_lo=this_snippet.lf_fine;
%   f_hi=this_snippet.hf_fine;
%   if is_outlier(i_example_snippet)
%     clr=[0.7 0 0];
%     z=3;
%   else
%     clr=[0 0 0.7];
%     z=2;
%   end
%   for i_mic=i_mic_to_show_snippets_on ,
%     line('parent',subplot_handles(i_mic), ...
%          'xdata',1000*[t_lo_rel t_hi_rel t_hi_rel t_lo_rel t_lo_rel], ...
%          'ydata',[f_lo f_lo f_hi f_hi f_lo], ...
%          'zdata',z*[1 1 1 1 1], ...
%          'linewidth',0.25, ...
%          'color',clr);
%   end
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
                                
%f_plot_low=mouse_from_ax_example_segment.lf_fine-2000;  % Hz
%f_plot_high=mouse_from_ax_example_segment.hf_fine+2000;  % Hz
f_plot_low=[];  % Hz
f_plot_high=[];  % Hz
%S_db_plot_low=+5-90;  % "10*log10 V^2/Hz"
%S_db_plot_high=+20-90;  % "10*log10 V^2/Hz"
S_db_plot_low=[];  % "10*log10 V^2/Hz"
S_db_plot_high=[];  % "10*log10 V^2/Hz"
[figure_handle,subplot_handles]= ...
  fig_spectrogram_ssl_dB(exp_dir_name, ...
                         letter_str, ...
                         fs, ...
                         i_start, ...
                         i_end, ...
                         f_plot_low, ...
                         f_plot_high, ...
                         S_db_plot_low, ...
                         S_db_plot_high, ...
                         i_segment_start);
drawnow;

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
       

% load the snippets determined by Josh's code
snippet_file_name=fullfile(exp_dir_name, ...
                           data_analysis_dir_name, ...
                           sprintf('Test_%s_1_Mouse.mat',letter_str));
snippet_file_contents=load(snippet_file_name);
snippets=snippet_file_contents.mouse;
i_example_segment=3091;  % 
is_example_segment= ([snippets.index]==i_example_segment) ;
example_snippets=snippets(is_example_segment);

% draw a rect showing the ax segment bound
i_mic_to_show_snippets_on=4;
t_segment_start=dt*(i_segment_start-1);
t_segment_end=dt*(i_segment_end-1);
t_segment_end_rel=t_segment_end-t_segment_start;
line('parent',subplot_handles(i_mic_to_show_snippets_on), ...
     'xdata',1000*[0 t_segment_end_rel t_segment_end_rel 0 0], ...
     'ydata',1e-3*[f_lo_segment f_lo_segment f_hi_segment f_hi_segment f_lo_segment], ...
     'linewidth',0.25, ...
     'color',[0 0.7 0]);

% get info about outliers by running more_panels_for_methods_figure_1.m
indices_of_outliers=[]';
n_example_snippets=length(example_snippets);
is_outlier=false(n_example_snippets);
is_outlier(indices_of_outliers)=true;

% draw rectangles for each snippet on all the spectrograms
i_snippet_pretty=nan;
for i_example_snippet=1:n_example_snippets
  this_snippet=example_snippets(i_example_snippet);
  t_lo=dt*(this_snippet.start_sample_fine-1);  %s
  t_hi=dt*(this_snippet.stop_sample_fine-1);  %s
  t_lo_rel=t_lo-t_segment_start;  %s
  t_hi_rel=t_hi-t_segment_start;  %s
  f_lo=this_snippet.lf_fine;
  f_hi=this_snippet.hf_fine;
  if is_outlier(i_example_snippet)
    clr=[0.7 0 0];
    z=3;
  elseif i_example_snippet==i_snippet_pretty ,
    clr=[0.7 0 0.7];
    z=4;    
  else
    clr=[0 0 0.7];
    z=2;
  end
  for i_mic=i_mic_to_show_snippets_on ,
    line('parent',subplot_handles(i_mic), ...
         'xdata',1000*[t_lo_rel t_hi_rel t_hi_rel t_lo_rel t_lo_rel], ...
         'ydata',1e-3*[f_lo f_lo f_hi f_hi f_lo], ...
         'zdata',z*[1 1 1 1 1], ...
         'linewidth',0.25, ...
         'color',clr);
  end
end

set(figure_handle,'name','spectrograms');

                                      