%clc
clear
close all

%variables
fs = 450450;%200000;%
fs_video = 29;  % video frame rate (Hz)
num_mice = 1; %number of sources
number_sessions = 1;
%source = 'mobile';
%scale_size = 14;%size of ruler for scale calibration

%folder for putting saved results
%data_analysis_dir_name = 'Data_analysis10';

data_set_dir_name_list = cell(0,1);
% path_d_list{end+1,1} = '/groups/egnor/egnorlab\Neunuebel\ssl_vocal_structure\10072012\';%;
% path_d_list{end+1,1} = '/groups/egnor/egnorlab\Neunuebel\ssl_vocal_structure\09042012\';%;
% path_d_list{end+1,1} = '/groups/egnor/egnorlab\Neunuebel\ssl_vocal_structure\08212012\';%;
% path_d_list{end+1,1} = '/groups/egnor/egnorlab\Neunuebel\ssl_vocal_structure\08232012\';%;
% path_d_list{end+1,1} = '/groups/egnor/egnorlab\Neunuebel\ssl_vocal_structure\09122012\';%;
% path_d_list{end+1,1} = '/groups/egnor/egnorlab\Neunuebel\ssl_vocal_structure\10052012\';%;
% path_d_list{end+1,1} = '/groups/egnor/egnorlab\Neunuebel\ssl_vocal_structure\10062012\';%;
% path_d_list{end+1,1} = '/groups/egnor/egnorlab\Neunuebel\ssl_vocal_structure\10082012\';%;
% path_d_list{end+1,1} = '/groups/egnor/egnorlab\Neunuebel\ssl_vocal_structure\11102012\';%;
% path_d_list{end+1,1} = '/groups/egnor/egnorlab\Neunuebel\ssl_vocal_structure\11122012\';%;
% path_d_list{end+1,1} = '/groups/egnor/egnorlab\Neunuebel\ssl_vocal_structure\12312012\';%;
% path_d_list{end+1,1} = '/groups/egnor/egnorlab\Neunuebel\ssl_vocal_structure\01012013\';%;
% path_d_list{end+1,1} = '/groups/egnor/egnorlab\Neunuebel\ssl_vocal_structure\01022013\';%
% path_d_list{end+1,1} = '/groups/egnor/egnorlab\Neunuebel\ssl_vocal_structure\03032013\';%
% 
%number 15-20 single mouse
% path_d_list{end+1,1} = '/groups/egnor/egnorlab\Neunuebel\ssl_sys_test\sys_test_06052012\';
% path_d_list{end+1,1} = '/groups/egnor/egnorlab\Neunuebel\ssl_sys_test\sys_test_06062012\';
% path_d_list{end+1,1} = '/groups/egnor/egnorlab\Neunuebel\ssl_sys_test\sys_test_06102012\';
% path_d_list{end+1,1} = '/groups/egnor/egnorlab\Neunuebel\ssl_sys_test\sys_test_06112012\';
% path_d_list{end+1,1} = '/groups/egnor/egnorlab\Neunuebel\ssl_sys_test\sys_test_06122012\';
data_set_dir_name_list{end+1,1} = '/groups/egnor/egnorlab/Neunuebel/ssl_sys_test/sys_test_06132012/';

%creat syl list
%create_syl_list_playback = true;%based on AX output files
%creat_syl_list_manual = false;%based on manual cut vocs

%extract video frame numbers associated with vocalization
%extract_framenumber = true;
associated_video_frame_method = 'close'; %options are begin or close
dur_chunk = 0.005; %s duration of each chunk localized
min_hot_pixels = 11; %minumum number of frequency contour hot pixels needed in freq bin

%determines mice positions
determine_mice_pos = 'motr';%manual, motr, or load_saved

% if strcmp(parallel_processing,'y')==1
%     matlabpool 8
% end

%for data_set = 15:20;%3:9
for i_data_set = 1:length(data_set_dir_name_list)
%     path_d = char(path_d_list(data_set,1));
    data_set_dir_name = data_set_dir_name_list{i_data_set};
    disp(data_set_dir_name)
    demuxed_data_dir_name = fullfile(data_set_dir_name,'demux');%datae with audio files   %'C:\Users\neunuebelj\Documents\Lab\Beamforming\beamforming4\Beamforming01042012\demux';%
    %data_set_dir_name = data_set_dir_name;%experiment folder     %'C:\Users\neunuebelj\Documents\Lab\Beamforming\beamforming4\Beamforming01042012';%
    tracks_dir_name = fullfile(data_set_dir_name,'Results','Tracks');%data with mot
    %saving_dir = [data_set_dir_name data_analysis_dir_name];%'C:\Users\neunuebelj\Documents\Lab\Beamforming\beamforming10\Beamforming03022012\Data_analysis\automatic';%C:\tmp
    saving_dir=pwd();
    
    %for scale
    test_letter = 'A';
    scale_base_name = sprintf('Test_%s_1',test_letter);
    %scale_base_name = sprintf('Test_%s_1',test_letter);
    
