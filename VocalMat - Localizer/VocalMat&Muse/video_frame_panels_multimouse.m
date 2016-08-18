% identifying info for the segment, snippet
date_str='10082012';
letter_str='B';
base_dir_name='/groups/egnor/egnorlab/Neunuebel/ssl_vocal_structure';
data_analysis_dir_name='Data_analysis10';
fs=450450;  % Hz, happen to know this a priori
fs_video=29;  % Hz
associated_video_frame_method = 'close'; %options are begin or close
example_segment_id_string='Voc130';
%i_segment=51; 
i_snippet=16;  % index of the example snippet
%are_positions_on_disk_in_old_style_coords=true;  % uses Josh's coord convention from the pre-Motr days

%session_base_name=sprintf('Test_%s_1',letter_str);
%fs_video=29;  % Hz, ditto

% % figure out the name of the stupid ax output file
exp_dir_name=fullfile(base_dir_name, ...
                      sprintf('%s',date_str));
% demuxed_data_dir_name = fullfile(exp_dir_name,'demux');
% ax_output_parent_dir_name=fullfile(demuxed_data_dir_name,'no_merge_only_har');
% ax_output_dir_name_pattern = sprintf('*_%s_*',letter_str);
% ax_output_parent_dir_listing_struct = dir(fullfile(ax_output_parent_dir_name,ax_output_dir_name_pattern));
% ax_output_dir_name=ax_output_parent_dir_listing_struct.name;
% ax_output_mat_file_name = sprintf('Test_%s_1_voc_list_no_merge_har.mat',letter_str);
% ax_output_mat_file_name_abs=fullfile(ax_output_parent_dir_name,ax_output_dir_name,ax_output_mat_file_name);
% 
% % read the video frame pulse data
% session_base_name=sprintf('Test_%s_1',letter_str);
% yn_load_time_stamps = 'y';
% video_pulse_start_ts = ...
%   fn_video_pulse_start_ts(demuxed_data_dir_name, ...
%                           exp_dir_name, ...
%                           session_base_name, ...
%                           session_base_name, ...
%                           yn_load_time_stamps, ...
%                           fs, ...
%                           fs_video);
% 
% % load the raw ax output, and the figure out the frame index that goes with 
% % each snippet
% mouse_from_ax=load_ax_segments_and_append_frame_number(ax_output_mat_file_name_abs,video_pulse_start_ts,associated_video_frame_method);
% 
% % extract the segment we want
% %example_segment_name='Voc130';
% is_example_segment= strcmp(example_segment_id_string,{mouse_from_ax.syl_name});
% mouse_example_segment=mouse_from_ax(is_example_segment);

% extract the corresponding video frame
i_frame_example=24417;
video_file_name=fullfile(exp_dir_name, ...
                         sprintf('Test_%s_1.seq',letter_str));
video_info=fnReadSeqInfo(video_file_name);
example_frame=fnReadFrameFromSeq(video_info,i_frame_example);
[frame_height_in_pels,frame_width_in_pels]=size(example_frame);
%r_frame_upper_left_pel_center_pels=[1/2 size(example_frame,1)-1/2]';  
  % (non-image-style) cartesian coords of the center of the upper-left pel
%r_frame_lower_right_pel_center_pels=[size(example_frame,2)-1/2 1/2]';  
  % (non-image-style) cartesian coords of the center of the lower-right pel
% this puts one corner of the image at the origin

% % get the syl_names, etc for all segments
% [snippet_id_string_all,i_start_all,i_end_all,f_lo_all,f_hi_all, ...
%  r_head_all,r_tail_all,r_mics,Temp, ...
%  dx,x_grid,y_grid,in_cage,r_corners]= ...
%   ssl_trial_overhead_cartesian_heckbertian(base_dir_name, ...
%                                            data_analysis_dir_name, ...
%                                            date_str, ...
%                                            letter_str);
% n_mics=size(r_mics,2);

%xl_example_frame_pels=[1 size(example_frame,2)];
%yl_example_frame_pels=[1 size(example_frame,1)];

% load the meters/pixel scaling factor
meters_2_pixels_file_name= ...
  fullfile(exp_dir_name, ...
           'meters_2_pixels.mat');
s=load(meters_2_pixels_file_name);
meters_per_pixel=s.meters_2_pixels;

% convert the image limits to meters
%xl_example_frame_m=meters_per_pixel*xl_example_frame_pels;  % meters
%yl_example_frame_m=meters_per_pixel*yl_example_frame_pels;  % meters
%r_frame_upper_left_pel_center=meters_per_pixel*r_frame_upper_left_pel_center_pels;  % meters
%r_frame_lower_right_pel_center=meters_per_pixel*r_frame_lower_right_pel_center_pels;

% % get the r_head and r_tail for that segment
% is_example_snippet= strncmp('Voc000051',snippet_id_string_all,9);
% r_head_example_segment=r_head_all(:,is_example_snippet);
% r_tail_example_segment=r_tail_all(:,is_example_snippet);

% % x and y are swapped for head and tail, need to sort out
% % qucik fix:
% r_head_example_segment=flipud(r_head_example_segment)
% r_tail_example_segment=flipud(r_tail_example_segment)

% make the figure
w_fig=6; % in
h_fig=4; % in
w_axes=3;  % in
h_axes=3;  % in
%w_colorbar=0.1;  % in
%w_colorbar_spacer=0.05;  % in

fig_h=figure('color','w', ...
             'colormap',gray(256));
set_figure_size_explicit(fig_h,[w_fig h_fig]);

axes_h=axes('parent',fig_h, ...
            'clim',[0 255]);
set_axes_size_fixed_center_explicit(axes_h,[w_axes h_axes])

[xd,yd]=xdata_ydata_for_conventionally_arranged_heckbertian_image(example_frame,meters_per_pixel);
image('parent', axes_h, ...
      'xdata',100*xd, ...
      'ydata',100*yd, ...
      'cdata',example_frame, ...
      'cdatamapping','scaled');

%z_mics_and_floor=0;
%do_draw_mask=false;
%draw_mics_and_floor_in_axes(axes_h,r_mics,r_corners,z_mics_and_floor,do_draw_mask);

   
   
