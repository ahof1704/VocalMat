clc
clear
close all

%variables
fc = 450450;%200000;%
vfc = 29;
num_mice = 1; %number of sources
number_sessions = 1;
source = 'mobile';
scale_size = 14;%size of ruler for scale calibration

path_d = 'A:\Neunuebel\ssl_sys_test\sys_test_06052012\';
dir1 = [path_d 'demux'];%'C:\Users\neunuebelj\Documents\Lab\Beamforming\beamforming4\Beamforming01042012\demux';%
dir2 = path_d;%'C:\Users\neunuebelj\Documents\Lab\Beamforming\beamforming4\Beamforming01042012';%
dir3 = [path_d 'Results\Tracks'];
saving_dir = [path_d 'Data_analysis4'];%'C:\Users\neunuebelj\Documents\Lab\Beamforming\beamforming10\Beamforming03022012\Data_analysis\automatic';%C:\tmp

%for scale
test2 = 'A';
audio_fname_prefix_scale = sprintf('Test_%s_1',test2);
video_fname_prefix_scale = sprintf('Test_%s_1',test2);

% creates saving directory-if one does not exist
if isdir(saving_dir)==0
    mkdir(saving_dir)
end

%extract video frame numbers associated with vocalization
extract_framenumber = 'n';

%determines mice positions
determine_mice_pos = 'motr';%manual, motr, or load_saved

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
exp_list = char(Experiment_list);
pos = strfind(exp_list,'_');
prefix = exp_list(1:pos(3));
old_filename = [prefix 'Mouse_b.mat'];
cd (saving_dir)
s = load(old_filename);
old_mouse = s.mouse;
clear s

tic
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
    
    %assigns chunk of vocal segment to nearest frame
    mouse = fn_chunk_vocalization_time_range4(old_mouse,1/29,fc,video_pulse_start_ts,0.01);%dur_chunk = 0.01 s
    
    disp(1)
    
    
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
            mouse = fn_incorporate_tracker_data_different_rf_frames(astrctTrackers,mouse,num_mice);
            
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
            
            
        case strcmp(determine_mice_pos,'load_saved')==1
            cd (saving_dir)
            load(sprintf('%s_Mouse',video_fname_prefix))
    end
    cd (saving_dir)
    save(sprintf('%s_Mouse',video_fname_prefix),'mouse')
    clear audio_fname_prefix video_fname_prefix video_pulse_start_ts mouse
    
end
toc