%     % creates saving directory-if one does not exist
%     if isdir(saving_dir)==0
%         mkdir(saving_dir)
%     end
    
%     %%%%%%%%%%timestamps for video file for scale
%     video_pulse_file_name = fullfile(data_set_dir_name,[scale_base_name '_video_pulse_start_ts.mat']);
%     if ~exist(video_pulse_file_name,'file') %check if exist
%         load_time_stamps = 'n';
%     else
%         load_time_stamps = 'y';
%     end
%     %clear strSeekFilename
%     
%     [~,handle1] = fn_video_pulse_start_ts(demuxed_data_dir_name, data_set_dir_name, scale_base_name, scale_base_name, load_time_stamps, fc, vfc);
%     close (handle1)
%     clear handle2 dummy
    
%     %%%%%%%%%%%%%%%%%%%%%%%conversion factor
%     meters_2_pixels_file_name = fullfile(data_set_dir_name,'meters_2_pixels.mat');
%     if ~exist(meters_2_pixels_file_name,'file') %check if exist
%         load_saved_conversion_factor = 'n';
%     else
%         load_saved_conversion_factor = 'y';
%     end
%     %clear strSeekFilename
%     
%     scale_vfilename = sprintf('%s.seq',scale_base_name);
%     [meters_2_pixels,handle1] = fn_scale_factor(data_set_dir_name, scale_vfilename , scale_size, load_saved_conversion_factor);
%     close (handle1)
    
%     %%%%%%%%%%%%%%%%%%%%%%%microphone positions
%     positions_out_file_name = fullfile(data_set_dir_name,'positions_out.mat');
%     if ~exist(positions_out_file_name,'file') %check if exist
%         load_saved_mic_positions = 'n';
%     else
%         load_saved_mic_positions = 'y';
%     end
%     %clear strSeekFilename
%     
%     %microphone positions
%     %%%%CHANGED on 10/29/2012
%     % vfilename = sprintf('%s.seq',video_fname_prefix_scale);
%     scale_vfilename = sprintf('%s.seq',scale_base_name);
%     [positions_out,handle1]  = fn_mic_pos_location(data_set_dir_name,scale_vfilename,meters_2_pixels,load_saved_mic_positions);
%     close (handle1)
%     %clc
    
%     %%%%%%%%%%%%%%%%%%processing data
%     %loads temp of experiment
%     %cd (data_set_dir_name)
%     temp_list_file_name = fullfile(data_set_dir_name,'temps.mat');
%     if ~exist(temp_list_file_name,'file') %check if exist
%         load_saved_temps = 'n';
%     else
%         load_saved_temps = 'y';
%     end
%     temps = fn_load_temps(temp_list_file_name,load_saved_temps,number_sessions);
%     % load (temp_list)
    
    %loads Experiment_list letter
    %cd (demuxed_data_dir_name)
    experimental_list_file_name = fullfile(demuxed_data_dir_name,'Experimental_list.mat');
    if ~exist(experimental_list_file_name,'file') %check if exist
        load_saved_voc_file_list = 'n';
    else
        load_saved_voc_file_list = 'y';
    end
    Experiment_list = fn_load_saved_voc_file_list(experimental_list_file_name,load_saved_voc_file_list,number_sessions);
    tic
    % Experiment_list{1,1} = 'Test_E_1_voc_list'
    for i_session = 1:size(Experiment_list,1)
        this_exp_list = char(Experiment_list(i_session,1));
        this_letter_str = this_exp_list(6);
        %velocity of sound
%         T = temps(i_session,1);
%         Vsound = fn_velocity_sound(T);
        
        %for vocalizations
        file_name1 = Experiment_list{i_session,1};
        dashpos = strfind(file_name1,'_');
        session_base_name = file_name1(1:dashpos(3)-1);
        
%         %%%%%%%%%%%%%%%%%%%%%%%cage corner positions
%         corners_file_name = [data_set_dir_name,session_base_name,'_mark_corners.mat'];
%         if ~exist(corners_file_name,'file') %check if exist
%             load_saved_corners = 'n';
%         else
%             load_saved_corners = 'y';
%         end
        %clear strSeekFilename
        
        video_file_name = [session_base_name '.seq'];
