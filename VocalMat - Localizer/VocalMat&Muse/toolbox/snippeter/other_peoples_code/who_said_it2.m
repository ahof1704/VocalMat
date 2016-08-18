%works with any number of real mice and virtual mice
clc
clear
close all

fc = 450450;

num_virtual_mice = 1;
num_mice = 2;

calculate_error = 'n';

to_do = 3;
chunk_start_num = 2;  %1 if whole segment was omitted or 2 if whole segment was localized
scale_size = 14;%size of ruler for scale calibration

%thresholds
min_seg_time = 5;%ms
hot_pix_threshold = 11;

%plot options
subplot_options.on_off = 'on';
subplot_options.num_rows = 4;
subplot_options.num_cols = 2;
subplot_options.vis = 'on';

% video_fname_prefix = 'Test_D_1';
video_fname_prefix = 'Merged_results_1';

% part1 = 'A:\Neunuebel\ssl_sys_test\sys_test_06052012\';
% folder1 = 'Data_analysis9\';

part1 = 'A:\Neunuebel\ssl_sys_test\merged_data\merged1\';
folder1 = 'Data_analysis2\';
folder2 = 'demux\';
dir1 = sprintf('%s%s',part1,folder1);
dir2 = part1;
dir3 = sprintf('%s%s',part1,folder2);

% load('U:\Matlab\progs\v33_multiple_mice_cleaned_up\r_est_for_06052012_D_Data_analysis9.mat')
load('A:\Neunuebel\ssl_sys_test\merged_data\merged1\Data_analysis2\r_est_for_Merged_results_1_Data_analysis2.mat')
cd (dir1)
% load('Test_D_1_Mouse.mat')
load('Merged_results_1_Mouse.mat')

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

count = 0;
for i = 1:size(numberOfAppearancesOfRepeatedValues,2)
    for col = 1:numberOfAppearancesOfRepeatedValues(i)
        count = count + 1;
        
        color_list(1,count) = col;
        dur_mat(mouse(count).index,col) = dur(1,count);
        hot_pix_mat(mouse(count).index,col) = hot_pix(1,count);
        r_est_x_mat(mouse(count).index,col) = r_est(1,count);
        r_est_y_mat(mouse(count).index,col) = r_est(2,count);
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

