clc
clear
close all

%variables
fc = 200000;
num_mice = 2; %number of sources
scale_size = 14;%size of ruler for scale calibration
T = 21.6;%temp of recordings
corr_thresh = 0.2;
num_iteration = 1000; %number of random points generated
radius_step_size = 5; %in millimeters

test = 'C';
dir1 = 'C:\Users\neunuebelj\Documents\Lab\Beamforming\beamforming4\Beamforming01042012\demux';
audio_fname_prefix = sprintf('Test%s_1',test);
dir2 = 'C:\Users\neunuebelj\Documents\Lab\Beamforming\beamforming4\Beamforming01042012';
video_fname_prefix = sprintf('Test%s',test);
imagefile = sprintf('Test%s_1_fm-6',test); %for making speaker locations
imagefile_scale = 'Scale_14inch'; %for loading in scale image to calibrate
imagefile_mice_prefix = sprintf('Test%s_fm-',test); %to determine mouse location--used with frame_range (1)

cd (dir2)
dir3 = sprintf('Corr_threshold%g',corr_thresh);
if isdir(dir3)==0
    mkdir(dir3)
end

%process video data or load preprocessed
load_time_stamps = 'y';
%calulate or load meters to pixels based on scale 
load_saved_conversion_factor = 'y'; 
%determine microphone positions or load positions
load_saved_positions = 'y';
%load structure with data or process data
load_saved_data = 'y';
%load mouse positions or use ginput to determine mouse head location
load_mouse_positional_cords = 'y';
%used to make sure jpg of correct frame is in directory
get_frame_only = 'n';
%calculates probs based on size of box
calculate_probs = 'n';
load_saved_corners = 'y';
%calcualtes probs by increasing size of radius
calculate_radius_probs = 'n';
plot_rings = 'n';
%create pdf with plots of many quntification numbers
plot_pdf = 'n';
%filteres data (high pass)
filter_data = 'y';
%plots points higher (red) or lower (blue) than true value
plot_ring_hist = 'n';
%plots color maps
plot_color_map='y';

%sets up parallel processing
parallel_processing = 'n';

if strcmp(parallel_processing,'y')==1
    matlabpool 8
end
%loads begining and end times of vocalization recorded on channel 1
%NEED A FUNCTION TO EXTRACT ALL VOCALIZATIONS FROM MUSCAT
cd(dir2)
[a b data_points] = xlsread(sprintf('vocalization sound source location %s',test),'sheet2');
clear a b

%timestamps for video file
video_pulse_start_ts = fn_video_pulse_start_ts(dir1, dir2, audio_fname_prefix, video_fname_prefix, load_time_stamps);
close all

%conversion factor
meters_2_pixels = fn_scale_factor(dir2, imagefile_scale , scale_size, load_saved_conversion_factor);
close all

%microphone positions
positions_out  = fn_mic_pos_location(dir2,imagefile,meters_2_pixels,load_saved_positions);
close all
clc

%velocity of sound
Vsound = fn_velocity_sound(T);

if strcmp(load_saved_data,'y')==0  %creates structure unless one is saved
    for i = 1:size(data_points,1) %maybe setup parallel processing
        syl_name =data_points{i,1};
        mouse(i).syl_name = syl_name;
        mouse(i).corr_thresh = corr_thresh;
        mouse(i).filtering = filter_data;
        mouse(i).num_iteration = num_iteration;
        
        start_point = data_points{i,2};
        end_point = data_points{i,3};
        
        %determines frames associated with vocalization
        frame_range = fn_extract_frames( video_pulse_start_ts, start_point, end_point );
        mouse(i).frame_range = frame_range;
        
        if strcmp(get_frame_only,'y')==1  % used to get frame numbers and then user needs to create jpgs from seq frame numbers
            data_points{i,4} = frame_range(1);
            data_points{i,5} = frame_range(2);
        elseif strcmp(get_frame_only,'n')==1  %if jpg created already
            
            %determines time of delay based on xcorr and arrival times at
            %different speakers
            [TDOA max_corr]= fn_TDOA_estimates(dir1, dir2, audio_fname_prefix, fc , start_point, end_point, corr_thresh, 'n', syl_name, 0, filter_data);
            mouse(i).TDOA = TDOA;
            mouse(i).max_corr = max_corr;
            
            %*************************************************************
            %   NOTE:
            %       need to get the coords from mouse video tracking program but manual to test
            %
            %*************************************************************
            if strcmp(load_mouse_positional_cords,'y') == 1
                if i == 1
                    cd (dir2)
                    load (sprintf('Test%s_mouse_positions.mat',test))
                end
                foo(1,1) = mouse_positional_data(1,i).mouse1;
                foo(1,2) = mouse_positional_data(1,i).mouse2;
            else
                %name of file frame to load
                mouse_imagefile = sprintf('%s%d',imagefile_mice_prefix,frame_range(1));
                %gets mouse position in pixels
                foo = fn_mouse_coords(dir2,mouse_imagefile,num_mice);
            end
            mouse(i).pos_data = foo;
            
            %determines estimated time of delays based on the positions of
            %the mice
            estimated_delta_t = fn_equations( positions_out, Vsound, foo, meters_2_pixels);
            mouse(i).estimated_delta_t = estimated_delta_t;
            clear foo
            
            %             %possible metric for quantifing differnece between estimated
            %             %delta t and TDOA
            %             mag_mice  = fn_mag_mice( TDOA, estimated_delta_t );
            %             mouse(i).mag_mice = mag_mice;
            
            %possible metric for quantifing differnece between estimated
            %delta t and TDOA
            mean_mice = fn_mean_mice( TDOA, estimated_delta_t);
            mouse(i).mean_diff_mice = mean_mice;
            
        end
        clear start_point end_point frame_range TDOA mouse_image_file estimated_delta_t foo mag_mice mean_mice max_corr
    end
    cd (dir2)
    if strcmp(pwd,sprintf('%s\\%s',dir2,dir3))==0
        cd (dir3)
    end
    save(sprintf('%s_Mouse',video_fname_prefix),'mouse')