%         [corners_out, handle1] = fn_corner_pos_location(data_set_dir_name,video_file_name,meters_2_pixels,load_saved_corners, session_base_name);
%         close (handle1)
        %clc
        
        %timestamps for video file
        video_pulse_file_name = [data_set_dir_name,session_base_name,'_video_pulse_start_ts.mat'];
        if ~exist(video_pulse_file_name,'file') %check if exist
            load_time_stamps = 'n';
        else
            load_time_stamps = 'y';
        end
        %clear strSeekFilename
        %     load_time_stamps = 'n';
        
        [video_pulse_start_ts,handle1] = fn_video_pulse_start_ts(demuxed_data_dir_name, data_set_dir_name, session_base_name, session_base_name, load_time_stamps, fs, fs_video);
        close (handle1)
        clear handle2

        %need to load tracked files and
        voc_list_file_name_pattern = sprintf('*_%s_*',this_letter_str);
        voc_list_mat_file_name = sprintf('Test_%s_1_voc_list_no_merge_har.mat',this_letter_str);
        %cd (demuxed_data_dir_name)
        %cd no_merge_only_har
        dir_struct = dir(fullfile(demuxed_data_dir_name,'no_merge_only_har',voc_list_file_name_pattern));
        voc_list_dir_name=dir_struct.name;
        %cd (tmp_voc_str.name)
        ax_output_mat_file_name=fullfile(demuxed_data_dir_name,'no_merge_only_har',voc_list_dir_name,voc_list_mat_file_name);
        s=load(ax_output_mat_file_name);
        voc_list=s.voc_list;
        clear s;
        mouse_from_ax=load_ax_segments_and_append_frame_number(ax_output_mat_file_name,video_pulse_start_ts,associated_video_frame_method);

        %loads full frequency contours file from directory with voc_list
        fc2_file_name=fullfile(demuxed_data_dir_name,'no_merge_only_har',voc_list_dir_name,'fc2.mat');
        if exist(fc2_file_name,'file')==2
            s = load(fc2_file_name);
            freq_contours2 = s.freq_contours2;
            clear s
        end

%         tmp_good = voc_list(:,6);
%         good_vocs = tmp_good == 1;
%         list = voc_list(good_vocs,1:5);
 
        tic
        n_segments_from_ax=length(mouse_from_ax);
%         mouse_from_ax=struct('syl_name',cell(1,n_segments_from_ax));
%         for i = 1:n_segments_from_ax
%             %voc number
%             mouse_from_ax(i).syl_name = sprintf('Voc%g',list(i,1));
%             %voc freq info
%             mouse_from_ax(i).lf_fine = floor(list(i,4));
%             mouse_from_ax(i).hf_fine = ceil(list(i,5));
%             %voc start/stop times(samples)
%             mouse_from_ax(i).start_sample_fine = list(i,2);
%             mouse_from_ax(i).stop_sample_fine = list(i,3);
%         end
        %cd (saving_dir)
        %save(fullfile(saving_dir,sprintf('%s_Mouse',session_base_name)),'mouse_from_ax');  %   We do _not_ want to save this---it's not the final thing
        clear file_name1 dashpos tmp_good voc_list tmp_good good_vocs list data_set_info
        
