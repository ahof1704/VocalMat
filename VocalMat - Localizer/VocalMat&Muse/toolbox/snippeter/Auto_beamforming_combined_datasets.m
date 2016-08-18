clc
clear
close all

%variables
fc = 450450;%200000;%
vfc = 29;
num_mice = 2; %number of sources
number_sessions = 1;
source = 'mobile';
scale_size = 14;%size of ruler for scale calibration

num_iteration = 10000; %number of random points generated
% radius_step_size = 5; %in millimeters

% path_d = 'A:\Neunuebel\ssl_vocal_structure\08212012\';%;
% path_d = 'A:\Neunuebel\ssl_vocal_structure\08232012\';%;
% path_d = 'A:\Neunuebel\ssl_vocal_structure\09042012\';%;
% path_d = 'A:\Neunuebel\ssl_vocal_structure\09122012\';%;
% path_d = 'A:\Neunuebel\ssl_vocal_structure\10052012\';%;
% path_d = 'A:\Neunuebel\ssl_vocal_structure\10062012\';%;
path_d = 'A:\Neunuebel\ssl_vocal_structure\10072012\';%;
% path_d = 'A:\Neunuebel\ssl_vocal_structure\10082012\';%;
% path_d = 'A:\Neunuebel\ssl_vocal_structure\11102012\';%;

% path_d = 'A:\Neunuebel\ssl_sys_test\merged_data\merged1\';
% path_d = 'A:\Neunuebel\ssl_sys_test\sys_test_06052012\';
% path_d = 'A:\Neunuebel\ssl_sys_test\sys_test_06062012\';
% path_d = 'A:\Neunuebel\ssl_sys_test\sys_test_06102012\';
% path_d = 'A:\Neunuebel\ssl_sys_test\sys_test_06112012\';
% path_d = 'A:\Neunuebel\ssl_sys_test\sys_test_06122012\';
% path_d = 'A:\Neunuebel\ssl_sys_test\sys_test_06132012\';
% path_d = 'A:\Neunuebel\ssl_vocal_structure\08172012\';
dir1 = [path_d 'demux'];%'C:\Users\neunuebelj\Documents\Lab\Beamforming\beamforming4\Beamforming01042012\demux';%
dir2 = path_d;%'C:\Users\neunuebelj\Documents\Lab\Beamforming\beamforming4\Beamforming01042012';%
dir3 = [path_d 'Results\Tracks'];
saving_dir = [path_d 'Data_analysis10'];%'C:\Users\neunuebelj\Documents\Lab\Beamforming\beamforming10\Beamforming03022012\Data_analysis\automatic';%C:\tmp

%for scale
test2 = 'A';
audio_fname_prefix_scale = sprintf('Test_%s_1',test2);
video_fname_prefix_scale = sprintf('Test_%s_1',test2);

% creates saving directory-if one does not exist
if isdir(saving_dir)==0
    mkdir(saving_dir)
end

%creat syl list
creat_syl_list_playback = 'y';%based on snf files
creat_syl_list_manual = 'n';%based on manual cut vocs

%load the list for other functions
load_syl_list = 'n';%based on snf files
load_syl_list_manual = 'y';%based on manual cut vocs

%extract video frame numbers associated with vocalization
extract_framenumber = 'y';
associated_video_frame_method = 'close'; %options are begin or close
dur_chunk = 0.005; %s
min_hot_pixels = 11; %minumum number of frequency contour hot pixels needed in freq bin

%determines mice positions
determine_mice_pos = 'motr';%manual, motr, or load_saved
load_saved_pos = 'n'; %y if already saved source locations for frames

%sets up parallel processing
parallel_processing = 'n';

%just saves images not structure
example_figures = 'y';
save_file_type = 'epsc';

if strcmp(parallel_processing,'y')==1
    matlabpool 8
end

