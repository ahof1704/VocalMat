clc
clear
close all

fc = 450450;
to_do = 3;

scale_size = 14;%size of ruler for scale calibration
% video_fname_prefix = 'Test_D_1';
% date_st_1 = '06052012';
video_fname_prefix = 'Test_B_1';
date_st_1 = '10072012';
data_set = sprintf('%s_%s',date_st_1,video_fname_prefix);
min_seg_time = 5;%ms

num_virtual_mice = 0;
num_mice = 4;

subplot_options.on_off = 'on';
subplot_options.num_rows = 1;
subplot_options.num_cols = 2;
subplot_options.vis = 'on';
% load('U:\Matlab\progs\v33_multiple_mice_cleaned_up\r_est_raw_for_06052012_D_voc_frame_chunk_DA3_pdfs.mat')
% load('A:\Neunuebel\ssl_sys_test\sys_test_06052012\Data_analysis3\Test_D_1_Mouse.mat')
part1 = 'A:\Neunuebel\ssl_vocal_structure\';
folder0 = [date_st_1 '\'];
folder1 = 'Data_analysis7\';
folder2 = 'demux\';
dir1 = sprintf('%s%s',part1,folder0,folder1);
dir2 = [part1 folder0];
dir3 = sprintf('%s%s',part1,folder0,folder2);

% load('U:\Matlab\progs\v33_multiple_mice_cleaned_up\r_est_raw_for_06052012_D_voc_5ms_chunk_DA8_pdfs.mat')
load('U:\Matlab\progs\v33_multiple_mice_cleaned_up\r_est_for_10072012_B_Data_analysis7.mat')
cd (dir1)
load('Test_B_1_Mouse.mat')

%%%%%%%%%%%%%%%%%%%%%%%conversion factor
strSeekFilename = [dir2,'meters_2_pixels.mat'];
if ~exist(strSeekFilename,'file') %check if exist
    load_saved_conversion_factor = 'n';
else
    load_saved_conversion_factor = 'y';
end
clear strSeekFilename

scale_vfilename = sprintf('%s.seq',video_fname_prefix);
[meters_2_pixels handle1] = fn_scale_factor(dir2, scale_vfilename , scale_size, load_saved_conversion_factor);
close (handle1)

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
corners_x = [corners_out.x_m];
corners_x(1,end+1) = corners_x(1,1);
corners_y = [corners_out.y_m];
corners_y(1,end+1) = corners_y(1,1);

max_x = max(corners_x)+0.1;
max_y = max(corners_y)+0.1;
min_x = min(corners_x)-0.1;
min_y = min(corners_y)-0.1;

space_range_y =linspace(min_y,max_y,5);
space_range_x =linspace(min_x,max_x,5);

color_matrix = spatial_colormap;
%% asigns name
r_est = [r_est_blob_per_voc_per_trial{1,1}.r_est];
i_syl = [r_est_blob_per_voc_per_trial{1,1}.i_syl];
[r c] = size(r_est);
r_heads = [r_est_blob_per_voc_per_trial{1,1}.r_head];
r_tails = [r_est_blob_per_voc_per_trial{1,1}.r_tail];
rheads = zeros(r,c,4);
rtails = zeros(r,c,4);
for i = 1:num_mice
    m_locs = i:4:size(r_heads,2);
    tmp1 = r_heads(:,m_locs);
    tmp2 = r_tails(:,m_locs);
    rheads(:,:,i) = tmp1;
    rtails(:,:,i) = tmp2;
    clear tmp1 tmp2 m_locs
end
%%
% error = fn_calculate_distance3( r_head, r_est);
%%
index = [mouse.index];
start_ts = [mouse.start_sample_fine];
stop_ts = [mouse.stop_sample_fine];
dur = (stop_ts-start_ts)/fc;
dur = dur*1000; %ms

%%
%formating data matrices
[n, bin] = histc(index, unique(index));
multiple = find(n > 1);
loc_repeats  = find(ismember(bin, multiple));

uniqueX = unique(index);
countOfX = hist(index,uniqueX);
indexToRepeatedValue = (countOfX~=1);
repeatedValues = uniqueX(indexToRepeatedValue);
numberOfAppearancesOfRepeatedValues = countOfX(indexToRepeatedValue);

num_vocs = max(index);
max_num_chunks = max(numberOfAppearancesOfRepeatedValues);
head_error = nan(num_vocs,max_num_chunks);
pos_x_mat = nan(num_vocs,max_num_chunks,4); %mouse x pos; z = mouse number (1:num_mice)
pos_y_mat = nan(num_vocs,max_num_chunks,4); %mouse y pos; z = mouse number (1:num_mice)
r_est_x_mat = head_error;
r_est_y_mat = head_error;
dur_mat = head_error;
color_list = zeros(1,size(i_syl,2));

count = 0;
for i = 1:size(numberOfAppearancesOfRepeatedValues,2)
    for col = 1:numberOfAppearancesOfRepeatedValues(i)
        count = count + 1;
        voc_num{count,1} = char(i_syl{count});
        color_list(1,count) = col;
        
        %     head_error(mouse(i).index,col) = error(1,i);
        dur_mat(mouse(count).index,col) = dur(1,count);
        r_est_x_mat(mouse(count).index,col) = r_est(1,count);
        r_est_y_mat(mouse(count).index,col) = r_est(2,count);
        for j = 1:num_mice
            pos_x_mat(mouse(count).index,col,j) = rheads(1,count,j);
            pos_y_mat(mouse(count).index,col,j) = rheads(2,count,j);
        end
    end
end
%%
%sets up tmp data
clear tmp1 tmp2 tmp3 tmp4 tmp5
tmp1 = dur_mat(:,2:end);
tmp2 = r_est_x_mat(:,2:end);
tmp3 = r_est_y_mat(:,2:end);
tmp4 = pos_x_mat(:,2:end,:);
tmp5 = pos_y_mat(:,2:end,:);
% tmp6 = pos_x_mat2(:,2:end);
% tmp7 = pos_y_mat2(:,2:end);
% tmp8 = pos_x_mat3(:,2:end);
% tmp9 = pos_y_mat3(:,2:end);
% tmp10 = pos_x_mat4(:,2:end);
% tmp11 = pos_y_mat4(:,2:end);
% tmp6 = head_error(:,2:end);

%preallocate space for jackknife procedures
centroid_chunks = zeros(size(tmp1,1),2);
n = 50;
Xrange = linspace(min(corners_x),max(corners_x),n);
Yrange = linspace(min(corners_y),max(corners_y),n);
[Xrange_m,Yrange_m] = meshgrid(Xrange,Yrange);
scale_factor = 100;
range_x = [ceil(min(corners_x)*scale_factor),floor(max(corners_x)*scale_factor)];
range_y = [ceil(min(corners_y)*scale_factor),floor(max(corners_y)*scale_factor)];

odd_voc_count = 0;
odd_voc = 'n';
subplot_options.max_size = size(head_error,1);

var1 = subplot_options.on_off;
rows = subplot_options.num_rows;
cols = subplot_options.num_cols;
vis = subplot_options.vis;
max_size = subplot_options.max_size;

cd (dir1)
if to_do<=3
    for i = 1:size(head_error,1)
        %gets all data from single segment
        r_est_x_tmp = tmp2(i,:);
        r_est_y_tmp = tmp3(i,:);
        pos_x_tmp = tmp4(i,:,:);
        pos_y_tmp = tmp5(i,:,:);
        
        %finds and removes small chunks at i from tmp1 -  whole voc ssl
        %estimate removed
        small = fn_find_short_chunks(min_seg_time,tmp1,i);
        
        r_est_x_tmp(1,small) = NaN;
        r_est_y_tmp(1,small) = NaN;
        pos_x_tmp(1,small,:) = NaN;
        pos_y_tmp(1,small,:) = NaN;
        
        %removes NaN;
        locs = isnan(r_est_x_tmp)==0;
        X = r_est_x_tmp(1,locs);
        Y = r_est_y_tmp(1,locs);
        if size(X,2)>1
            if max(diff(X))==0 && max(diff(Y))==0
                odd_voc = 'y';
            end
        end
        Pos_X = pos_x_tmp(1,locs,:);
        Pos_Y = pos_y_tmp(1,locs,:);
        
        figure('color','w','Position',get(0,'screenSize'),'visible',vis)
        mos_locs = find(index==i);
        cd(dir3)
        start_point = mouse(1,mos_locs(1)).start_sample_fine;
        end_point = mouse(1,mos_locs(1)).stop_sample_fine;
        chunk_size = end_point-start_point;
        % samples_in_voc = end_point-start_point;
        signal = zeros(4,chunk_size);
        for ch_num = 1:4
            fname = [video_fname_prefix '.ch' num2str(ch_num)];
            fid = fopen(fname,'r');
            fseek(fid, start_point*4, -1);
            signal(ch_num,:) = fread(fid,chunk_size,'float32');
            fclose(fid);
        end
        merged_chs = sum(signal,1);
        subplot(subplot_options.num_rows,subplot_options.num_cols,2);
        r_specgram_mouse_mod(merged_chs,fc);
        ylim([.3e5 1.3e5])
        clim_val = get(gca,'clim');
        clim_val(2) = clim_val(2)/6;
        set(gca,'clim',clim_val)
        xlim_val = get(gca,'xlim');
        xlim_val(1) = 0;
        set(gca,'xlim',xlim_val)
        hold on
        clear signal signal2
        %             else
        %                 start_point_c = mouse(1,plot_spec).start_sample_fine;
        %                 end_point_c = mouse(1,plot_spec).stop_sample_fine;
        %                 tp_c = mean(start_point_c,end_point_c);
        %
        %             end
        disp(1)
        
        
        subplot(subplot_options.num_rows,subplot_options.num_cols,1);
        plot(corners_x,corners_y,'k')
        axis equal
        ylim([min(corners_y)*0.8 max(corners_y)*1.2])
        xlim([min(corners_x)*0.8 max(corners_x)*1.2])
        hold on
        
        for x_val = 2:size(space_range_x,2)
            x1 = space_range_x(1,x_val-1);
            x2 = space_range_x(1,x_val);
            poss_x = (X>=x1 & X<x2);
            for y_val = 2:size(space_range_y,2)
                y1 = space_range_y(1,y_val-1);
                y2 = space_range_y(1,y_val);
                poss_y = (Y>=y1 & Y<y2);
                comb_xy = poss_x + poss_y;
                locs2 = find(comb_xy == 2);                
                c_v = color_matrix{x_val-1,y_val-1};
                subplot(subplot_options.num_rows,subplot_options.num_cols,1);
                plot(X(1,locs2),Y(1,locs2),'ok',...
                    'MarkerFaceColor',c_v,...
                    'MarkerEdgeColor',c_v)
                %bugs 267-279
                locs3 = locs2+mos_locs(1);%not sure about this
                start_times_tmp = [mouse(locs3).start_sample_fine];
                stop_times_tmp = [mouse(locs3).start_sample_fine];
                freq_l_tmp = [mouse(locs3).lf_fine];
                freq_h_tmp = [mouse(locs3).hf_fine]+1;
                mean_time = (start_times_tmp+stop_times_tmp)./2;
                mean_freq = (freq_l_tmp+freq_h_tmp)./2;
                subplot(subplot_options.num_rows,subplot_options.num_cols,2);
                range_ts = ((mean_time-start_point)/fc)+(0.005/2);
                plot(range_ts,mean_freq,'ok',...
                    'MarkerFaceColor',c_v,...
                    'MarkerEdgeColor',c_v)
                clear locs2 start_times_tmp stop_times_tmp freq_h_tmp freq_l_tmp mean_time mean_freq range_ts locs3
            end
        end
        
        disp(1)
    end 
    count2 = 0;
    clc
    clear pos_x_tmp pos_y_tmp r_est_x_tmp r_est_y_tmp locs X Y
    clear Pos_X Pos_Y coords_chunks coords_mouse small
    clear idx dm mm C outliers_k ppd small_distance small_distance_loc
    clear R err
end



