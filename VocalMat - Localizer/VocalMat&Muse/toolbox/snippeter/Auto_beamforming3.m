% clc
% clear
% close all

%variables
fc = 450450;%200000;%
num_mice = 1; %number of sources
scale_size = 14;%size of ruler for scale calibration
T = 21.6;%temp of recordings
num_iteration = 10000; %number of random points generated
% radius_step_size = 5; %in millimeters

dir1 = 'C:\Users\neunuebelj\Documents\Lab\Beamforming\beamforming12\Beamforming05152012\demux';%'C:\Users\neunuebelj\Documents\Lab\Beamforming\beamforming4\Beamforming01042012\demux';%
dir2 = 'C:\Users\neunuebelj\Documents\Lab\Beamforming\beamforming12\Beamforming05152012';%'C:\Users\neunuebelj\Documents\Lab\Beamforming\beamforming4\Beamforming01042012';%
saving_dir = 'C:\tmp';%'C:\Users\neunuebelj\Documents\Lab\Beamforming\beamforming10\Beamforming03022012\Data_analysis\automatic';%C:\tmp

%for vocalizations
test = 'B';
audio_fname_prefix = sprintf('Test_%s_1',test);
video_fname_prefix = sprintf('Test_%s_1',test);

%for scale
test2 = 'A';
audio_fname_prefix_scale = sprintf('Test_%s_1',test2);
video_fname_prefix_scale = sprintf('Test_%s_1',test2);

% creates saving directory-if one does not exist
if isdir(saving_dir)==0
    mkdir(saving_dir)
end

%creat syl list
creat_syl_list = 'n';%based on snf files
creat_syl_list_manual = 'n';%based on manual cut vocs

%load the list for other functions
load_syl_list = 'n';%based on snf files
load_syl_list_manual = 'y';%based on manual cut vocs

%extract video frame numbers associated with vocalization
extract_framenumber = 'n';

%determines mice positions
determine_mice_pos = 'n';

%determines tigher fit for bounds of vocalization
fine_scale_data = 'n';

%determines TDOA
calcualte_TDOA = 'y';
filter_data = 'y'; %filteres data (high pass)

%determines estimated delta t based on mice positions
calcualte_estimated_delta_t = 'y';

%metric to determine difference between TDOA estimate from two mice positions and TDOA
calcualte_mean_difference = 'y';

%calculates probs based on size of box
calculate_probs = 'n';
load_saved_corners = 'y';

%plots color maps
plot_color_map='n';
%calculates box estimated delta t
calculate_box_estimated_delta_t='n';

%calculates sound localization based on TDOA
calculate_quadlateration = 'n';

%create pdf with plots of many quntification numbers
plot_pdf = 'n';

%process video data or load preprocessed
load_time_stamps = 'y';

%calulate or load meters to pixels based on scale
load_saved_conversion_factor = 'y';

%determine microphone positions or load positions
load_saved_mic_positions = 'y';

%sets up parallel processing
parallel_processing = 'n';

if strcmp(parallel_processing,'y')==1
    matlabpool 8
end

%timestamps for video file for scale
[dummy handle1 handle2] = fn_video_pulse_start_ts(dir1, dir2, audio_fname_prefix_scale, video_fname_prefix_scale, load_time_stamps);
close (handle1)
close (handle2)
clear handle2 dummy

%timestamps for video file
[video_pulse_start_ts handle1 handle2] = fn_video_pulse_start_ts(dir1, dir2, audio_fname_prefix, video_fname_prefix, load_time_stamps);
close (handle1)
close (handle2)
clear handle2

%conversion factor
scale_vfilename = sprintf('%s.seq',audio_fname_prefix_scale);
[meters_2_pixels handle1] = fn_scale_factor(dir2, scale_vfilename , scale_size, load_saved_conversion_factor);
close (handle1)

%microphone positions
vfilename = sprintf('%s.seq',video_fname_prefix);
[positions_out handle1]  = fn_mic_pos_location(dir2,vfilename,meters_2_pixels,load_saved_mic_positions);
close (handle1)
clc

%velocity of sound
Vsound = fn_velocity_sound(T);

tic
if strcmp(creat_syl_list,'y')==1  %creates structure unless one is saved
    cd (dir1)
    directory_list = dir;
    mouse = fn_vocalization_counter( directory_list,audio_fname_prefix,'.snf' );
    
    cd (saving_dir)
    save(sprintf('%s_Mouse',video_fname_prefix),'mouse')
elseif strcmp(creat_syl_list_manual,'y')==1
    cd (dir1)
    fname = [audio_fname_prefix '_syl_info_manual_jpn.mat'];
    load (fname)
    count = 0;
    for i = 1:size(syl_info_manual_jpn,2)
        if syl_info_manual_jpn(i).good_syl == 1
            count = count + 1;
            mouse(count).syl_name = syl_info_manual_jpn(i).voc_name;
            mouse(count).lf_fine = syl_info_manual_jpn(i).lf;
            mouse(count).hf_fine = syl_info_manual_jpn(i).hf;
            
            mouse(count).start_sample_fine = syl_info_manual_jpn(i).start_time;
            mouse(count).stop_sample_fine = syl_info_manual_jpn(i).stop_time;
        end
    end
    cd (saving_dir)
    save(sprintf('%s_Mouse',video_fname_prefix),'mouse')