%preallocate space for jackknife procedures
centroid_chunks = nan(size(tmp1,1),2);
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
coords_mouse2 = nan(2,num_mice+num_virtual_mice,size(head_error,1));
p = nan(2,num_mice+num_virtual_mice,size(head_error,1));%top row = density bottom row = p value, columns = 1:mice number + virtual mice, z-stack = voc segment number
outliers = nan(max_num_chunks,num_vocs);
odd_voc_list = nan(2,num_vocs);
cd (dir1)
if to_do<=3
    for i = 1:size(head_error,1)
        %gets all data from single segment
        pos_x_tmp = pos_x_mat(i,chunk_start_num:end,:);
        pos_y_tmp = pos_y_mat(i,chunk_start_num:end,:);
        r_est_x_tmp = r_est_x_mat(i,chunk_start_num:end);
        r_est_y_tmp = r_est_y_mat(i,chunk_start_num:end);
        hot_pix_tmp = hot_pix_mat(i,chunk_start_num:end);
        
        %finds and removes small chunks at i from tmp1 -  whole voc ssl
        %estimate removed
        small = fn_find_short_chunks(min_seg_time,tmp1,i);
        pos_x_tmp(1,small,num_mice,:) = NaN;
        pos_y_tmp(1,small,num_mice,:) = NaN;
        r_est_x_tmp(1,small) = NaN;
        r_est_y_tmp(1,small) = NaN;
        hot_pix_tmp(1,small) = NaN;
        
        %finds and removes low hot pixels
        large_hot_pix = find(hot_pix_tmp<hot_pix_threshold);
        pos_x_tmp(1,large_hot_pix,:) = NaN;
        pos_y_tmp(1,large_hot_pix,:) = NaN;
        r_est_x_tmp(1,large_hot_pix) = NaN;
        r_est_y_tmp(1,large_hot_pix) = NaN;
        hot_pix_tmp(1,large_hot_pix) = NaN;
        
        %removes NaN;
        locs = isnan(r_est_x_tmp)==0;
        X = r_est_x_tmp(1,locs);
        Y = r_est_y_tmp(1,locs);
        if isempty(X)==0
            if size(X,2)>1
                if max(diff(X))==0 && max(diff(Y))==0
                    odd_voc = 'y';
                end
            end
            %X and Y positions of the mice
            Pos_X = pos_x_tmp(1,locs,:);
            Pos_Y = pos_y_tmp(1,locs,:);
            
            coords_chunks = cat(1,X,Y);
            coords_mouse = cat(1,Pos_X,Pos_Y);
            
            %Virtual mice
            if num_virtual_mice>0
                for vm = 1:num_virtual_mice
                    rc = fn_random_select_cords3( range_x, range_y, scale_factor);
                    coords_mouse2(:,vm+num_mice,i) = rc';
                    clear rc
                end
            end            
            
            if strcmp(odd_voc,'n')==1
                if size(coords_chunks,2)>3
                    [idx,dm,mm,C] = kur_rce(coords_chunks',0);
                    outliers_k = find(idx==1);
                    centroid_chunks(i,:) = mm';
                    
                    [ small_distance small_distance_loc ] = fn_smallest_error( centroid_chunks,i,coords_mouse );
                    for mn = 1:size(small_distance_loc,2)
                        coords_mouse2(:,mn,i) = coords_mouse(:,small_distance_loc(1,mn),mn);
                    end
                    
                    p(1,:,i) = mvnpdf(coords_mouse2(:,:,i)', centroid_chunks(i,:),C)';
                    p(2,:,i) = p(1,:,i)/sum(p(1,:,i));
                    if isempty(outliers_k) == 0
                        outliers(1:numel(outliers_k),i) = outliers_k;
                    end
                    area(1,i) = fn_plot_chunks(centroid_chunks, C, i, coords_mouse2,Pos_X,Pos_Y,Xrange,Yrange,Xrange_m,Yrange_m,corners_x,corners_y,X,Y,coords_chunks,outliers_k,p,'good',subplot_options,video_fname_prefix);
                elseif size(coords_chunks,2)>1 && size(coords_chunks,2)<=3
                    centroid_chunks(i,1) = mean(X);
                    centroid_chunks(i,2) = mean(Y);
                    
                    C = cov(X,Y);
                    [R,err] = cholcov(C,0);
                    if err>0 || any(eig(C) <=0)==1
                        odd_voc_list(1,i) = 1;
                        [ small_distance small_distance_loc ] = fn_smallest_error( centroid_chunks,i,coords_mouse );
                        for mn = 1:size(small_distance_loc,2)
                            coords_mouse2(:,mn,i) = coords_mouse(:,small_distance_loc(1,mn),mn);
                        end                       
                        outliers_k = [];
                        area(1,i) = fn_plot_chunks(centroid_chunks, C, i, coords_mouse2,Pos_X,Pos_Y,Xrange,Yrange,Xrange_m,Yrange_m,corners_x,corners_y,X,Y,coords_chunks,outliers_k,p,'bad',subplot_options,video_fname_prefix);
                    else
                        [ small_distance small_distance_loc ] = fn_smallest_error( centroid_chunks,i,coords_mouse );
                        for mn = 1:size(small_distance_loc,2)
                            coords_mouse2(:,mn,i) = coords_mouse(:,small_distance_loc(1,mn),mn);
                        end
                        p(1,:,i) = mvnpdf(coords_mouse2(:,:,i)', centroid_chunks(i,:),C)';
                        p(2,:,i) = p(1,:,i)/sum(p(1,:,i));
                        outliers_k = [];
                        area(1,i) = fn_plot_chunks(centroid_chunks, C, i, coords_mouse2,Pos_X,Pos_Y,Xrange,Yrange,Xrange_m,Yrange_m,corners_x,corners_y,X,Y,coords_chunks,outliers_k,p,'good',subplot_options,video_fname_prefix);
                    end                    
                else
                    odd_voc_list(1,i) = 2;
                    if isempty(coords_mouse)==0
                        [ small_distance small_distance_loc ] = fn_smallest_error( centroid_chunks,i,coords_mouse );
                        for mn = 1:size(small_distance_loc,2)
                            coords_mouse2(:,mn,i) = coords_mouse(:,small_distance_loc(1,mn),mn);
                        end
                    end                    
                    outliers_k = [];
                    C = NaN;
                    area(1,i) = fn_plot_chunks(centroid_chunks, C, i, coords_mouse2,Pos_X,Pos_Y,Xrange,Yrange,Xrange_m,Yrange_m,corners_x,corners_y,X,Y,coords_chunks,outliers_k,p,'bad',subplot_options,video_fname_prefix);
                end
            else
                odd_voc_list(1,i) = 3;
                odd_voc = 'n';
                [ small_distance small_distance_loc ] = fn_smallest_error( centroid_chunks,i,coords_mouse );
                for mn = 1:size(small_distance_loc,2)
                     coords_mouse2(:,mn,i) = coords_mouse(:,small_distance_loc(1,mn),mn);
                end
                outliers_k = [];
                C = NaN;
                area(1,i) = fn_plot_chunks(centroid_chunks, C, i, coords_mouse2,Pos_X,Pos_Y,Xrange,Yrange,Xrange_m,Yrange_m,corners_x,corners_y,X,Y,coords_chunks,outliers_k,p,'bad',subplot_options,video_fname_prefix);
            end
            %         close all
            clc
            clear pos_x_tmp pos_y_tmp r_est_x_tmp r_est_y_tmp locs X Y
            clear Pos_X Pos_Y coords_chunks coords_mouse small
            clear idx dm mm C outliers_k ppd small_distance small_distance_loc
            clear R err
        end        
        outliers_k = [];
        C = NaN;
    end
end
cd (dir1)
save('Results_who_said_it_single_mouse.mat','area','odd_voc_list','outliers','p')

