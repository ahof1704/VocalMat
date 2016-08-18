%%
clc
clear
close all

four_channel_line = 'y';
scatter_plot = 'n';
box_position_error = 'n';
box_position_orientation_maxintensity = 'n';
box_position_orientation_intensityindex = 'n';
plot_individual_error = 'n';
get_microphone_positions = 'y';
calculate_theta = 'y';
comp_amp_or = 'n';
scatter_amp_or = 'y';
fc = 450450;
load('C:\Users\neunuebelj\Documents\Lab\Analysis\ssl_test_analysis\r_est_raw_single_mouse.mat')
%% asigns name
date_str=date_str_raw;
letter_str=letter_str_raw;
i_syl=i_syl_raw;
r_est=r_est_raw;
a=a_raw;
mse_min=mse_min_raw;
mse_body=mse_body_raw;
ms_total=ms_total_raw;
r_head=r_head_raw;
r_tail=r_tail_raw;
N=N_raw;
N_filt=N_filt_raw;
R=R_raw;
%% marshalls and flattens
% marshall the values across trials into double arrays (not cell arrays)
[date_str_flat, ...
    letter_str_flat, ...
    i_syl_flat, ...
    r_est_flat, ...
    a_flat, ...
    mse_min_flat, ...
    mse_body_flat, ...
    ms_total_flat, ...
    r_head_flat, ...
    r_tail_flat, ...
    N_flat, ...
    N_filt_flat] = ...
    flatten_trials(date_str, ...
    letter_str, ...
    i_syl, ...
    r_est, ...
    a, ...
    mse_min, ...
    mse_body, ...
    ms_total, ...
    r_head, ...
    r_tail, ...
    N, ...
    N_filt);

%%
if exist('C:\Users\neunuebelj\Documents\Lab\Analysis\ssl_test_analysis\r_est_raw_single_mouse_jpn.mat')==0
    count = 1;
    mouse_id = 0;
    dur = zeros(size(i_syl_flat));
    bandwidth = zeros(size(i_syl_flat));
    spm = zeros(size(i_syl_flat));
    epm = zeros(size(i_syl_flat));
    low_f = zeros(size(i_syl_flat));
    high_f = zeros(size(i_syl_flat));
    mouse_id_matrix = zeros(size(i_syl_flat));
    noise_rms = zeros(size(i_syl_flat,1),4);
    signal_rms = zeros(size(i_syl_flat,1),4);
    % figure('position',[164 106 560 1001],'color','w')
    while count<=size(date_str_flat,1)
        mouse_id = mouse_id + 1;
        current_date = date_str_flat(count,1);
        current_let = letter_str_flat(count,1);
        count2 = 0;
        range1 = ismember(date_str_flat,current_date);
        range2 = ismember(letter_str_flat,current_let);
        range_date = range1 == 1;
        range_let = range2 == 1;
        merged_date_let = range_date + range_let;
        range = find(merged_date_let==2);
        for i = range(1):range(end)
            count2 = count2 + 1;
            if i==range(1)
                file2 = sprintf('A:\\Neunuebel\\ssl_sys_test\\sys_test_%s\\Data_analysis\\Test_%s_1_Mouse.mat',date_str_flat{count,1},letter_str_flat{count,1});
                load(file2)
            end
            start_point = mouse(count2).start_sample_fine;
            end_point = mouse(count2).stop_sample_fine;
            low_f_t = mouse(count2).lf_fine;
            high_f_t = mouse(count2).hf_fine;
            
            if high_f_t<low_f_t
                tmp = low_f_t;
                low_f_t = high_f_t;
                high_f_t = tmp;
                clear tmp
            end
            
            mouse_id_matrix (count,1) = mouse_id;
            bandwidth(count,1) = high_f_t-low_f_t;%hz
            dur(count,1) = ((end_point-start_point)/fc)*1000;%ms
            low_f(count,1) = low_f_t;
            high_f(count,1) = high_f_t;
            spm(count,1) = start_point;
            epm(count,1) = end_point;
            count = count + 1;
            clear start_point end_point low_f_t high_f_t
        end
        clear range range2 current mouse
        %     scatter(dur,bandwidth,'filled')
    end
    
    error = zeros(size(i_syl_flat));
    color_e = zeros(3,size(i_syl_flat,1));
    bandwidth = bandwidth/1000;%kHz
    low_f = low_f/1000;%kHz
    high_f = high_f/1000;%kHz
    
    % elseif exists('C:\Users\neunuebelj\Documents\Lab\Analysis\ssl_test_analysis\r_est_raw_single_mouse.mat')==2
    %    load('C:\Users\neunuebelj\Documents\Lab\Analysis\ssl_test_analysis\flattened_data.mat')
    % end
    
    
    prefix_file1 = 'Test_A_1';
    for chan_num = 4
        count = 1;
        while count<=size(date_str_flat,1)
            mouse_id = mouse_id + 1;
            current_date = date_str_flat(count,1);
            current_let = letter_str_flat(count,1);
            count2 = 0;
            range1 = ismember(date_str_flat,current_date);
            range2 = ismember(letter_str_flat,current_let);
            range_date = range1 == 1;
            range_let = range2 == 1;
            merged_date_let = range_date + range_let;
            range = find(merged_date_let==2);
            for i = range(1):range(end)
                count2 = count2 + 1;
                if i==range(1)
                    dir1 = sprintf('A:\\Neunuebel\\ssl_sys_test\\sys_test_%s\\demux\\',char(current_date));
                    dir2 = sprintf('A:\\Neunuebel\\ssl_sys_test\\sys_test_%s\\',char(current_date));
                    filename_prefix2 = sprintf('Test_%s_1.ch%d',char(current_let),chan_num); %signal
                    filename_prefix1 = sprintf('%s.ch%d',prefix_file1,chan_num);%noise
                    cd (dir2)
                    load('Test_A_1_video_pulse_start_ts')
                    start_ts_n = video_pulse_start_ts(1);
                    stop_ts_n = video_pulse_start_ts(end);
                    cd (dir1)
                    %                 m_n = memmapfile(filename_prefix1,         ...
                    %                     'Offset', 0,        ...
                    %                     'Format', 'single',    ...
                    %                     'Writable', false);
                    %                 m_s = memmapfile(filename_prefix2,         ...
                    %                     'Offset', 0,        ...
                    %                     'Format', 'single',    ...
                    %                     'Writable', false);
                    
                end
                start_ts_s = spm(count,1);
                stop_ts_s = epm(count,1);
                lf = low_f(count,1)*1000;
                hf = high_f(count,1)*1000;
