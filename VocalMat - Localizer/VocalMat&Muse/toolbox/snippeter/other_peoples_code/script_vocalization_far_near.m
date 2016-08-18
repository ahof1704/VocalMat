%female vocalization triggered male vocal interaction
clc
clear
close all

col = 2;%start times in voc_list;
fc = 450450;
time_lag =  5; %in seconds
figure_fonttype = 'arial';

video_sample_rate = 29;

time_window_bin_size = 5;%seconds???

s = load('A:\Neunuebel\ssl_vocal_structure\mouse_groups.mat');
mouse_groups = s.mouse_groups;
clear s

DA_folder = 'Data_analysis10';
[ date_str,let_str,base_dir_name] = fn_create_experimental_list;

dsn_start = 9;
dsn_end = size(date_str,2);
triggered_events = cell(1,numel(dsn_start:dsn_end));
triggered_events_frames = cell(1,numel(dsn_start:dsn_end));
triggered_events_pos1 = cell(1,numel(dsn_start:dsn_end));
triggered_events_pos2 = cell(1,numel(dsn_start:dsn_end));
triggered_events_combo1 = cell(1,numel(dsn_start:dsn_end));
triggered_events_combo2 = cell(1,numel(dsn_start:dsn_end));

group_type_value = zeros(numel(dsn_start:dsn_end),1);
count = 0;
count2 = 0;
for dsn = dsn_start:dsn_end
    
    for gn = 2:size(mouse_groups,1)
        gn_s = mouse_groups{gn,1};
        if strcmp(gn_s,date_str{1,dsn})==1
            group_type = mouse_groups{gn,2};
            if strcmp(group_type,'Wild-type')==1
                count2 = count2 + 1;
                group_type_value(count2,1) = 1;
            else
                count2 = count2 + 1;
                group_type_value(count2,1) = 2;
            end
            break
        end
        
    end
    
    path = fullfile(base_dir_name{1,dsn},date_str{1,dsn},DA_folder,'Records');
    cd (path)
    s = load('MUSE_mouse_id_reconstruct_voc_list.mat');
    identified_source = s.identified_source;
    voc_list = s.voc_list;
    clear s
    
    cd ..
    cd ..
    video_file_name = sprintf('Test_%s_1_video_pulse_start_ts',let_str{1,dsn});
    s = load(video_file_name);
    video_pulse_start_ts = s.video_pulse_start_ts;
    clear s
    
    s = load ('meters_2_pixels.mat');
    meters_2_pixels = s.meters_2_pixels;
    clear s
    
    cd 'Tuning/'
    s = load('mouse_ID.mat');
    mid = s.mid;
    clear s
    
    cd ..
    cd 'Results/Tracks/'
    
    track_fn = sprintf('Test_%s_1_convert.mat',let_str{1,dsn});
    if exist(track_fn,'file') == 2
        s = load(track_fn);
        tracks = s.astrctTrackers;
        clear s
    else
        track_fn2 = sprintf('Test_%s_1.mat',let_str{1,dsn});
        s = load(track_fn2);
        tracks = s.astrctTrackers;
        astrctTrackers=prep_trajectory_jpn(tracks,meters_2_pixels,video_sample_rate);
        save(track_fn,'astrctTrackers')
        clear s
    end
    %
    %     [ tmp_events, tmp_frames, tmp_positional_data] = fn_male_vocal_only_triggered_behavior( identified_source,...
    %         voc_list,time_window_range,col,fc,time_lag,...
    %         video_search_window,video_pulse_start_ts,...
    %         mid,tracks,meters_2_pixels,distance_threshold);
    %
    
    [ tmp_events, tmp_frames, tmp_positional_data1,...
           tmp_positional_data2,tmp_combo1,tmp_combo2] = fn_female_vocal_only_preceed_triggered_behavior3( identified_source,...
        voc_list,time_window_range,col,fc,time_lag,...
        video_search_window,video_pulse_start_ts,...
        mid,tracks,meters_2_pixels,distance_threshold,...
        preceed_female_duration);
    
%        [ tmp_events, tmp_frames, tmp_positional_data1,...
%            tmp_positional_data2,tmp_combo1,tmp_combo2] = fn_female_vocal_only_sub_triggered_behavior3( identified_source,...
%         voc_list,time_window_range,col,fc,time_lag,...
%         video_search_window,video_pulse_start_ts,...
%         mid,tracks,meters_2_pixels,distance_threshold,...
%         preceed_female_duration);
    
    count = count + 1;
    triggered_events{1,count} = tmp_events;
    triggered_events_frames{1,count} = tmp_frames;
    triggered_events_pos1{1,count} = tmp_positional_data1;
    triggered_events_pos2{1,count} = tmp_positional_data2;
    triggered_events_combo1{1,count} = tmp_combo1;
    triggered_events_combo2{1,count} = tmp_combo2;
    %     averages_for_ds(:,count,2) = ave_rand;
    clear identified_source voc_list tmp_events video_pulse_start_ts tmp_frames mid tracks
    clear tmp_positional_data
end

fn_plot_group_distances(group_type_value,...
    triggered_events_combo1,triggered_events_combo2,...
    video_search_window,video_sample_rate,'wild')

% tmp = group_type_value==1;
% trans_wild(:,:,:) = transition_matrix_for_ds(:,:,tmp);
% clear tmp
% tmp = group_type_value==2;
% trans_fmr(:,:,:) = transition_matrix_for_ds(:,:,tmp);
% clear tmp