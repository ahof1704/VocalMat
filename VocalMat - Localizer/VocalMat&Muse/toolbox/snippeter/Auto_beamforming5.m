clc
clear
close all

%variables
fc = 450450;%200000;%
num_mice = 1; %number of sources
source = 'mobile';
scale_size = 14;%size of ruler for scale calibration

num_iteration = 10000; %number of random points generated
% radius_step_size = 5; %in millimeters

path_d = 'A:\Neunuebel\ssl_vocal_structure\08212012\';%;
% path_d = 'A:\Neunuebel\ssl_sys_test\sys_test_06052012\';
% path_d = 'A:\Neunuebel\ssl_sys_test\sys_test_06062012\';
% path_d = 'A:\Neunuebel\ssl_sys_test\sys_test_06102012\';
% path_d = 'A:\Neunuebel\ssl_sys_test\sys_test_06112012\';
% path_d = 'A:\Neunuebel\ssl_sys_test\sys_test_06122012\';
% path_d = 'A:\Neunuebel\ssl_sys_test\sys_test_06132012\';
% path_d = 'A:\Neunuebel\ssl_vocal_structure\08172012\';
dir1 = [path_d 'demux'];%'C:\Users\neunuebelj\Documents\Lab\Beamforming\beamforming4\Beamforming01042012\demux';%
dir2 = path_d;%'C:\Users\neunuebelj\Documents\Lab\Beamforming\beamforming4\Beamforming01042012';%
saving_dir = [path_d 'Data_analysis'];%'C:\Users\neunuebelj\Documents\Lab\Beamforming\beamforming10\Beamforming03022012\Data_analysis\automatic';%C:\tmp

%for scale
test2 = 'A';
audio_fname_prefix_scale = sprintf('Test_%s_1',test2);
video_fname_prefix_scale = sprintf('Test_%s_1',test2);

% creates saving directory-if one does not exist
if isdir(saving_dir)==0
    mkdir(saving_dir)
end

%creat syl list
creat_syl_list_playback = 'n';%based on snf files
creat_syl_list_manual = 'n';%based on manual cut vocs

%load the list for other functions
load_syl_list = 'n';%based on snf files
load_syl_list_manual = 'y';%based on manual cut vocs

%extract video frame numbers associated with vocalization
extract_framenumber = 'n';

%determines mice positions
determine_mice_pos = 'n';
load_saved_pos = 'n'; %y if already saved source locations for frames

%determines TDOA
calcualte_TDOA = 'n';
filter_data = 'y'; %filteres data (high pass)

%calculates the estimated delta t
calcualte_estimated_delta_t = 'n';

%calculates the p-values associated with max xcorr;
calcualte_TDOA_p_val = 'n';

%calculates theoretical max TDOA based on velocity of sound and mic distances
calculated_mic_distance = 'y';

%calculates sound localization based on TDOA
calculate_quadlateration = 'n';

%create pdf with plots of many quntification numbers
plot_pdf = 'n';

% % %process video data or load preprocessed
% load_time_stamps = 'n';
% 
% %calulate or load meters to pixels based on scale
% load_saved_conversion_factor = 'n';
% 
% %determine microphone positions or load positions
% load_saved_mic_positions = 'n';

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

[dummy handle1 handle2] = fn_video_pulse_start_ts(dir1, dir2, audio_fname_prefix_scale, video_fname_prefix_scale, load_time_stamps);
close (handle1)
close (handle2)
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
tic
cd (dir2)
temp_list = 'temps';
load (temp_list)

cd (dir1)
filename_list = 'Experimental_list';
load (filename_list)