%                 if i == range(1)
                    nrms = calculate_channel_rms2(dir1, start_ts_n, stop_ts_n, hf, lf, filename_prefix1, fc);
                    clear m_n  %start_ts_n stop_ts_n
%                 end
                noise_rms(count,chan_num) = nrms;
%                 signal_rms(count,chan_num) = calculate_channel_rms2(dir1, start_ts_s, stop_ts_s, hf, lf, filename_prefix2, fc);
                
                count = count + 1;
                clear start_point end_point low_f_t high_f_t
            end
            clear range range2 current mouse nrms
            %     scatter(dur,bandwidth,'filled')
        end
        
    end
elseif exist('C:\Users\neunuebelj\Documents\Lab\Analysis\ssl_test_analysis\r_est_raw_single_mouse_jpn.mat')==2
    load('C:\Users\neunuebelj\Documents\Lab\Analysis\ssl_test_analysis\r_est_raw_single_mouse_jpn.mat')
end
%%

if strcmp(get_microphone_positions,'y')==1
    count = 1;
    mouse_id = 0;
    mic_pos_x = zeros(size(i_syl_flat,1),4);
    mic_pos_y = zeros(size(i_syl_flat,1),4);
    % figure('position',[164 106 560 1001],'color','w')
    while count<=size(date_str_flat,1)
        mouse_id = mouse_id + 1;
        current_date = date_str_flat(count,1);
        current_let = letter_str_flat(count,1);
        count2 = 0;
        range1 = ismember(date_str_flat,current_date);
        range2 = ismember(letter_str_flat,current_let);
        range_date = range1 == 1;
        range_let = range2 == 1;
        merged_date_let = range_date + range_let;
        range = find(merged_date_let==2);
        for i = range(1):range(end)
            count2 = count2 + 1;
            if i==range(1)
                file2 = sprintf('A:\\Neunuebel\\ssl_sys_test\\sys_test_%s\\positions_out.mat',date_str_flat{count,1});
                load(file2)
            end
            for mn = 1:4
                mic_pos_x(count,mn) = positions_out(mn).x_m;
                mic_pos_y(count,mn) = positions_out(mn).y_m;
            end
            count = count + 1;
            clear start_point end_point low_f_t high_f_t
        end
        clear range range2 current mouse
        %     scatter(dur,bandwidth,'filled')
    end
end
%%
r1 = linspace(0,255,5)';
g1 = r1;
b1 = 255*ones(size(g1));
color_matrix_t = cat(2,r1, g1, b1);
color_matrix_b = flipdim(color_matrix_t,2);
color_matrix_b = flipdim(color_matrix_b,1);
color_matrix_b(1,:) = [];
color_matrix = cat(1,color_matrix_t,color_matrix_b);
color_matrix = color_matrix/255;

% b1 = linspace(255,0,5)';
% r1 = zeros(size(b1));
% g1 = zeros(size(b1));
% color_matrix_t = cat(2,r1,g1,b1);
% color_matrix_b = flipdim(color_matrix_t,2);
% color_matrix_b = flipdim(color_matrix_b,1);
% color_matrix_b(1,:) = [];
% color_matrix = cat(1,color_matrix_t,color_matrix_b);
% color_matrix = color_matrix/255;

for i = 1:size(r_est_flat,2)
    point1 = r_est_flat(:,i);
    point2 = r_head_flat(:,i);
    error_p = fn_calculate_distance2( point1, point2);
    if (error_p*100)>8
        color_error = color_matrix(9,:);
    elseif ((error_p*100)>7 && (error_p*100)<=8)
        color_error = color_matrix(8,:);
    elseif ((error_p*100)>6 && (error_p*100)<=7)
        color_error = color_matrix(7,:);
    elseif ((error_p*100)>5 && (error_p*100)<=6)
        color_error = color_matrix(6,:);
    elseif ((error_p*100)>4 && (error_p*100)<=5)
        color_error = color_matrix(5,:);
    elseif ((error_p*100)>3 && (error_p*100)<=4)
        color_error = color_matrix(4,:);
    elseif ((error_p*100)>2 && (error_p*100)<=3)
        color_error = color_matrix(3,:);
    elseif ((error_p*100)>1 && (error_p*100)<=2)
        color_error = color_matrix(2,:);
    elseif ((error_p*100)>0 && (error_p*100)<=1)
        color_error = color_matrix(1,:);
    end
    color_e(1:3,i) = color_error;
    error(i,1) = error_p;
    clear color_error point1 point2
    