%%%%%%%%%%timestamps for video file for scale
strSeekFilename = [dir2,video_fname_prefix_scale,'_video_pulse_start_ts.mat'];
if ~exist(strSeekFilename,'file') %check if exist
    load_time_stamps = 'n';
else
    load_time_stamps = 'y';
end
clear strSeekFilename

[dummy handle1 ] = fn_video_pulse_start_ts(dir1, dir2, audio_fname_prefix_scale, video_fname_prefix_scale, load_time_stamps, fc, vfc);
close (handle1)
clear handle2 dummy

%%%%%%%%%%%%%%%%%%%%%%%conversion factor
strSeekFilename = [dir2,'meters_2_pixels.mat'];
if ~exist(strSeekFilename,'file') %check if exist
    load_saved_conversion_factor = 'n';
else
    load_saved_conversion_factor = 'y';
end
clear strSeekFilename

scale_vfilename = sprintf('%s.seq',audio_fname_prefix_scale);
[meters_2_pixels handle1] = fn_scale_factor(dir2, scale_vfilename , scale_size, load_saved_conversion_factor);
close (handle1)

%%%%%%%%%%%%%%%%%%%%%%%microphone positions
strSeekFilename = [dir2,'positions_out.mat'];
if ~exist(strSeekFilename,'file') %check if exist
    load_saved_mic_positions = 'n';
else
    load_saved_mic_positions = 'y';
end
clear strSeekFilename

%microphone positions
%%%%CHANGED on 10/29/2012
% vfilename = sprintf('%s.seq',video_fname_prefix_scale);
scale_vfilename = sprintf('%s.seq',audio_fname_prefix_scale);
[positions_out handle1]  = fn_mic_pos_location(dir2,scale_vfilename,meters_2_pixels,load_saved_mic_positions);
close (handle1)
clc

%%%%%%%%%%%%%%%%%%processing data

cd (dir2)
temp_list = 'temps.mat';
if ~exist(temp_list,'file') %check if exist
    load_saved_temps = 'n';
else
    load_saved_temps = 'y';
end
temps = fn_load_temps(temp_list,load_saved_temps,number_sessions);
% load (temp_list)

cd (dir1)
filename_list = 'Experimental_list.mat';
if ~exist(filename_list,'file') %check if exist
    load_saved_voc_file_list = 'n';
else
    load_saved_voc_file_list = 'y';
end
Experiment_list = fn_load_saved_voc_file_list(filename_list,load_saved_voc_file_list,number_sessions);