%         for i = 1:n_segments_from_ax %maybe setup parallel processing
% 
%             start_point = mouse_from_ax(i).start_sample_fine;
%             end_point = mouse_from_ax(i).stop_sample_fine;
% 
%             %determines frames associated with vocalization
%             [ frame_number,frame_number_ts ] = fn_extract_frames2( video_pulse_start_ts, start_point, end_point );
%             %if want closest video frame associated with vocalization start sample
%             %set associated video frame to close
%             if strcmp(associated_video_frame_method,'close')==1
%                 [smallest_value,smallest_loc] = min(abs(frame_number_ts-start_point));
%                 frame_of_interest = frame_number(smallest_loc);
%                 frame_ts_of_interest = frame_number_ts(smallest_loc);
%                 %if want begining video frame associated with vocalization start sample
%                 %set associated video frame to close
%             elseif  strcmp(associated_video_frame_method,'begin')==1
%                 frame_of_interest = frame_number(1);
%             end
%             mouse_from_ax(i).frame_range = frame_number;
%             mouse_from_ax(i).frame_range_ts = frame_number_ts;
%             mouse_from_ax(i).frame_number = frame_of_interest;
% 
%             clear start_point end_point frame_range
%             clear smallest_value smallest_loc
%         end

        %removes vocilizations that occured before or after video was
        %started/stopped
        idx = cellfun(@(x) x(1),{mouse_from_ax.frame_number});
        has_video = ~isnan(idx);
        %no_video = find(has_no_video==1);
        mouse_intermediate=mouse_from_ax(has_video);
        %mouse(no_video) = [];
        clear idx 

        %removes vocs that are below 0.005 ms
        s_ts = [mouse_intermediate.start_sample_fine];
        e_ts = [mouse_intermediate.stop_sample_fine];
        l_v = e_ts-s_ts;
        voc_list_very_short = find(l_v<ceil(dur_chunk*fs)+1);
        mouse_intermediate(voc_list_very_short) = [];

        %--------------------------------------------------------------------------
        %     function to break into snippets
        %--------------------------------------------------------------------------
        if strcmp(associated_video_frame_method,'close')==1
            [mouse,mouse_video] = fn_chunk_vocalization_time_range7(mouse_intermediate,1/fs_video,fs,video_pulse_start_ts,dur_chunk,freq_contours2,min_hot_pixels);%dur_chunk in s
        elseif  strcmp(associated_video_frame_method,'begin')==1
            mouse = fn_chunk_vocalization_time_range2(mouse_intermediate,1/fs_video,fs,video_pulse_start_ts);
        end
        %clear mouse_intermediate;
        %mouse = new_mouse;
        %clear new_mouse
        %cd (saving_dir)
        
        % Save the snippets
        %save(fullfile(saving_dir,sprintf('%s_Mouse',session_base_name)),'mouse')
        
        %determine mouse positions...add clause for manual or motr
        %cd (tracks_dir_name)
        trackers_file_contents=load(fullfile(tracks_dir_name,session_base_name));
        astrctTrackers=trackers_file_contents.astrctTrackers;
        clear trackers_file_contents;
        %function that sends in number of mice and tracker data returns
        %modified mouse structure-reversals corrected, position data in
        %pixels, position data = x (center), y (center), a, b, theta
        %(corrected for reversals), nose x/y, and tail x/y
        %mouse data structure has the following fields
        %     syl_name
        %     lf_fine
        %     hf_fine
        %     start_sample_fine
        %     stop_sample_fine
        %     frame_range
        %     pos_data
        % position data = mouse(vocalization_number).pos_data(1,mouse_number)
        
        if num_mice > 2
            %manual selection of microphone position and motr reference frames in
            %the same reference frame
            mouse_position = fn_incorporate_tracker_data(astrctTrackers,mouse,num_mice);
        else
            %corrects for different reference frames between microphone position
            %manual selection and motr reference frame
            mouse_position = fn_incorporate_tracker_data_different_rf_frames(astrctTrackers,mouse,num_mice);
        end
        %-------------------------------------------------------------
        
        mouse = rmfield(mouse,'frame_number');
        mouse = rmfield(mouse,'frame_range');
        mouse = rmfield(mouse,'frame_range_ts');
        toc
        
        % save everything
        mouse_file_name_abs=fullfile(saving_dir,sprintf('%s_Mouse',session_base_name));
        save(mouse_file_name_abs,'mouse')%voc data
        save(fullfile(saving_dir,sprintf('%s_Mouse_Video',session_base_name)),'mouse_video')%video data
        save(fullfile(saving_dir,sprintf('%s_Mouse_Position',session_base_name)),'mouse_position')
        %     fn_save_associated_struct_parts(mouse, saving_dir, video_fname_prefix )
        clear audio_fname_prefix video_fname_prefix video_pulse_start_ts mouse*
        
    end
    toc
    
%     if strcmp(parallel_processing,'y')==1
%         matlabpool close
%     end
    
    clear ans corners example_figures filename_list frame_number frame_number_ts
    clear frame_of_interest handle1 i load_saved_conversion_factor
    clear load_saved_corners load_saved_mic_positions load_saved_pos
    clear load_saved_temps load_saved_voc_file_list load_syl_list
    clear load_syl_list_manual load_time_stamps meters_2_pixels num_iteration
    clear parallel_processing positions_out save_file_type
    clear scale_vfilename ses_num strMovieFileName temp_list temps test2
    clear vfilename video_fname_prefix_scale astrctTrackers freq_contours2
    
    params_list = who;
    %cd (saving_dir)
    save(fullfile(saving_dir,'Muse_params_list'),params_list{:})
    clear T Vsound corners_out dir1 dir2 dir3 path_d voc_list_dir voc_list_name
end