end
%%
clear noise_rms
load('A:\Neunuebel\ssl_sys_test\noise_rms_matched_filter_all.mat')  %correct noise calculations based on filtered range of associated signals
s_2_n = signal_rms./noise_rms;
tmp = sort(s_2_n,2,'descend');
%
%%
if strcmp(scatter_plot,'y')==1
    figure('Color','w')
    set(gcf,'Units','Inches','Position',[0 0 10 7.5])
    axes1 = axes('Parent',gcf,'Color',[0 0 0]);
    hold(axes1,'all');
    foi1 = dur;
    foi2 = high_f;
    xlabel_str = 'Duration (ms)';
    ylabel_str = 'High Frequency (kHz)';
    for i = 1:size(r_est_flat,2)
        color_p = color_e(:,i)';
        scatter(foi1(i,1),foi2(i,1),6,color_p,'filled')
        hold on
    end
    xlabel(xlabel_str)
    ylabel(ylabel_str)
    xlim_vals = get(gca,'xlim');
    ylim_vals = get(gca,'ylim');
    
    cd C:\Users\neunuebelj\Documents\Lab\Analysis\ssl_test_analysis
    % saveas(gcf,'All_error_distance','jpg')
    %close (gcf)
    for j = 1:9
        if j == 1
            errors = find((error*100)>8);
            t1 = 'Error > 8';
            t2 = 'greater8';
        elseif j == 2
            errors = find((error*100)>7 & (error*100)<=8);
            t1 = '7 < Error < 8';
            t2 = 'greater7less8';
        elseif j == 3
            errors = find((error*100)>6 & (error*100)<=7);
            t1 = '6 < Error < 7';
            t2 = 'greater6less7';
        elseif j == 4
            errors = find((error*100)>5 & (error*100)<=6);
            t1 = '5 < Error < 6';
            t2 = 'greater5less6';
        elseif j == 5
            errors = find((error*100)>4 & (error*100)<=5);
            t1 = '4 < Error < 5';
            t2 = 'greater4less5';
        elseif j == 6
            errors = find((error*100)>3 & (error*100)<=4);
            t1 = '3 < Error < 4';
            t2 = 'greater3less4';
        elseif j == 7
            errors = find((error*100)>2 & (error*100)<=3);
            t1 = '2 < Error < 3';
            t2 = 'greater2less3';
        elseif j == 8
            errors = find((error*100)>1 & (error*100)<=2);
            t1 = '1 < Error < 2';
            t2 = 'greater1less2';
        elseif j == 9
            errors = find((error*100)>0 & (error*100)<=1);
            t1 = '0 < Error < 1';
            t2 = 'greater0less1';
        end
        figure('Color','w')
        set(gcf,'Units','Inches','Position',[0 0 10 7.5])
        axes1 = axes('Parent',gcf,'Color',[0 0 0]);
        hold(axes1,'all');
        for i = errors
            color_p = color_e(:,i)';
            scatter(foi1(i,1),foi2(i,1),6,color_p,'filled')
            hold on
        end
        title(t1)
        xlabel(xlabel_str)
        ylabel(ylabel_str)
        set(gca,'xlim',xlim_vals)
        set(gca,'ylim',ylim_vals)
        cd C:\Users\neunuebelj\Documents\Lab\Analysis\ssl_test_analysis
        set(gcf,'InvertHardcopy','off')
        %     saveas(gcf,t2,'jpg')
        clear errors
        %     close (gcf)
    end
    clear foi*
    close all