else
    cd (dir2)
    if strcmp(pwd,sprintf('%s\\%s',dir2,dir3))==0
        cd (dir3)
    end
    load(sprintf('%s_Mouse',video_fname_prefix))
end

if strcmp(calculate_probs,'y')==1
    num_iteration = 10000;
    %calcuates location of corners to generate possible random mouse
    %positions to determine probablity
    corners_out = fn_corner_pos_location(dir2,imagefile,meters_2_pixels,load_saved_corners, video_fname_prefix);
    close all
    %generates the first and last point of range of numbers that are
    %possible cords (in pixels)
    [ range_x, range_y ] = fn_range_x_y_cords( corners_out );
    
    for j = 1:size(mouse,2)
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
        
        trv_m1 = mouse(1,j).mean_diff_mice(1,1);
        trv_m2 = mouse(1,j).mean_diff_mice(1,2);
        
        precent_m1 = size((find(trv_m1>random_mean_mice(:,1))),1)/num_iteration;
        precent_m2 = size((find(trv_m2>random_mean_mice(:,2))),1)/num_iteration;
        mouse(1,j).mean_sig(1,1) = precent_m1;
        mouse(1,j).mean_sig(1,2) = precent_m2;
        
        cd (dir2)
        if strcmp(pwd,sprintf('%s\\%s',dir2,dir3))==0
            cd (dir3)
        end
        
        fn_ploticantthinkofnameforgraph(dir2, dir3, num_iteration, randomized_cords, random_mean_mice, trv_m1, 1, imagefile_mice_prefix, j, mouse, precent_m1,meters_2_pixels)
        fn_ploticantthinkofnameforgraph(dir2, dir3, num_iteration, randomized_cords, random_mean_mice, trv_m2, 2, imagefile_mice_prefix, j, mouse, precent_m2,meters_2_pixels)
        
        clear precent_m1 percent_m2 random_mean_mice
    end
    cd (dir2)
    if strcmp(pwd,sprintf('%s\\%s',dir2,dir3))==0
        cd (dir3)
    end
    save(sprintf('%s_Mouse',video_fname_prefix),'mouse')
end

if strcmp(calculate_radius_probs,'y')==1
    theta = [0,359];
    fn_plot_calculate_radius_probs(dir2, dir3, mouse, radius_step_size, meters_2_pixels, theta, positions_out, Vsound, imagefile_mice_prefix, video_fname_prefix)
end

if strcmp(plot_ring_hist,'y')==1
    theta = [0,359]; cd (dir2)
    fn_plot_ring_hist(dir2, dir3, mouse, meters_2_pixels, theta, positions_out, Vsound, imagefile_mice_prefix)
end

if strcmp(plot_pdf,'y')==1
    for i = 1:size(mouse,2) %setup parallel processing
        tmp = mouse(1,i);
        syl_name =data_points{i,1};
        start_point =data_points{i,2};
        end_point =data_points{i,3};
        foo = fn_TDOA_estimates(dir1, dir2, audio_fname_prefix, fc , start_point, end_point, corr_thresh, 'y', syl_name,tmp,filter_data);
        clear foo tmp syl_name start_point end_point
    end
end

if strcmp(plot_color_map,'y')==1
    corners_out = fn_corner_pos_location(dir2,imagefile,meters_2_pixels,load_saved_corners, video_fname_prefix);
    close all
    %generates the first and last point of range of numbers that are
    %possible cords (in pixels)
    [ range_x, range_y ] = fn_range_x_y_cords( corners_out );
    for j = 1:size(mouse,2)
        [x3,y3,val_low,distance_m1,distance_m2] = fn_vocalization_colormap(dir2, dir3, range_x, range_y, imagefile_mice_prefix, j, mouse, meters_2_pixels, Vsound, positions_out );
        mouse(j).voc_colormap(1,1).x = x3;
        mouse(j).voc_colormap(1,1).y = y3;
        mouse(j).voc_colormap(1,1).low_value = val_low;
        mouse(j).voc_colormap(1,1).low_val_distance_m1_mm = distance_m1;
        mouse(j).voc_colormap(1,1).low_val_distance_m2_mm = distance_m2;
        
        x = mouse(j).pos_data(1,1).x;
        y = mouse(j).pos_data(1,1).y;
        point(1) = mouse(j).pos_data(1,2).x;
        point(2) = mouse(j).pos_data(1,2).y;
        m1_distance_m2_mm  = fn_calculate_distance( x, y, point);
        m1_distance_m2_mm = m1_distance_m2_mm*meters_2_pixels;
        mouse(j).voc_colormap(1,1).m1_distance_m2_mm = m1_distance_m2_mm;
        
        clear x3 y3 val_low distance_m1 distance_m2 m1_distance_m2_mm x y point
    end
    
    cd (dir2)
    if strcmp(pwd,sprintf('%s\\%s',dir2,dir3))==0
        cd (dir3)
    end
    save(sprintf('%s_Mouse',video_fname_prefix),'mouse')
end

if strcmp(parallel_processing,'y')==1
    matlabpool close
end