% part1 = 'A:\Neunuebel\ssl_vocal_structure\';
% folder0 = [date_st_1 '\'];
% folder1 = 'Data_analysis7\';
% folder2 = 'demux\';
% dir1 = sprintf('%s%s',part1,folder0,folder1);
% dir2 = [part1 folder0];
% dir3 = sprintf('%s%s',part1,folder0,folder2);
%works with any number of real mice and virtual mice
clc
clear
close all

fc = 450450;

num_virtual_mice = 0;
num_mice = 2;
elements = 35;

calculate_error = 'n';

to_do = 3;
chunk_start_num = 2;  %1 if whole segment was omitted or 2 if whole segment was localized
scale_size = 14;%size of ruler for scale calibration
color_values = [0 0 0;0 0.5 0;0.5 0 0.5;0 1 1];%mouse 1 = black, mouse 2 = green, mouse 3 = purple, mouse 4 = cyan

% video_fname_prefix = 'Test_D_1';
video_fname_prefix = 'Merged_results_1';
% date_st_1 = '06052012';
% data_set = sprintf('%s_%s',date_st_1,video_fname_prefix);
data_set = video_fname_prefix;
min_seg_time = 5;%ms
subplot_options.on_off = 'on';
subplot_options.num_rows = 1;
subplot_options.num_cols = 2;
subplot_options.vis = 'on';

% part1 = 'A:\Neunuebel\ssl_sys_test\sys_test_06052012\';
% folder1 = 'Data_analysis9\';

part1 = 'A:\Neunuebel\ssl_sys_test\merged_data\merged1\';
folder1 = 'Data_analysis2\';
folder2 = 'demux\';
folder3 = 'Spatial_segregation2\';
dir1 = sprintf('%s%s',part1,folder1);
dir2 = part1;
dir3 = sprintf('%s%s',part1,folder2);
dir4 = sprintf('%s%s%s',part1,folder1,folder3);

if isdir(dir4)==0
    mkdir(dir4)
end

% load('U:\Matlab\progs\v33_multiple_mice_cleaned_up\r_est_for_06052012_D_Data_analysis9.mat')
% load('Test_D_1_Mouse.mat')
cd (dir1)
load(sprintf('r_est_for_%s_%s.mat',video_fname_prefix,folder1(1:end-1)))
load(sprintf('%s_Mouse.mat',video_fname_prefix))
load('A:\Neunuebel\ssl_sys_test\merged_data\merged1\no_merge_Har\Merged_results_1-out20130405T172917\fc2.mat')
% load('A:\Neunuebel\ssl_sys_test\merged_data\merged1\no_merge_Har\Merged_results_1-out20130405T172917\manual_overlaps_info_Merged_results_1_no_merge_no_har.mat')
load('A:\Neunuebel\ssl_sys_test\merged_data\merged1\no_merge_Har\Merged_results_1-out20130405T172917\Results_Autocalculate_Overlap.mat')

index = [mouse.index];
num_vocs = max(index);
voc_list_used = nan(1,num_vocs);
for i = 1:num_vocs
    tmp = find(index==i);
    idx = tmp(1);
    voc_list_used(1,i) = str2double(mouse(idx).syl_name_old(4:end));
end
mouse_number = overlap_info(voc_list_used,2);
clear overlap_info
overlap_info = mouse_number;
clear mouse_number
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

space_range_y =linspace(min_y,max_y,elements);
space_range_x =linspace(min_x,max_x,elements);
% color_matrix = spatial_colormap;
color_matrix = fn_color_spectrum( elements, 0, 0 );
%% asigns name
r_est = [r_est_blob_per_voc_per_trial{1,1}.r_est];
r_head = [r_est_blob_per_voc_per_trial{1,1}.r_head];
r_tail = [r_est_blob_per_voc_per_trial{1,1}.r_tail];
i_syl = [r_est_blob_per_voc_per_trial{1,1}.i_syl];
%%
if strcmp(calculate_error,'y')==1
    error = fn_calculate_distance3( r_head, r_est);
end
%%
index = [mouse.index];
start_ts = [mouse.start_sample_fine];
stop_ts = [mouse.stop_sample_fine];
hf = [mouse.hf_fine];
lf = [mouse.lf_fine];
dur = (stop_ts-start_ts)/fc;
dur = dur*1000; %ms
hot_pix = [mouse.hot_pix];
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
pos_x_mat = nan(num_vocs,max_num_chunks,num_mice);
pos_y_mat = nan(num_vocs,max_num_chunks,num_mice);
r_est_x_mat = head_error;
r_est_y_mat = head_error;
dur_mat = head_error;
hot_pix_mat = head_error;
color_list = zeros(1,size(i_syl,2));
stop_mat = head_error;
count = 0;
for i = 1:size(numberOfAppearancesOfRepeatedValues,2)
    for col = 1:numberOfAppearancesOfRepeatedValues(i)
        count = count + 1;
        
        voc_num{count,1} = char(i_syl{count});
        color_list(1,count) = col;
        dur_mat(mouse(count).index,col) = dur(1,count);
        hot_pix_mat(mouse(count).index,col) = hot_pix(1,count);
        r_est_x_mat(mouse(count).index,col) = r_est(1,count);
        r_est_y_mat(mouse(count).index,col) = r_est(2,count);
        stop_mat(mouse(count).index,col) = stop_ts(1,count);
        if strcmp(calculate_error,'y')==1
            head_error(mouse(count).index,col) = error(1,count);
        end
        for j = 1:num_mice
            pos_x_mat(mouse(count).index,col,j) = r_head(1,num_mice*(count-1)+j);
            pos_y_mat(mouse(count).index,col,j) = r_head(2,num_mice*(count-1)+j);
            %             disp(pos_x_mat(mouse(count).index,col,j))
            %             disp(pos_y_mat(mouse(count).index,col,j))
        end
    end
end

%%
%sets up tmp data
clear tmp1 tmp2 tmp3 tmp4 tmp5
tmp1 = dur_mat(:,chunk_start_num:end);

%preallocate space
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
area = nan(1,size(head_error,1));
cd (dir1)
if to_do<=3
    for i = 1:size(head_error,1)
        %gets all data from single segment
        r_est_x_tmp = r_est_x_mat(i,chunk_start_num:end);
        r_est_y_tmp = r_est_y_mat(i,chunk_start_num:end);
        pos_x_tmp = pos_x_mat(i,chunk_start_num:end,:);
        pos_y_tmp = pos_y_mat(i,chunk_start_num:end,:);
        hot_pix_tmp = hot_pix_mat(i,chunk_start_num:end);
        
        %finds and removes small chunks at i from tmp1 -  whole voc ssl
        %estimate removed
        small = fn_find_short_chunks(min_seg_time,tmp1,i);
        r_est_x_tmp(1,small) = NaN;
        r_est_y_tmp(1,small) = NaN;
        pos_x_tmp(1,small,num_mice,:) = NaN;
        pos_y_tmp(1,small,num_mice,:) = NaN;
        hot_pix_tmp(1,small) = NaN;
        
        %finds and removes low hot pixels
        large_hot_pix = find(hot_pix_tmp<11);
        r_est_x_tmp(1,large_hot_pix) = NaN;
        r_est_y_tmp(1,large_hot_pix) = NaN;
        pos_x_tmp(1,large_hot_pix,:) = NaN;
        pos_y_tmp(1,large_hot_pix,:) = NaN;
        hot_pix_tmp(1,large_hot_pix) = NaN;
        
        %removes NaN;
        locs = isnan(r_est_x_tmp)==0;
        locs_hot = find(locs==1);
        X = r_est_x_tmp(1,locs);
        Y = r_est_y_tmp(1,locs);
        if size(X,2)>2
            if (all(X(1,:)==X(1,1)) && all(Y(1,:)==Y(1,1))) == 0
                figure('color','w','Position',[807 439 772 605],'visible',vis)
                mos_locs = find(index==i);
                tmp = mouse(mos_locs(1)).syl_name_old;
                tmp_voc_num = str2double(tmp(4:end));
                mos_locs2 = mos_locs(chunk_start_num:end);
                start_point = mouse(1,mos_locs(1)).start_sample_fine;
                %X and Y positions of the mice
                Pos_X = pos_x_tmp(1,locs,:);
                Pos_Y = pos_y_tmp(1,locs,:);
                
                for syl = 1:size(freq_contours2{1,tmp_voc_num},2)
                    b1 = freq_contours2{1,tmp_voc_num}{1,syl};
                    if syl == 1
                        ball = b1;
                    else
                        ball = cat(1,ball,b1);
                    end
                    clear b1
                end
                
                subplot(subplot_options.num_rows,subplot_options.num_cols,2);
                hold on
                scatter(ball(:,1)*450450,ball(:,2),'y','filled');
                subplot(subplot_options.num_rows,subplot_options.num_cols,1);
                plot(corners_x,corners_y,'k')
                axis equal
                ylim([min(corners_y)*0.8 max(corners_y)*1.2])
                xlim([min(corners_x)*0.8 max(corners_x)*1.2])
                hold on
                count2 = 0;
                for x_val = 2:size(space_range_x,2)
                    count2 = count2 + 1;
                    x1 = space_range_x(1,x_val-1);
                    x2 = space_range_x(1,x_val);
                    poss_x = (X>=x1 & X<x2);
                    for y_val = 2:size(space_range_y,2)
                        y1 = space_range_y(1,y_val-1);
                        y2 = space_range_y(1,y_val);
                        poss_y = (Y>=y1 & Y<y2);
                        comb_xy = poss_x + poss_y;
                        locs2 = find(comb_xy == 2);
                        if isempty(locs2)==0
                            
                            
                            c_v = color_matrix{x_val-1,y_val-1};
                            subplot(subplot_options.num_rows,subplot_options.num_cols,1);
                            plot(X(1,locs2),Y(1,locs2),'ok',...
                                'MarkerFaceColor',c_v,...
                                'MarkerEdgeColor',c_v)
                            for j = 1:num_mice
                                plot(Pos_X(:,:,j),Pos_Y(:,:,j),'s-',...
                                    'markerfacecolor',color_values(j,:),...
                                    'MarkerEdgeColor',color_values(j,:),...
                                    'MarkerSize',4)
                            end
                            clear rm
                            
                            rm = overlap_info(i,1);
                            if isnan(rm)==0
                                if rm == 3
                                    for rm = 1:2;
                                        plot(Pos_X(:,end,rm),Pos_Y(:,end,rm),'ok',...
                                            'MarkerEdgeColor',color_values(1,:),...
                                            'MarkerSize',10)
                                    end
                                else
                                    plot(Pos_X(:,end,rm),Pos_Y(:,end,rm),'ok',...
                                        'MarkerEdgeColor',color_values(1,:),...
                                        'MarkerSize',10)
                                end
                            end
                            
                            locs3 = locs_hot(locs2)+mos_locs(1);%not sure about this
                            if isempty(locs3)==0
                                %                         for k = locs3
                                start_times_tmp = start_ts(locs3);
                                stop_times_tmp = stop_ts(locs3);
                                freq_l_tmp = lf(locs3);
                                freq_h_tmp = hf(locs3);
                                subplot(subplot_options.num_rows,subplot_options.num_cols,2);
                                for fc_loop = 1:size(start_times_tmp,2)
                                    tmp_time = (ball(:,1)>(start_times_tmp(fc_loop)/fc) & ball(:,1)<(stop_times_tmp(fc_loop)/fc));
                                    tmp_frq = (ball(:,2)>freq_l_tmp(fc_loop) & ball(:,2)<freq_h_tmp(fc_loop));
                                    idx2_tmp = tmp_time+tmp_frq;
                                    idx2 = find(idx2_tmp==2);
                                    plot(ball(idx2,1)*450450,ball(idx2,2),'ok',...
                                        'MarkerFaceColor',c_v,...
                                        'MarkerEdgeColor',c_v)
                                end
                                mean_time = (start_times_tmp+stop_times_tmp)./2;
                                mean_freq = (freq_l_tmp+freq_h_tmp)./2;
                                subplot(subplot_options.num_rows,subplot_options.num_cols,2);
                                %                                                     range_ts = ((mean_time-start_point)/fc);%+(0.005/2);
                                plot(mean_time,mean_freq,'ok',...
                                    'MarkerFaceColor',c_v,...
                                    'MarkerEdgeColor',c_v)
                            end
                            clear locs2 start_times_tmp stop_times_tmp freq_h_tmp freq_l_tmp mean_time mean_freq range_ts locs3
                        end
                    end
                end
                
                subplot(subplot_options.num_rows,subplot_options.num_cols,1);
                title(sprintf('Voc segment %d Num vocal animals %d',i,overlap_info(i,1)))
                cd (dir4)
                fig_num = fn_numPad(i,4);
                saveas(gcf,sprintf('Voc_%s_spatial_segregation',fig_num),'jpg')
                close(gcf)
                clear ball
            end
        end
        
        
    end
    count2 = 0;
    clc
    clear pos_x_tmp pos_y_tmp r_est_x_tmp r_est_y_tmp locs X Y
    clear Pos_X Pos_Y coords_chunks coords_mouse small
    clear idx dm mm C outliers_k ppd small_distance small_distance_loc
    clear R err
end