end
%%
if strcmp(four_channel_line,'y')==1
    figure('Color','w')
    axes1 = axes('Parent',gcf,'Color',[0 0 0]);
    hold(axes1,'all');
    xlabel_str = 'Sorted Channels';
    ylabel_str = 'Signal//Noise';
    xtick_label = {'Largest','','','Smallest'};
    for i = 1:size(r_est_flat,2)
        color_p = color_e(:,i)';
        plot(tmp(i,:),'color',color_p)
        hold on
    end
    xlabel(xlabel_str)
    ylabel(ylabel_str)
    xlim_vals = get(gca,'xlim');
    ylim_vals = get(gca,'ylim');
    set(gca,'xtick',1:4,'xticklabel',xtick_label)
    
    cd C:\Users\neunuebelj\Documents\Lab\Analysis\ssl_test_analysis
    % saveas(gcf,'All_error_distance','jpg')
    %close (gcf)
    for j = 1:9
        if j == 1
            errors = find((error*100)>8);
            t1 = 'Error > 8';
            t2 = 'greater8';
        elseif j == 2
            errors = find((error*100)>7 & (error*100)<=8);
            t1 = '7 < Error < 8';
            t2 = 'greater7less8';
        elseif j == 3
            errors = find((error*100)>6 & (error*100)<=7);
            t1 = '6 < Error < 7';
            t2 = 'greater6less7';
        elseif j == 4
            errors = find((error*100)>5 & (error*100)<=6);
            t1 = '5 < Error < 6';
            t2 = 'greater5less6';
        elseif j == 5
            errors = find((error*100)>4 & (error*100)<=5);
            t1 = '4 < Error < 5';
            t2 = 'greater4less5';
        elseif j == 6
            errors = find((error*100)>3 & (error*100)<=4);
            t1 = '3 < Error < 4';
            t2 = 'greater3less4';
        elseif j == 7
            errors = find((error*100)>2 & (error*100)<=3);
            t1 = '2 < Error < 3';
            t2 = 'greater2less3';
        elseif j == 8
            errors = find((error*100)>1 & (error*100)<=2);
            t1 = '1 < Error < 2';
            t2 = 'greater1less2';
        elseif j == 9
            errors = find((error*100)>0 & (error*100)<=1);
            t1 = '0 < Error < 1';
            t2 = 'greater0less1';
        end
        figure('Color','w')
        axes1 = axes('Parent',gcf,'Color',[0 0 0]);
        hold(axes1,'all');
        for i = errors
            color_p = color_e(:,i)';
            color_p_t = color_p(1,:);
            plot(tmp(i,:)','color',color_p_t)
            hold on
        end
        title(t1)
        xlabel(xlabel_str)
        ylabel(ylabel_str)
        set(gca,'xlim',xlim_vals)
        set(gca,'ylim',ylim_vals)
        %     cd C:\Users\neunuebelj\Documents\Lab\Analysis\ssl_test_analysis
        %     set(gcf,'InvertHardcopy','off')
        %     saveas(gcf,t2,'jpg')
        clear errors
        %     close (gcf)
    end
end
%%
point_size = 10;
if strcmp(box_position_error,'y') == 1
    figure('Color','w')
    set(gcf,'Units','Inches','Position',[0 0 10 7.5])
    axes1 = axes('Parent',gcf,'Color',[0 0 0]);
    hold(axes1,'all');
    xlabel_str = 'x (m)';
    ylabel_str = 'y (m)';
    
    for i = 1:size(r_est_flat,2)
        color_p = color_e(:,i)';
        scatter(r_head_flat(1,i),r_head_flat(2,i),point_size,color_p,'filled')
        hold on
    end
    xlabel(xlabel_str)
    ylabel(ylabel_str)
    xlim_vals = get(gca,'xlim');
    ylim_vals = get(gca,'ylim');
    
    cd C:\Users\neunuebelj\Documents\Lab\Analysis\ssl_test_analysis
    % saveas(gcf,'All_error_distance','jpg')
    %close (gcf)
    for j = 1:9
        if j == 1
            errors = find((error*100)>8);
            t1 = 'Error > 8';
            t2 = 'greater8';
        elseif j == 2
            errors = find((error*100)>7 & (error*100)<=8);
            t1 = '7 < Error < 8';
            t2 = 'greater7less8';
        elseif j == 3
            errors = find((error*100)>6 & (error*100)<=7);
            t1 = '6 < Error < 7';
            t2 = 'greater6less7';
        elseif j == 4
            errors = find((error*100)>5 & (error*100)<=6);
            t1 = '5 < Error < 6';
            t2 = 'greater5less6';
        elseif j == 5
            errors = find((error*100)>4 & (error*100)<=5);
            t1 = '4 < Error < 5';
            t2 = 'greater4less5';
        elseif j == 6
            errors = find((error*100)>3 & (error*100)<=4);
            t1 = '3 < Error < 4';
            t2 = 'greater3less4';
        elseif j == 7
            errors = find((error*100)>2 & (error*100)<=3);
            t1 = '2 < Error < 3';
            t2 = 'greater2less3';
        elseif j == 8
            errors = find((error*100)>1 & (error*100)<=2);
            t1 = '1 < Error < 2';
            t2 = 'greater1less2';
        elseif j == 9
            errors = find((error*100)>0 & (error*100)<=1);
            t1 = '0 < Error < 1';
            t2 = 'greater0less1';
        end
        figure('Color','w')
        axes1 = axes('Parent',gcf,'Color',[0 0 0]);
        set(gcf,'Units','Inches','Position',[0 0 10 7.5])
        hold(axes1,'all');
        for i = errors
            color_p = color_e(:,i)';
            scatter(r_head_flat(1,i),r_head_flat(2,i),point_size,color_p,'filled')
            hold on
        end
        title(t1)
        xlabel(xlabel_str)
        ylabel(ylabel_str)
        set(gca,'xlim',xlim_vals)
        set(gca,'ylim',ylim_vals)
        %     cd C:\Users\neunuebelj\Documents\Lab\Analysis\ssl_test_analysis
        %     set(gcf,'InvertHardcopy','off')
        %     saveas(gcf,t2,'jpg')
        clear errors
        %     close (gcf)
    end
end
%%

if strcmp(box_position_orientation_maxintensity,'y') == 1
    s_2_n = signal_rms./noise_rms;
    tmp = sort(s_2_n,2,'descend');
    tmp(:,2:4) = [];
    tmp = 10*(tmp/max(tmp));
    figure('Color','w')
    set(gcf,'Units','Inches','Position',[0 0 10 7.5])
    axes1 = axes('Parent',gcf,'Color',[0 0 0]);
    hold(axes1,'all');
    xlabel_str = 'x (m)';
    ylabel_str = 'y (m)';
    
    for i = 1:size(r_est_flat,2)
        color_p = color_e(:,i)';
        plot([r_head_flat(1,i) r_tail_flat(1,i)],[r_head_flat(2,i) r_tail_flat(2,i)],'color',color_p,'linewidth',tmp(i,1))
        
        hold on
        scatter(r_head_flat(1,i),r_head_flat(2,i),30,color_p,'o','filled')
    end
    xlabel(xlabel_str)
    ylabel(ylabel_str)
    xlim_vals = get(gca,'xlim');
    ylim_vals = get(gca,'ylim');
    
    cd C:\Users\neunuebelj\Documents\Lab\Analysis\ssl_test_analysis
    % saveas(gcf,'All_error_distance','jpg')
    %close (gcf)
    for j = 1:9
        if j == 1
            errors = find((error*100)>8);
            t1 = 'Error > 8';
            t2 = 'greater8';
        elseif j == 2
            errors = find((error*100)>7 & (error*100)<=8);
            t1 = '7 < Error < 8';
            t2 = 'greater7less8';
        elseif j == 3
            errors = find((error*100)>6 & (error*100)<=7);
            t1 = '6 < Error < 7';
            t2 = 'greater6less7';
        elseif j == 4
            errors = find((error*100)>5 & (error*100)<=6);
            t1 = '5 < Error < 6';
            t2 = 'greater5less6';
        elseif j == 5
            errors = find((error*100)>4 & (error*100)<=5);
            t1 = '4 < Error < 5';
            t2 = 'greater4less5';
        elseif j == 6
            errors = find((error*100)>3 & (error*100)<=4);
            t1 = '3 < Error < 4';
            t2 = 'greater3less4';
        elseif j == 7
            errors = find((error*100)>2 & (error*100)<=3);
            t1 = '2 < Error < 3';
            t2 = 'greater2less3';
        elseif j == 8
            errors = find((error*100)>1 & (error*100)<=2);
            t1 = '1 < Error < 2';
            t2 = 'greater1less2';
        elseif j == 9
            errors = find((error*100)>0 & (error*100)<=1);
            t1 = '0 < Error < 1';
            t2 = 'greater0less1';
        end
        figure('Color','w')
        axes1 = axes('Parent',gcf,'Color',[0 0 0]);
        set(gcf,'Units','Inches','Position',[0 0 10 7.5])
        hold(axes1,'all');
        for i = 1:numel(errors)
            loc = errors(i,1);
            color_p = color_e(:,loc)';
            plot([r_head_flat(1,loc) r_tail_flat(1,loc)],[r_head_flat(2,loc) r_tail_flat(2,loc)],'color',color_p,'linewidth',tmp(loc,1))
            hold on
            scatter(r_head_flat(1,loc),r_head_flat(2,loc),30,color_p,'o','filled')
        end
        title(t1)
        xlabel(xlabel_str)
        ylabel(ylabel_str)
        set(gca,'xlim',xlim_vals)
        set(gca,'ylim',ylim_vals)
        %     cd C:\Users\neunuebelj\Documents\Lab\Analysis\ssl_test_analysis
        %     set(gcf,'InvertHardcopy','off')
        %     saveas(gcf,t2,'jpg')
        clear errors
        %     close (gcf)
    end
end

%%
point_size = 10;
if strcmp(box_position_orientation_intensityindex,'y') == 1
    s_2_n = signal_rms./noise_rms;
    tmp_0 = sort(s_2_n,2,'descend');
    %     tmp(:,2:4) = [];
    num = tmp_0(:,1)-tmp_0(:,4);
    den = tmp_0(:,1)+tmp_0(:,4);
    
    tmp = 5*(num./den);
    figure('Color','w')
    set(gcf,'Units','Inches','Position',[0 0 10 7.5])
    scatter(error*100,tmp/5,10,'filled')
    xlabel('Error')
    ylabel('Intensity Index')
    
    figure('Color','w')
    set(gcf,'Units','Inches','Position',[0 0 10 7.5])
    scatter(error*100,tmp_0(:,3),10,'filled')
    xlabel('Error')
    ylabel('3rd largest intensity')
    
    figure('Color','w')
    set(gcf,'Units','Inches','Position',[0 0 10 7.5])
    axes1 = axes('Parent',gcf,'Color',[0 0 0]);
    hold(axes1,'all');
    xlabel_str = 'x (m)';
    ylabel_str = 'y (m)';
    
    for i = 1:size(r_est_flat,2)
        color_p = color_e(:,i)';
        plot([r_head_flat(1,i) r_tail_flat(1,i)],[r_head_flat(2,i) r_tail_flat(2,i)],'color',color_p,'linewidth',tmp(i,1))
        
        hold on
        scatter(r_head_flat(1,i),r_head_flat(2,i),30,color_p,'o','filled')
    end
    xlabel(xlabel_str)
    ylabel(ylabel_str)
    xlim_vals = get(gca,'xlim');
    ylim_vals = get(gca,'ylim');
    
    cd C:\Users\neunuebelj\Documents\Lab\Analysis\ssl_test_analysis
    % saveas(gcf,'All_error_distance','jpg')
    %close (gcf)
    for j = 1:9
        if j == 1
            errors = find((error*100)>8);
            t1 = 'Error > 8';
            t2 = 'greater8';
        elseif j == 2
            errors = find((error*100)>7 & (error*100)<=8);
            t1 = '7 < Error < 8';
            t2 = 'greater7less8';
        elseif j == 3
            errors = find((error*100)>6 & (error*100)<=7);
            t1 = '6 < Error < 7';
            t2 = 'greater6less7';
        elseif j == 4
            errors = find((error*100)>5 & (error*100)<=6);
            t1 = '5 < Error < 6';
            t2 = 'greater5less6';
        elseif j == 5
            errors = find((error*100)>4 & (error*100)<=5);
            t1 = '4 < Error < 5';
            t2 = 'greater4less5';
        elseif j == 6
            errors = find((error*100)>3 & (error*100)<=4);
            t1 = '3 < Error < 4';
            t2 = 'greater3less4';
        elseif j == 7
            errors = find((error*100)>2 & (error*100)<=3);
            t1 = '2 < Error < 3';
            t2 = 'greater2less3';
        elseif j == 8
            errors = find((error*100)>1 & (error*100)<=2);
            t1 = '1 < Error < 2';
            t2 = 'greater1less2';
        elseif j == 9
            errors = find((error*100)>0 & (error*100)<=1);
            t1 = '0 < Error < 1';
            t2 = 'greater0less1';
        end
        figure('Color','w')
        axes1 = axes('Parent',gcf,'Color',[0 0 0]);
        set(gcf,'Units','Inches','Position',[0 0 10 7.5])
        hold(axes1,'all');
        for i = 1:numel(errors)
            loc = errors(i,1);
            color_p = color_e(:,loc)';
            plot([r_head_flat(1,loc) r_tail_flat(1,loc)],[r_head_flat(2,loc) r_tail_flat(2,loc)],'color',color_p,'linewidth',tmp(loc,1))
            hold on
            scatter(r_head_flat(1,loc),r_head_flat(2,loc),30,color_p,'o','filled')
        end
        title(t1)
        xlabel(xlabel_str)
        ylabel(ylabel_str)
        set(gca,'xlim',xlim_vals)
        set(gca,'ylim',ylim_vals)
        %     cd C:\Users\neunuebelj\Documents\Lab\Analysis\ssl_test_analysis
        %     set(gcf,'InvertHardcopy','off')
        %     saveas(gcf,t2,'jpg')
        clear errors
        %     close (gcf)
    end
end

%%
if strcmp(plot_individual_error,'y') == 1
    figure('Color','w')
    set(gcf,'Units','Inches','Position',[0 0 8.5 11])
    subplot(9,1,1)
    hist(error*100,0:1:max(error)*100,'color','k')
    xlim_vals = get(gca,'xlim');
    xlim_vals(1) = -1;
    set(gca,'xticklabel',[],'box','off','xlim',xlim_vals)
    for mouse_num = 2:9
        mouse_loc = find(mouse_id_matrix==mouse_num-1);
        error_tmp = error(mouse_loc);
        subplot(9,1,mouse_num)
        hist(error_tmp*100,0:1:max(error)*100,'color','k')
        if mouse_num<=8
            set(gca,'xticklabel',[])
        end
        set(gca,'box','off','xlim',xlim_vals)
    end
    
end
%%
if strcmp(calculate_theta,'y') == 1
    d_x = zeros(1,size(r_est_flat,2));
    d_y = zeros(1,size(r_est_flat,2));
    orientation = zeros(1,size(r_est_flat,2));
    d_xm = zeros(4,size(r_est_flat,2));
    d_ym = zeros(4,size(r_est_flat,2));
    theta = zeros(4,size(r_est_flat,2));
    for i = 1:size(r_est_flat,2)
        d_x(1,i) = r_head_flat(1,i)-r_tail_flat(1,i);
        d_y(1,i) = r_head_flat(2,i)-r_tail_flat(2,i);
        tmp = atan2(d_y(1,i),d_x(1,i))*180/pi;
        if tmp<0
            orientation(1,i) = 360+tmp;
        else
            orientation(1,i) = tmp;
        end
        clear tmp
    end
    
    for mn = 1:4
        for i = 1:size(r_est_flat,2)
            d_xm(mn,i) = mic_pos_x(i,mn)-r_tail_flat(1,i);
            d_ym(mn,i) = mic_pos_y(i,mn)-r_tail_flat(2,i);
            tmp = atan2(d_ym(mn,i),d_xm(mn,i))*180/pi;
            if tmp<0
                theta(mn,i) = 360+tmp;
            else
                theta(mn,i) = tmp;
            end
            clear tmp
        end
    end
    clear b1 b2 m1 m2
    for k = 1:size(r_est_flat,2);
        angle = theta(1:4,k)-orientation(1,k);
        tmp = find(angle<0);
        angle(tmp) = angle(tmp)+360;
        mag = s_2_n(k,1:4)';
        [x y] = pol2cart(angle*(pi/180),mag);
        anum = k*ones(size(x));
        %         [x2 y2] = pol2cart(theta(1:4,k)*(pi/180),mag);
        if k == 1
            x_f = x;
            y_f = y;
            anum_f = anum;
        else
            x_f = cat(1,x_f,x);
            y_f = cat(1,y_f,y);
            anum_f = cat(1,anum_f,anum);
        end
        
        clear angle mag x y tmp
        %         close all
        %         clc
        %         figure
        %         plot([r_head_flat(1,k) r_tail_flat(1,k)],[r_head_flat(2,k) r_tail_flat(2,k)],'color','r')
        %         hold on
        %         scatter(r_head_flat(1,k),r_head_flat(2,k),30,'ro','filled')
        %         scatter(r_tail_flat(1,k),r_tail_flat(2,k),30,'r',...
        %             'MarkerFaceColor',[1 0 0],...
        %             'MarkerEdgeColor',[1 0 0],...
        %             'Marker','+')
        %         xlim([0 1])
        %         ylim([0 1])
        %         scatter(mic_pos_x(k,1),mic_pos_y(k,1),30,'r','o','filled')
        %         scatter(mic_pos_x(k,2),mic_pos_y(k,2),30,'g','o','filled')
        %         scatter(mic_pos_x(k,3),mic_pos_y(k,3),30,'b','o','filled')
        %         scatter(mic_pos_x(k,4),mic_pos_y(k,4),30,'k','o','filled')
        %         plot([mic_pos_x(k,1) mic_pos_x(k,3)], [mic_pos_y(k,1) mic_pos_y(k,3)],'c')
        %         plot([mic_pos_x(k,2) mic_pos_x(k,4)], [mic_pos_y(k,2) mic_pos_y(k,4)],'c')
        %
        %         disp(orientation(k))
        %         disp(theta(:,k))
        %         hold off
        %         pause
        
        %         disp([mic_pos_x(k,1) mic_pos_y(k,1)])
        %         disp([mic_pos_x(k,2) mic_pos_y(k,2)])
        %         disp([mic_pos_x(k,3) mic_pos_y(k,3)])
        %         disp([mic_pos_x(k,4) mic_pos_y(k,4)])
        
        %         disp([r_head_flat(1,k) r_head_flat(2,k)])
        
        m1(k) = (mic_pos_y(k,1)-mic_pos_y(k,3))/(mic_pos_x(k,1)-mic_pos_x(k,3));
        m2(k) = (mic_pos_y(k,2)-mic_pos_y(k,4))/(mic_pos_x(k,2)-mic_pos_x(k,4));
        b_1(k) = mic_pos_y(k,1)-m1(k)*mic_pos_x(k,1);
        b_2(k) = mic_pos_y(k,2)-m2(k)*mic_pos_x(k,2);
        x_int = (b_1(k)-b_2(k))/(m2(k)-m1(k));
        y_int = b_1(k)+m1(k)*x_int;
        x_value_lines(k,1) = mic_pos_x(k,1);
        x_value_lines(k,2) = x_int;
        x_value_lines(k,3) = mic_pos_x(k,3);
        y_value_lines(k,1) = mic_pos_y(k,2);
        y_value_lines(k,2) = y_int;
        y_value_lines(k,3) = mic_pos_y(k,4);
        y_q(k) = m1(k)*(r_head_flat(1,k))+b_1(k);
        x_q(k) = (r_head_flat(2,k)-b_2(k))/m2(k);
        if (r_head_flat(1,k)<=x_q(k))
            if (r_head_flat(2,k)<=y_q(k))
                quadrant(k) = 3;
            elseif (r_head_flat(2,k)>y_q(k))
                quadrant(k) = 2;
            end
        elseif (r_head_flat(1,k)>x_q(k))
            if (r_head_flat(2,k)<=y_q(k))
                quadrant(k) = 4;
            elseif (r_head_flat(2,k)>y_q(k))
                quadrant(k) = 1;
            end
        end
        %         disp(quadrant(k))
        %         clc
        
        %          pause
    end
    if strcmp(comp_amp_or,'y')==1
        figure('color','w')
        compass(x_f,y_f)
        close all
        for j = 1:11
            if j == 1
                errors = find((error*100)>8);
                t1 = 'Error > 8';
                t2 = 'greater8';
            elseif j == 2
                errors = find((error*100)>7 & (error*100)<=8);
                t1 = '7 < Error < 8';
                t2 = 'greater7less8';
            elseif j == 3
                errors = find((error*100)>6 & (error*100)<=7);
                t1 = '6 < Error < 7';
                t2 = 'greater6less7';
            elseif j == 4
                errors = find((error*100)>5 & (error*100)<=6);
                t1 = '5 < Error < 6';
                t2 = 'greater5less6';
            elseif j == 5
                errors = find((error*100)>4 & (error*100)<=5);
                t1 = '4 < Error < 5';
                t2 = 'greater4less5';
            elseif j == 6
                errors = find((error*100)>3 & (error*100)<=4);
                t1 = '3 < Error < 4';
                t2 = 'greater3less4';
            elseif j == 7
                errors = find((error*100)>2 & (error*100)<=3);
                t1 = '2 < Error < 3';
                t2 = 'greater2less3';
            elseif j == 8
                errors = find((error*100)>1 & (error*100)<=2);
                t1 = '1 < Error < 2';
                t2 = 'greater1less2';
            elseif j == 9
                errors = find((error*100)>0 & (error*100)<=1);
                t1 = '0 < Error < 1';
                t2 = 'greater0less1';
            elseif j == 10
                errors = find((error*100)>0 & (error*100)<=4);
                t1 = '0 < Error < 4';
                t2 = 'greater0less1';
                color_p = 'k';
            elseif j == 11
                errors = find((error*100)>4);
                t1 = 'Error >= 4';
                t2 = 'greater0less1';
                color_p = 'k';
            end
            for i = 1:size(errors,1)
                anum_pos = find(anum_f == errors(i,1));
                if i == 1
                    anum_pos_f = anum_pos;
                else
                    anum_pos_f = cat(1,anum_pos_f,anum_pos);
                end
            end
            
            Zf = figure('Color','w');
            set(gcf,'Units','Inches','Position',[0 0 10 7.5])
            %         hold(axes1,'all');
            Zhd = compass(200,0,'w.');
            hold on
            if j<10
                color_p = color_e(:,errors(1))';
            end
            if color_p(1) == 1 &&  color_p(2) == 1 && color_p(3) == 1
                color_p = [0 0 0];
            end
            Zh = compass(x_f(anum_pos_f,1),y_f(anum_pos_f,1));
            set(Zh,'color',color_p);
            title(t1)
            
            %     cd C:\Users\neunuebelj\Documents\Lab\Analysis\ssl_test_analysis
            %     set(gcf,'InvertHardcopy','off')
            %     saveas(gcf,t2,'jpg')
            clear errors Z color_p
            %     close (gcf)
        end
    end
    if strcmp(scatter_amp_or,'y')==1
        %         count = 0;
        %         for k = 1:size(r_est_flat,2);
        %             angle = theta(1:4,k)-orientation(1,k);
        %             tmp = find(angle<0);
        %             angle(tmp) = angle(tmp)+360;
        %             mag = s_2_n(k,1:4)';
        %             if k == 1
        %                 reshaped_theta = angle;
        %                 reshaped_s2n = mag;
        %             else
        %                 reshaped_theta = cat(1,reshaped_theta,angle);
        %                 reshaped_s2n = cat(1,reshaped_s2n,mag);
        %             end
        %             clear angle mag tmp
        %         end
        theta_ranges = linspace(0,360,7);
        figure('color','w')
        hold on
        set(gcf,'Units','Inches','Position',[0 0 10 7.5*2])
        count = 0;
        for i = size(theta_ranges,2):-1:2
            tmp_o = orientation>theta_ranges(1,i-1) & orientation<=theta_ranges(1,i);
%             tmp_t = theta(:,tmp_o);
            tmp_a = s_2_n(tmp_o,:)';
            max_v = max(tmp_a,[],1);
            tmp_a1 = tmp_a(1,:)./max_v;
            tmp_a2 = tmp_a(2,:)./max_v;
            tmp_a3 = tmp_a(3,:)./max_v;
            tmp_a4 = tmp_a(4,:)./max_v;
            clear tmp_a
            tmp_a = cat(1,tmp_a1,tmp_a2,tmp_a3,tmp_a4);
            count = count + 1;
            subplot(size(theta_ranges,2),1,count)
            t = sprintf('Orientation \n %d to %d \n degrees',theta_ranges(1,i-1)+1,theta_ranges(1,i));
            plot(tmp_a)
            ylabel(t)
            set(gca,'xtick',1:4)
            %             disp(1)
            clear tmp_o tmp_t tmp_a max_v
        end
        
        fh = figure('color','w');
%         set(gcf,'Units','Inches','Position',[0 0 10 7.5*2])
        count2 = 0;
        [sorted_s2n sort_s2n_loc] = sort(s_2_n,2,'descend');
        sorted_perms0 = perms([1 2 3 4]);
        foo = 0;
        for n = 1:4
%             for m = n+1:4
%                 tmp = find((sort_s2n_loc(:,1)==n | sort_s2n_loc(:,2)==n) & (sort_s2n_loc(:,1)==m | sort_s2n_loc(:,2)==m));
                tmp = find(sort_s2n_loc(:,1)==n);
                tmp_s = max(size(tmp));
                count2 = count2 + 1;
                figure(fh)
%                 subplot(3,2,count2)
                subplot(2,2,count2)
                scatter(r_head_flat(1,tmp),r_head_flat(2,tmp),30,'ro','filled')
                hold on
                scatter(mic_pos_x(1,1),mic_pos_y(1,1),30,[120 234 238]/255,'o','filled')
                scatter(mic_pos_x(1,2),mic_pos_y(1,2),30,'g','o','filled')
                scatter(mic_pos_x(1,3),mic_pos_y(1,3),30,'b','o','filled')
                scatter(mic_pos_x(1,4),mic_pos_y(1,4),30,'k','o','filled')
                %                 title(sprintf('%d%d',n,m))
                title(sprintf('%d - %d',n,tmp_s))                
                axis equal
                xlim([0 1])
                ylim([0 1])                
                clear tmp tmp_s
%             end
        end
        clear fh
        
        sorted_perms = perms([1 2 3 4]);
        fh = figure('color','w');
        set(gcf,'Units','Inches','Position',[0 0 10 7.5*2])
        count2 = 0;
        for sp = 1:size(sorted_perms,1)
            tmp = sorted_perms(sp,:);
            count = 0;
            for jj = 1:size(sort_s2n_loc,1)
%                 sort_s2n_loc(jj,:)
%                 tmp
                if isequal(tmp,sort_s2n_loc(jj,:))==1
                    count = count + 1;
                    locations(1,count) = jj;
                end
            end
            count2 = count2 + 1;
            figure(fh)
            subplot(6,4,count2)
            scatter(r_head_flat(1,locations),r_head_flat(2,locations),30,'ro','filled')
            hold on
            scatter(mic_pos_x(1,1),mic_pos_y(1,1),30,[120 234 238]/255,'o','filled')
            scatter(mic_pos_x(1,2),mic_pos_y(1,2),30,'g','o','filled')
            scatter(mic_pos_x(1,3),mic_pos_y(1,3),30,'b','o','filled')
            scatter(mic_pos_x(1,4),mic_pos_y(1,4),30,'k','o','filled')
            title(sprintf('%d%d%d%d',tmp(1),tmp(2),tmp(3),tmp(4)))
            
            figure('Color','w')
            set(gcf,'Units','Inches','Position',[0 0 10 7.5])
            for ii = 1:numel(locations)
                loc = locations(ii);
                plot([r_head_flat(1,loc) r_tail_flat(1,loc)],[r_head_flat(2,loc) r_tail_flat(2,loc)],'r')
                hold on
                scatter(r_head_flat(1,loc),r_head_flat(2,loc),30,'r','o','filled')
                title(sprintf('%d%d%d%d',tmp(1),tmp(2),tmp(3),tmp(4)))
                xlim([0 1])
                ylim([0 1])
                if ii == 1
                    scatter(mic_pos_x(1,1),mic_pos_y(1,1),30,[120 234 238]/255,'o','filled')
                    scatter(mic_pos_x(1,2),mic_pos_y(1,2),30,'g','o','filled')
                    scatter(mic_pos_x(1,3),mic_pos_y(1,3),30,'b','o','filled')
                    scatter(mic_pos_x(1,4),mic_pos_y(1,4),30,'k','o','filled')
                end
            end
            
            clear locations tmp
        end
        disp(1)
        
%         for quadrant_value = 1:4
%             quadrant_loc = find(quadrant == quadrant_value);
%             q_o = orientation(quadrant_loc);
%             figure('color','w')
%             hold on
%             set(gcf,'Units','Inches','Position',[0 0 10 7.5*2])
%             count = 0;
%             for i = size(theta_ranges,2):-1:2
%                 tmp_o = q_o>theta_ranges(1,i-1) & q_o<=theta_ranges(1,i);
%                 tmp_t = theta(:,tmp_o);
%                 tmp_a = s_2_n(tmp_o,:)';
%                 max_v = max(tmp_a,[],1);
%                 tmp_a1 = tmp_a(1,:)./max_v;
%                 tmp_a2 = tmp_a(2,:)./max_v;
%                 tmp_a3 = tmp_a(3,:)./max_v;
%                 tmp_a4 = tmp_a(4,:)./max_v;
%                 clear tmp_a
%                 tmp_a = cat(1,tmp_a1,tmp_a2,tmp_a3,tmp_a4);
%                 count = count + 1;
%                 subplot(size(theta_ranges,2),1,count)
%                 t = sprintf('Orientation \n %d to %d \n degrees',theta_ranges(1,i-1)+1,theta_ranges(1,i));
%                 plot(tmp_a)
%                 ylabel(t)
%                 if count==1
%                     title(num2str(quadrant_value))
%                 end
%                 set(gca,'xtick',1:4)
%                 %             disp(1)
%                 clear tmp_o tmp_t tmp_a max_v
%             end
%             clear q_o quadrant_loc
%         end
        
    end
end