if ~isempty(strfind(source,'stationary'))
    for ses_num = 1:size(Experiment_list,1)
                
        if strcmp(load_saved_pos,'y')==0  %gets source position
            %for vocalizations
            file_name1 = Experiment_list{ses_num,1};
            voc_list_pos = strfind(file_name1,'voc_list');
            audio_fname_prefix = file_name1(1:voc_list_pos-2);
            video_fname_prefix = audio_fname_prefix;
            
            strSeekFilename = [dir2,video_fname_prefix,'_video_pulse_start_ts.mat'];
            if ~exist(strSeekFilename,'file')
                load_time_stamps = 'n';
            else
                load_time_stamps = 'y';
            end
            clear strSeekFilename
            
            %timestamps for video file
            [video_pulse_start_ts handle1 handle2] = fn_video_pulse_start_ts(dir1, dir2, audio_fname_prefix, video_fname_prefix, load_time_stamps);
            close (handle1)
            close (handle2)
            clear handle2
            
            cd (dir1)
            load (file_name1)
            
            tmp_good = voc_list(:,6);
            good_vocs = tmp_good == 1;
            list = voc_list(good_vocs,1:5);
            
            clear tmp_good good_vocs 
            
            vfilename = sprintf('%s.seq',video_fname_prefix);
            
            list_dummy(size(list,1)) = struct('frame_range',[]);
            list_dummy(1:size(list_dummy,1)).frame_range = [9, 9];
            
            i = 0;
            while i < 1
                i = i + 1;
                %gets mouse position in pixels
                foo = fn_mouse_coords(dir2,list_dummy,i,vfilename,num_mice);
                
                fn_FigureTrackFrame_jpn(vfilename,list_dummy(i).frame_range(1))
                hold on
                
                plot(foo(1).x_head,foo(1).y_head,'w^','MarkerSize',5,'MarkerFaceColor','w')
                plot(foo(1).x_tail,foo(1).y_tail,'w.','MarkerSize',5,'MarkerFaceColor','w')
                hold off
                
                correct_string = 'n';
                loop_number1 = 0;                
                
                mouse_positions_backup(size(list_dummy,2)) = struct('pos_data',[]);
                for populate = 1:size(mouse_positions_backup,2)
                    mouse_positions_backup(populate).pos_data = foo;
                end
                
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
                            saveas(gcf,'Image_mice_Frame_9.jpg','jpg')
                        elseif strcmp(load_syl_list_manual,'y')==1
                            saveas(gcf,'Image_mice_Frame_9.jpg','jpg')
                        end
                        cd (saving_dir)
                        save(sprintf('%s_mouse_positions_backup',video_fname_prefix),'mouse_positions_backup')
                        close(gcf)
                        clc
                        clear mouse_positions_backup
                    elseif correct == 0
                        correct_string = 'n';
                        disp('repeating pick head positions')
                        pause(5)
                        i = i-1;
                        close(gcf)
                        clear mouse_positions_backup
                        break
                    else
                        correct_string = 'n';
                    end
                end
            end
        end
        clear audio_fname_prefix video_fname_prefix list_dummy mouse_positions_backup
        clear vfilename video_pulse_start_ts file_name1 voc_list_pos list list_dummy foo
        clear subfolder
    end
end