tic
% if ~isempty(strfind(source,'stationary'))
%     for ses_num = 1:size(Experiment_list,1)
%         
%         if strcmp(load_saved_pos,'y')==0  %gets source position
%             %for vocalizations
%             file_name1 = Experiment_list{ses_num,1};
%             voc_list_pos = strfind(file_name1,'voc_list');
%             audio_fname_prefix = file_name1(1:voc_list_pos-2);
%             video_fname_prefix = audio_fname_prefix;
%             
%             %%%%%%%%%%%%%%%%%%%%video frame time stamps
%             strSeekFilename = [dir2,video_fname_prefix,'_video_pulse_start_ts.mat'];
%             if ~exist(strSeekFilename,'file')
%                 load_time_stamps = 'n';
%             else
%                 load_time_stamps = 'y';
%             end
%             clear strSeekFilename
%             
%             %timestamps for video file
%             [video_pulse_start_ts handle1 handle2] = fn_video_pulse_start_ts(dir1, dir2, audio_fname_prefix, video_fname_prefix, load_time_stamps);
%             close (handle1)
%             close (handle2)
%             clear handle2
%             
%             cd (dir1)
%             load (file_name1)
%             
%             tmp_good = voc_list(:,6);
%             good_vocs = tmp_good == 1;
%             list = voc_list(good_vocs,1:5);
%             
%             clear tmp_good good_vocs
%             
%             vfilename = sprintf('%s.seq',video_fname_prefix);
%             
%             list_dummy(size(list,1)) = struct('frame_range',[]);
%             list_dummy(1:size(list_dummy,1)).frame_range = [9, 9];
%             
%             i = 0;
%             while i < 1
%                 i = i + 1;
%                 %gets mouse position in pixels
%                 foo = fn_mouse_coords(dir2,list_dummy,i,vfilename,num_mice);
%                 
%                 fn_FigureTrackFrame_jpn(vfilename,list_dummy(i).frame_range(1))
%                 hold on
%                 
%                 plot(foo(1).x_head,foo(1).y_head,'w^','MarkerSize',5,'MarkerFaceColor','w')
%                 plot(foo(1).x_tail,foo(1).y_tail,'w.','MarkerSize',5,'MarkerFaceColor','w')
%                 hold off
%                 
%                 correct_string = 'n';
%                 loop_number1 = 0;
%                 
%                 mouse_positions_backup(size(list_dummy,2)) = struct('pos_data',[]);
%                 for populate = 1:size(mouse_positions_backup,2)
%                     mouse_positions_backup(populate).pos_data = foo;
%                 end
%                 
%                 while strcmp(correct_string,'y')==0
%                     loop_number1 = loop_number1 + 1;
%                     if loop_number1>1
%                         disp('Please enter 0 or 1')
%                     end
%                     correct = input('Are positions correct? (1 = yes; 0 = no)');
%                     if correct == 1
%                         correct_string = 'y';
%                         cd (saving_dir)
%                         subfolder = sprintf('%s_mouse_position_images',video_fname_prefix);
%                         if isdir(subfolder)==0
%                             mkdir(subfolder)
%                             cd (subfolder)
%                         else
%                             cd (subfolder)
%                         end
%                         
%                         if strcmp(load_syl_list,'y')==1
%                             saveas(gcf,'Image_mice_Frame_9.jpg','jpg')
%                         elseif strcmp(load_syl_list_manual,'y')==1
%                             saveas(gcf,'Image_mice_Frame_9.jpg','jpg')
%                         end
%                         cd (saving_dir)
%                         save(sprintf('%s_mouse_positions_backup',video_fname_prefix),'mouse_positions_backup')
%                         close(gcf)
%                         clc
%                         clear mouse_positions_backup
%                     elseif correct == 0
%                         correct_string = 'n';
%                         disp('repeating pick head positions')
%                         pause(5)
%                         i = i-1;
%                         close(gcf)
%                         clear mouse_positions_backup
%                         break
%                     else
%                         correct_string = 'n';
%                     end
%                 end
%             end
%         end
%         clear audio_fname_prefix video_fname_prefix list_dummy mouse_positions_backup
%         clear vfilename video_pulse_start_ts file_name1 voc_list_pos list list_dummy foo
%         clear subfolder
%     end
% end
 Experiment_list{1,1} = 'Test_E_1';
for ses_num = 1:size(Experiment_list,1)
    
    %velocity of sound
    T = temps(ses_num,1);
    Vsound = fn_velocity_sound(T);
    
    %for vocalizations
    file_name1 = Experiment_list{ses_num,1};
    dashpos = strfind(file_name1,'_');
    audio_fname_prefix = file_name1(1:dashpos(3)-1);
    video_fname_prefix = audio_fname_prefix;
    
    %%%%%%%%%%%%%%%%%%%%%%%cage corner positions
    strSeekFilename = [dir2,video_fname_prefix,'_mark_corners.mat'];
    if ~exist(strSeekFilename,'file') %check if exist
        load_saved_corners = 'n';
    else
        load_saved_corners = 'y';
    end
    clear strSeekFilename
    
    vfilename = [video_fname_prefix '.seq'];
    [corners_out, handle1] = fn_corner_pos_location(dir2,vfilename,meters_2_pixels,load_saved_corners, video_fname_prefix);
    close (handle1)
    clc
    
    %timestamps for video file
    strSeekFilename = [dir2,video_fname_prefix,'_video_pulse_start_ts.mat'];
    if ~exist(strSeekFilename,'file') %check if exist
        load_time_stamps = 'n';
    else
        load_time_stamps = 'y';
    end
    clear strSeekFilename