else
    cd (saving_dir)
    load(sprintf('%s_Mouse',video_fname_prefix))
end

if strcmp(extract_framenumber,'y')==1
    for i = 1:size(mouse,2) %maybe setup parallel processing
        
        mouse(i).filtering = filter_data;
        mouse(i).num_iteration = num_iteration;
        
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

if strcmp(fine_scale_data,'y')==1
    for i = 1:size(mouse,2)
        [lf_fine, hf_fine, start_sample_fine, stop_sample_fine]= fn_fine_scale_data(dir1, audio_fname_prefix, fc , mouse, i, Vsound);
        
        mouse(i).lf_fine = lf_fine;
        mouse(i).hf_fine = hf_fine;
        
        mouse(i).start_sample_fine = start_sample_fine;
        mouse(i).stop_sample_fine = stop_sample_fine;
                
        clear lf_fine hf_fine start_sample_fine stop_sample_fine
    end
end
clear mouse

if strcmp(determine_mice_pos,'y')==1
    vfilename = sprintf('%s.seq',video_fname_prefix);
    i = 0;
    while i < size(mouse,2)
        i = i + 1;
        %gets mouse position in pixels
        foo = fn_mouse_coords(dir2,mouse,i,vfilename,num_mice);
        mouse(i).pos_data = foo;
        fn_FigureTrackFrame_jpn(vfilename,mouse(i).frame_range(1))
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
                if isdir('mouse_position_images')==0
                    mkdir('mouse_position_images')
                    cd 'mouse_position_images'
                else
                    cd 'mouse_position_images'
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
    cd (saving_dir)
    load(sprintf('%s_Mouse',video_fname_prefix))
end

if strcmp(calcualte_TDOA,'y')==1
    %determines time of delay based on xcorr and arrival times at different speakers
    for i = 40%1:size(mouse,2)
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

if strcmp(calcualte_mean_difference,'y')==1
    %one metric for quantifing differnece between estimated delta t and TDOA
    for i = 1:size(mouse,2)
        TDOA = mouse(1,i).TDOA;
        estimated_delta_t = mouse(1,i).estimated_delta_t;
        [mean_mice tag] = fn_mean_mice( TDOA, estimated_delta_t);
        mouse(i).mean_diff_mice = mean_mice;
        mouse(i).tag = tag;
        clear TDOA estimated_delta_t mean_mice tag
    end
    cd (saving_dir)
    save(sprintf('%s_Mouse',video_fname_prefix),'mouse')
else
    cd (saving_dir)
    load(sprintf('%s_Mouse',video_fname_prefix))
end

if strcmp(calculate_probs,'y')==1
    %calcuates location of corners to generate possible random mouse
    %positions to determine probablity
    vfilename = sprintf('%s.seq',video_fname_prefix);
    [corners_out, handle1] = fn_corner_pos_location(dir2,vfilename,meters_2_pixels,load_saved_corners, video_fname_prefix);
    close (handle1)
    %generates the first and last point of range of numbers that are
    %possible cords (in pixels)
    [ range_x, range_y ] = fn_range_x_y_cords( corners_out );
    num_iterations = mouse(1).num_iteration;
    for j = 1:size(mouse,2)
         if strcmp(mouse(1,j).tag,'GOOD')==1
            for i = 1:num_iteration %setup parallel processing
                if i == 1
                    randomized_cords = zeros(num_iteration,2);
                    clear TDOA
                    TDOA = mouse(1,j).TDOA;
                end
                [randomized_cords foo] = fn_random_select_cords( range_x, range_y, i, randomized_cords);
                
                estimated_delta_t = fn_equations( positions_out, Vsound, foo, meters_2_pixels);
                random_mean_mice(i,:) = fn_mean_mice( TDOA, estimated_delta_t);
                
                clear foo estimated_delta_t
            end
            
            trv_m1 = mouse(1,j).mean_diff_mice(1,1);%*1.03;%need to extend the boundary slightly to include at least one mouse's position in bounding box
            trv_m2 = mouse(1,j).mean_diff_mice(1,2);%*1.03;
            
            precent_m1 = size((find(trv_m1>random_mean_mice(:,1))),1)/num_iteration;
            precent_m2 = size((find(trv_m2>random_mean_mice(:,2))),1)/num_iteration;
            mouse(1,j).mean_sig(1,1) = precent_m1;
            mouse(1,j).mean_sig(1,2) = precent_m2;
            
            [convex_set_x, convex_set_y, convex_hull, area_convex_hull, in] = fn_probability_convexhull(dir2,saving_dir, num_iteration, randomized_cords, random_mean_mice, trv_m1, 1, vfilename, j, mouse, meters_2_pixels);
            mouse(1,j).convex(1,1).convex_set_x = convex_set_x;
            mouse(1,j).convex(1,1).convex_set_y = convex_set_y;
            mouse(1,j).convex(1,1).convex_hull = convex_hull;
            mouse(1,j).convex(1,1).convex_hull_area = area_convex_hull;
            mouse(1,j).convex(1,1).in = in; 
            clear convex_set_x convex_set_y convex_hull area_convex_hull in
            
            [convex_set_x, convex_set_y, convex_hull, area_convex_hull, in] = fn_probability_convexhull(dir2,saving_dir, num_iteration, randomized_cords, random_mean_mice, trv_m2, 2, vfilename, j, mouse, meters_2_pixels);
            mouse(1,j).convex(1,2).convex_set_x = convex_set_x;
            mouse(1,j).convex(1,2).convex_set_y = convex_set_y;
            mouse(1,j).convex(1,2).convex_hull = convex_hull;
            mouse(1,j).convex(1,2).convex_hull_area = area_convex_hull;
            mouse(1,j).convex(1,2).in = in; 
            clear convex_set_x convex_set_y convex_hull area_convex_hull in
            clear precent_m1 percent_m2 random_mean_mice
         end
    end
    cd (saving_dir)
    save(sprintf('%s_Mouse',video_fname_prefix),'mouse')