for ses_num = 1:size(Experiment_list,1)    

        %velocity of sound
        T = temps(ses_num,1);
        Vsound = fn_velocity_sound(T);
        
        %for vocalizations
        file_name1 = Experiment_list{ses_num,1};
        dashpos = strfind(file_name1,'_');
        audio_fname_prefix = file_name1(1:dashpos(3)-1);
        video_fname_prefix = audio_fname_prefix;
            
        %timestamps for video file
        strSeekFilename = [dir2,video_fname_prefix,'_video_pulse_start_ts.mat'];
        if ~exist(strSeekFilename,'file') %check if exist
            load_time_stamps = 'n';
        else
            load_time_stamps = 'y';
        end
        clear strSeekFilename
        
        [video_pulse_start_ts handle1 handle2] = fn_video_pulse_start_ts(dir1, dir2, audio_fname_prefix, video_fname_prefix, load_time_stamps);
        close (handle1)
        close (handle2)
        clear handle2
    
    if strcmp(creat_syl_list_playback,'y')==1  %creates structure unless one is saved
        cd (dir1)
        load (file_name1)
        
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
            
            mouse(i).filtering = filter_data;
            
            if strcmp(load_syl_list,'y')==1
                start_point = mouse(i).start_sample;
                end_point = mouse(i).stop_sample;
            elseif strcmp(load_syl_list_manual,'y')==1
                start_point = mouse(i).start_sample_fine;
                end_point = mouse(i).stop_sample_fine;
            end
            
            %determines frames associated with vocalization
            frame_range = fn_extract_frames( video_pulse_start_ts, start_point, end_point );
            mouse(i).frame_range = frame_range;
            clear start_point end_point frame_range
        end
        
        %removes vocilizations that occured before or after video was started/stopped
        for i = size(mouse,2):-1:1
            if isnan(mouse(i).frame_range(1))==1
                mouse(i) = [];
            end
        end
        cd (saving_dir)
        save(sprintf('%s_Mouse',video_fname_prefix),'mouse')
    else
        cd (saving_dir)
        load(sprintf('%s_Mouse',video_fname_prefix))
    end
    
    if strcmp(determine_mice_pos,'y')==1
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
            cd (saving_dir)
            save(sprintf('%s_Mouse',video_fname_prefix),'mouse')
        
        else
            backup_pos_filename = [dir2,'Data_analysis\',video_fname_prefix,'_mouse_positions_backup.mat'];
            load(backup_pos_filename)
            for populate = 1:size(mouse_positions_backup,2)
                mouse(populate).pos_data = mouse_positions_backup(populate).pos_data;
            end
            
            cd (saving_dir)
            save(sprintf('%s_Mouse',video_fname_prefix),'mouse')
        end
    else
        cd (saving_dir)
        load(sprintf('%s_Mouse',video_fname_prefix))
    end
    
    if strcmp(calcualte_TDOA,'y')==1
        %determines time of delay based on xcorr and arrival times at different speakers
        for i = 1:size(mouse,2)
            [TDOA max_corr]= fn_TDOA_estimates(dir1, saving_dir, audio_fname_prefix, fc , mouse, i, Vsound, load_syl_list,load_syl_list_manual);
            mouse(i).TDOA = TDOA;
            mouse(i).max_corr = max_corr;
            clear TDOA max_corr
        end
        cd (saving_dir)
        save(sprintf('%s_Mouse',video_fname_prefix),'mouse')
    else
        cd (saving_dir)
        load(sprintf('%s_Mouse',video_fname_prefix))
    end
    
    if strcmp(calcualte_TDOA_p_val,'y')==1
        %determines p values associated with the xcorrs used to calculated time of delay 
        for i = 1:size(mouse,2)
            [r p]= fn_TDOA_p_val(dir1, saving_dir, audio_fname_prefix, fc , mouse, i, Vsound, load_syl_list,load_syl_list_manual);
            mouse(i).r_corr = r;
            mouse(i).TDOA_p_val = p;
            clear r p
        end
        cd (saving_dir)
        save(sprintf('%s_Mouse',video_fname_prefix),'mouse')
    else
        cd (saving_dir)
        load(sprintf('%s_Mouse',video_fname_prefix))
    end
    
    if strcmp(calculated_mic_distance,'y')==1
        count = 0;
        for m1 = 1:4
            for m2 = m1+1:4
                count = count + 1;
                x1 = positions_out(1,m1).x_m;
                y1 = positions_out(1,m1).y_m;
                x2 = positions_out(1,m2).x_m;
                y2 = positions_out(1,m2).y_m;
                distance = fn_calculate_mic_distance( x1, y1, x2, y2);
                theoretical_max_TDOA(1,count) = distance;
                clear distance x1 x2 y1 y2
            end
        end
        theoretical_max_TDOA = (theoretical_max_TDOA/Vsound)+0.0001;%theoretical_max_TDOA = s and added buffer 0.1 ms incase of noise
        mouse(1).theoretical_max_TDOA = theoretical_max_TDOA;
        cd (saving_dir)
        save(sprintf('%s_Mouse',video_fname_prefix),'mouse')
    else
        cd (saving_dir)
        load(sprintf('%s_Mouse',video_fname_prefix))
    end
    
    %need to add function with estimated delay based on mouse position and microphone position
    if strcmp(calcualte_estimated_delta_t,'y')==1
        %determines time of delay based on xcorr and arrival times at different speakers
        for i = 1:size(mouse,2)
            %determines estimated time of delays based on the positions of the mice
            foo = mouse(i).pos_data;
            estimated_delta_t = fn_equations( positions_out, Vsound, foo, meters_2_pixels);
            mouse(i).estimated_delta_t = estimated_delta_t;
            clear foo estimated_delta_t
        end
        cd (saving_dir)
        save(sprintf('%s_Mouse',video_fname_prefix),'mouse')
    else
        cd (saving_dir)
        load(sprintf('%s_Mouse',video_fname_prefix))
    end
    
    if strcmp(calculate_quadlateration,'y')==1
        vfilename = sprintf('%s.seq',video_fname_prefix);
        for i = 1:size(mouse,2)
            if strcmp(mouse(1,i).tag,'GOOD')==1
                [ r, handle ] = fn_quadlateration_jpn( dir2, positions_out, Vsound, mouse, i, meters_2_pixels, vfilename );
                mouse(i).quadlateration = r;
                clear r
            end           
            cd (saving_dir)
            subfolder = sprintf('%s_quadlateration',video_fname_prefix);
            if isdir(subfolder)==0
                mkdir(subfolder)
                cd (subfolder)
            else
                cd (subfolder)
            end
            saveas(handle,sprintf('Quadlateration_%s.jpg',mouse(i).syl_name(1:end-4)),'jpg')
            close(handle)
            clc
        end
        cd (saving_dir)
        save(sprintf('%s_Mouse',video_fname_prefix),'mouse')
    else
        cd (saving_dir)
        load(sprintf('%s_Mouse',video_fname_prefix))
    end
    
    if strcmp(plot_pdf,'y')==1
        fn_plot_ssl_autoprocess( saving_dir, mouse, 'jpg' )
    end
    clear audio_fname_prefix video_fname_prefix video_pulse_start_ts mouse
    
end
toc

if strcmp(parallel_processing,'y')==1
    matlabpool close
end