%     load_time_stamps = 'n';

    [video_pulse_start_ts handle1] = fn_video_pulse_start_ts(dir1, dir2, audio_fname_prefix, video_fname_prefix, load_time_stamps, fc, vfc);
    close (handle1)
    clear handle2
    %need to load tracked files and
    if strcmp(creat_syl_list_playback,'y')==1  %creates structure unless one is saved
        [voc_list_name, voc_list_dir] = uigetfile(dir1);
        cd (voc_list_dir)
        load (voc_list_name)
        
        %loads full frequency contours file from directory with voc_list
        if exist('fc2.mat','file')==2
            s = load('fc2.mat');
            freq_contours2 = s.freq_contours2;
            clear s
        end
        
        tmp_good = voc_list(:,6);
        good_vocs = tmp_good == 1;
        list = voc_list(good_vocs,1:5);
        
        if ~isempty(strfind(source,'stationary'))
            cd (dir2)
            load playback_data_set_info
        end
        for i = 1:size(list,1)
            %voc number
            mouse(i).syl_name = sprintf('Voc%g',list(i,1));
            %voc freq info
            if ~isempty(strfind(source,'stationary'))
                mouse(i).lf_fine = floor(data_set_info{i,4});
                mouse(i).hf_fine = ceil(data_set_info{i,5});
            else
                mouse(i).lf_fine = floor(list(i,4));
                mouse(i).hf_fine = ceil(list(i,5));
            end
            %voc start/stop times(samples)
            if ~isempty(strfind(source,'stationary'))
                mouse(i).start_sample_fine = list(i,2);
                mouse(i).stop_sample_fine = list(i,3);
            else
                mouse(i).start_sample_fine = list(i,2);
                mouse(i).stop_sample_fine = list(i,3);
            end
            %voc number rep if playback
            if ~isempty(strfind(source,'stationary'))
                mouse(i).voc_number = mod(i,25);
                mouse(i).repeat = data_set_info{i,2};
            end
        end
        
        cd (saving_dir)
        save(sprintf('%s_Mouse',video_fname_prefix),'mouse')
        
    else
        cd (saving_dir)
        load(sprintf('%s_Mouse',video_fname_prefix))
    end
    clear file_name1 dashpos tmp_good voc_list tmp_good good_vocs list data_set_info
    
    if strcmp(extract_framenumber,'y')==1
        for i = 1:size(mouse,2) %maybe setup parallel processing
            
            start_point = mouse(i).start_sample_fine;
            end_point = mouse(i).stop_sample_fine;
            
            %determines frames associated with vocalization           
            [ frame_number,frame_number_ts ] = fn_extract_frames2( video_pulse_start_ts, start_point, end_point );
            %if want closest video frame associated with vocalization start sample 
            %set associated video frame to close
            if strcmp(associated_video_frame_method,'close')==1
                [smallest_value smallest_loc] = min(abs(frame_number_ts-start_point));
                frame_of_interest = frame_number(smallest_loc);
            %if want begining video frame associated with vocalization start sample
            %set associated video frame to close
            elseif  strcmp(associated_video_frame_method,'begin')==1
                frame_of_interest = frame_number(1);
            end
            mouse(i).frame_range = frame_number;
            mouse(i).frame_range_ts = frame_number_ts;
            mouse(i).frame_number = frame_of_interest;
            clear start_point end_point frame_range
            clear smallest_value smallest_loc
        end
        
        %removes vocilizations that occured before or after video was started/stopped