else
    cd (saving_dir)
    load(sprintf('%s_Mouse',video_fname_prefix))
end

if strcmp(plot_color_map,'y')==1
    vfilename = sprintf('%s.seq',video_fname_prefix);
    %need to change fn_corner_pos_location to make it use Adam's/jpn's code
    [corners_out, handle1] = fn_corner_pos_location(dir2,vfilename,meters_2_pixels,load_saved_corners, video_fname_prefix);
    close (handle1)
    if strcmp(calculate_box_estimated_delta_t,'y') == 1
        %generates the first and last point of range of numbers that are possible cords (in pixels)
        [ range_x, range_y ] = fn_range_x_y_cords( corners_out );
        [ cord_based_estimate, i_pos, j_pos, box_estimated_delta_t ] = fn_box_estimated_delta_t( range_x, range_y, positions_out, Vsound, meters_2_pixels);
        cd (dir2)
        save(sprintf('%s_box_estimated_delta_t',video_fname_prefix),'box_estimated_delta_t')
        save(sprintf('%s_i_pos',video_fname_prefix),'i_pos')
        save(sprintf('%s_j_pos',video_fname_prefix),'j_pos')
        save(sprintf('%s_cord_based_estimate',video_fname_prefix),'cord_based_estimate')
    else
        cd (dir2)
        load(sprintf('%s_box_estimated_delta_t',video_fname_prefix))
        load(sprintf('%s_i_pos',video_fname_prefix))
        load(sprintf('%s_j_pos',video_fname_prefix))
        load(sprintf('%s_cord_based_estimate',video_fname_prefix))
    end
    
    for j = 1:size(mouse,2)
        if strcmp(mouse(1,j).tag,'GOOD')==1
            [x3,y3,val_low,distance_m1,distance_m2] = fn_vocalization_colormap(dir2, saving_dir, cord_based_estimate, i_pos, j_pos, box_estimated_delta_t, j, mouse, meters_2_pixels, vfilename);
            %         [x3,y3,val_low,distance_m1,distance_m2] = fn_vocalization_colormap_old(dir2, dir3, range_x, range_y, imagefile_mice_prefix, j, mouse, meters_2_pixels, Vsound, positions_out );
            mouse(j).voc_colormap(1,1).x = x3;
            mouse(j).voc_colormap(1,1).y = y3;
            mouse(j).voc_colormap(1,1).low_value = val_low;
            mouse(j).voc_colormap(1,1).low_val_distance_m1_mm = distance_m1;
            mouse(j).voc_colormap(1,1).low_val_distance_m2_mm = distance_m2;
            
            x = mouse(j).pos_data(1,1).x_head;
            y = mouse(j).pos_data(1,1).y_head;
            point(1) = mouse(j).pos_data(1,2).x_head;
            point(2) = mouse(j).pos_data(1,2).y_head;
            m1_distance_m2_mm  = fn_calculate_distance( x, y, point);
            m1_distance_m2_mm = m1_distance_m2_mm*meters_2_pixels;
            mouse(j).voc_colormap(1,1).m1_distance_m2_mm = m1_distance_m2_mm;
            
            clear x3 y3 val_low distance_m1 distance_m2 m1_distance_m2_mm x y point
        end
    end
    cd (saving_dir)
    save(sprintf('%s_Mouse',video_fname_prefix),'mouse')
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
        if isdir('quadlateration')==0
            mkdir('quadlateration')
            cd 'quadlateration'
        else
            cd 'quadlateration'
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
toc

if strcmp(parallel_processing,'y')==1
    matlabpool close
end