%         for i = size(mouse,2):-1:1
%             if isnan(mouse(i).frame_range(1))==1
%                 mouse(i) = [];
%             end
%         end
        idx = cellfun(@(x) x(1),{mouse.frame_number});
        whereidx = isnan(idx);
        no_video = find(whereidx==1);
        mouse(no_video) = [];
        clear idx whereidx
        
        
        %removes vocs that are below 0.005 ms
%         for i = size(mouse,2):-1:1
%             if (mouse(i).stop_sample_fine-mouse(i).start_sample_fine)<0.005*fc
%                 mouse(i) = [];
%             end
%         end
        s_ts = [mouse.start_sample_fine];
        e_ts = [mouse.stop_sample_fine];
        l_v = e_ts-s_ts;
        voc_list_very_short = find(l_v<ceil(dur_chunk*fc)+1);
        mouse(voc_list_very_short) = [];
        
        %--------------------------------------------------------------------------
        %     function to break into chunks
        %--------------------------------------------------------------------------
        if strcmp(associated_video_frame_method,'close')==1
            new_mouse = fn_chunk_vocalization_time_range7(mouse,1/29,fc,video_pulse_start_ts,dur_chunk,freq_contours2,min_hot_pixels);%dur_chunk in s 
        elseif  strcmp(associated_video_frame_method,'begin')==1
            new_mouse = fn_chunk_vocalization_time_range2(mouse,1/29,fc,video_pulse_start_ts);
        end
        clear mouse
        mouse = new_mouse;
        clear new_mouse
        cd (saving_dir)
        save(sprintf('%s_Mouse',video_fname_prefix),'mouse')
    else
        cd (saving_dir)
        load(sprintf('%s_Mouse',video_fname_prefix))
    end
    size(mouse)
    %determine mouse positions...add clause for manual or motr
    
    switch isnumeric(ses_num)
        case strcmp(determine_mice_pos,'manual')==1
            if strcmp(load_saved_pos,'y')==0
                vfilename = sprintf('%s.seq',video_fname_prefix);
                vfilename2 = [dir2 vfilename];
                i = 0;
                while i < size(mouse,2)
                    i = i + 1;
                    %gets mouse position in pixels
                    foo = fn_mouse_coords(dir2,mouse,i,vfilename2,num_mice);
                    mouse(i).pos_data = foo;
                    fn_FigureTrackFrame_jpn(vfilename2,mouse(i).frame_range(1))
                    hold on
                    if num_mice == 1
                        plot(foo(1).x_head,foo(1).y_head,'w^','MarkerSize',5,'MarkerFaceColor','w')
                        plot(foo(1).x_tail,foo(1).y_tail,'w.','MarkerSize',5,'MarkerFaceColor','w')
                    elseif num_mice == 2
                        plot(foo(1).x_head,foo(1).y_head,'w^','MarkerSize',5,'MarkerFaceColor','w')
                        plot(foo(1).x_tail,foo(1).y_tail,'w.','MarkerSize',5,'MarkerFaceColor','w')
                        plot(foo(2).x_head,foo(2).y_head,'ws','MarkerSize',5,'MarkerFaceColor','w')
                        plot(foo(2).x_tail,foo(2).y_tail,'w*','MarkerSize',5,'MarkerFaceColor','w')
                    end
                    correct_string = 'n';
                    loop_number1 = 0;
                    mouse_positions_backup(i).pos_data = foo;
                    hold off
                    while strcmp(correct_string,'y')==0
                        loop_number1 = loop_number1 + 1;
                        if loop_number1>1
                            disp('Please enter 0 or 1')
                        end
                        correct = input('Are positions correct? (1 = yes; 0 = no)');
                        if correct == 1
                            correct_string = 'y';
                            
                            cd (saving_dir)
                            subfolder = sprintf('%s_mouse_position_images',video_fname_prefix);
                            if isdir(subfolder)==0
                                mkdir(subfolder)
                                cd (subfolder)
                            else
                                cd (subfolder)
                            end
                            
                            if strcmp(load_syl_list,'y')==1
                                saveas(gcf,sprintf('Image_mice_%s.jpg',mouse(i).syl_name(1:end-4)),'jpg')
                            elseif strcmp(load_syl_list_manual,'y')==1
                                saveas(gcf,sprintf('Image_mice_%s.jpg',mouse(i).syl_name),'jpg')
                            end
                            
                            cd (saving_dir)
                            save(sprintf('%s_mouse_positions_backup',video_fname_prefix),'mouse_positions_backup')
                            close(gcf)
                            clc
                        elseif correct == 0
                            correct_string = 'n';
                            disp('repeating pick head positions')
                            pause(5)
                            i = i-1;
                            close(gcf)
                            break
                        else
                            correct_string = 'n';
                        end
                    end
                end
            else
                backup_pos_filename = [dir2,'Data_analysis\',video_fname_prefix,'_mouse_positions_backup.mat'];
                load(backup_pos_filename)
                for populate = 1:size(mouse_positions_backup,2)
                    mouse(populate).pos_data = mouse_positions_backup(populate).pos_data;
                end
            end
            %saves mouse structure
            cd (saving_dir)
            save(sprintf('%s_Mouse',video_fname_prefix),'mouse')
        case strcmp(determine_mice_pos,'motr')==1
            
            cd (dir3)
            load (video_fname_prefix)
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
    mouse = fn_incorporate_tracker_data(astrctTrackers,mouse,num_mice);
else
    %corrects for different reference frames between microphone position
    %manual selection and motr reference frame
    mouse = fn_incorporate_tracker_data_different_rf_frames(astrctTrackers,mouse,num_mice);
end
%-------------------------------------------------------------

            
            %             video_fname_prefix ='Test_B_1';
%             vfile = sprintf('%s.seq',video_fname_prefix);
%             for iii = 1:15%size(mouse,2)
%                 cd (dir2)
%                 fn_FigureTrackFrame_jpn(vfile,mouse(iii).frame_range)
%                 hold on
%                 plot(mouse(iii).pos_data(1,1).nose_x,mouse(iii).pos_data(1,1).nose_y,'ys')
%                 plot(mouse(iii).pos_data(1,2).nose_x,mouse(iii).pos_data(1,2).nose_y,'rs')
%                 plot(mouse(iii).pos_data(1,3).nose_x,mouse(iii).pos_data(1,3).nose_y,'gs')
%                 plot(mouse(iii).pos_data(1,4).nose_x,mouse(iii).pos_data(1,4).nose_y,'cs')
%                 cd (saving_dir)
%                 saveas(gca,sprintf('Example tracking %d.jpg',iii),'jpg')
%                 close all
%             end
%             disp(1)
            
        case strcmp(determine_mice_pos,'load_saved')==1
            cd (saving_dir)
            load(sprintf('%s_Mouse',video_fname_prefix))
    end
    cd (saving_dir)
    save(sprintf('%s_Mouse',video_fname_prefix),'mouse')
    fn_save_associated_struct_parts(mouse, saving_dir, video_fname_prefix )
    clear audio_fname_prefix video_fname_prefix video_pulse_start_ts mouse
    
end
toc

if strcmp(parallel_processing,'y')==1
    matlabpool close
end

clear ans corners example_figures filename_list frame_number frame_number_ts
clear frame_of_interest handle1 i load_saved_conversion_factor
clear load_saved_corners load_saved_mic_positions load_saved_pos
clear load_saved_temps load_saved_voc_file_list load_syl_list
clear load_syl_list_manual load_time_stamps meters_2_pixels num_iteration
clear parallel_processing positions_out save_file_type scale_size
clear scale_vfilename ses_num strMovieFileName temp_list temps test2
clear vfc vfilename video_fname_prefix_scale

params_list = who;
cd (saving_dir)
save('Muse_params_list',params_list{:})