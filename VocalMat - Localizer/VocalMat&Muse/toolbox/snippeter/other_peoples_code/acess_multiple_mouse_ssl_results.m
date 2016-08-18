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

num_virtual_mice = 3;
num_mice = 4;

subplot_options.on_off = 'on';
subplot_options.num_rows = 4;
subplot_options.num_cols = 2;
subplot_options.vis = 'on';
% load('U:\Matlab\progs\v33_multiple_mice_cleaned_up\r_est_raw_for_06052012_D_voc_frame_chunk_DA3_pdfs.mat')
% load('A:\Neunuebel\ssl_sys_test\sys_test_06052012\Data_analysis3\Test_D_1_Mouse.mat')
part1 = 'A:\Neunuebel\ssl_vocal_structure\';
folder0 = [date_st_1 '\'];
folder1 = 'Data_analysis5\';
folder2 = 'demux\';
dir1 = sprintf('%s%s',part1,folder0,folder1);
dir2 = [part1 folder0];
dir3 = sprintf('%s%s',part1,folder0,folder2);

% load('U:\Matlab\progs\v33_multiple_mice_cleaned_up\r_est_raw_for_06052012_D_voc_5ms_chunk_DA8_pdfs.mat')
load('U:\Matlab\progs\v33_multiple_mice_cleaned_up\r_est_for_10072012_B_Data_analysis5.mat')
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

for i = 1:size(i_syl,2)
    voc_num = char(i_syl{i});
    pos1 = strfind(voc_num,'_');
    char_value = str2num(sprintf('%d',voc_num(pos1+1:end)));
    if char_value == 48;
        col = 1;
    else
        col = char_value - 95;
    end
    %     color_list{1,i} = color_v;
    color_list(1,i) = col;
    %     head_error(mouse(i).index,col) = error(1,i);
    dur_mat(mouse(i).index,col) = dur(1,i);
    r_est_x_mat(mouse(i).index,col) = r_est(1,i);
    r_est_y_mat(mouse(i).index,col) = r_est(2,i);
    for j = 1:num_mice
        pos_x_mat(mouse(i).index,col,j) = rheads(1,i,j);
        pos_y_mat(mouse(i).index,col,j) = rheads(2,i,j);        
    end
    %      num{i} = regexprep(fileName{i},'[^\d]*','');
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
        
        coords_chunks = cat(1,X,Y);
        coords_mouse = cat(1,Pos_X,Pos_Y);
        
        if num_mice < 4
            for vm = 1:num_virtual_mice
                rc = fn_random_select_cords3( range_x, range_y, scale_factor);
                coords_mouse2(i).pos(vm+1,:) = rc;
                clear rc
            end
        end
        
        if strcmp(odd_voc,'n')==1
            if size(coords_chunks,2)>3
                [idx,dm,mm,C] = kur_rce(coords_chunks',0);
                outliers_k = find(idx==1);
                centroid_chunks(i,:) = mm';
                
                for j = 1:num_mice
                    [ small_distance small_distance_loc ] = fn_smallest_error( centroid_chunks,i,coords_mouse(:,:,j) );
                    coords_mouse2(i).pos(j,:) = coords_mouse(:,small_distance_loc,j);
                end
                ppd = mvnpdf(coords_mouse2(i).pos, centroid_chunks(i,:),C);
                p(i).p_values = ppd/sum(ppd);
                if isempty(outliers_k) == 0
                    outliers(i).bad = outliers_k;
                else
                    outliers(i).bad = NaN;
                end
                fn_plot_chunks(centroid_chunks, C, i, coords_mouse2,Pos_X,Pos_Y,Xrange,Yrange,Xrange_m,Yrange_m,corners_x,corners_y,X,Y,coords_chunks,outliers_k,p,'good',subplot_options,data_set);
            elseif size(coords_chunks,2)>1 && size(coords_chunks,2)<=3
                centroid_chunks(i,1) = mean(X);
                centroid_chunks(i,2) = mean(Y);
                
                C = cov(X,Y);
                [R,err] = cholcov(C,0);
                if err>0 || any(eig(C) <=0)==1                 
                    odd_voc_count = odd_voc_count + 1;
                    odd_voc_list(odd_voc_count,1) = i;
                    odd_voc_list(odd_voc_count,2) = 1;
                    for j = 1:num_mice
                        [ small_distance small_distance_loc ] = fn_smallest_error( centroid_chunks,i,coords_mouse(:,:,j) );
                        coords_mouse2(i).pos(j,:) = coords_mouse(:,small_distance_loc,j);
                    end
                    p(i).p_values = NaN;
                    outliers_k = [];
                    outliers(i).bad = NaN;
                    fn_plot_chunks(centroid_chunks, C, i, coords_mouse2,Pos_X,Pos_Y,Xrange,Yrange,Xrange_m,Yrange_m,corners_x,corners_y,X,Y,coords_chunks,outliers_k,p,'bad',subplot_options,data_set)
                else
                    [ small_distance small_distance_loc ] = fn_smallest_error( centroid_chunks,i,coords_mouse );
                    for j = 1:num_mice
                        [ small_distance small_distance_loc ] = fn_smallest_error( centroid_chunks,i,coords_mouse(:,:,j) );
                        coords_mouse2(i).pos(j,:) = coords_mouse(:,small_distance_loc,j);
                    end
                    ppd = mvnpdf(coords_mouse2(i).pos, centroid_chunks(i,:),C);
                    p(i).p_values = ppd/sum(ppd);
                    outliers_k = [];
                    outliers(i).bad = NaN;
                    fn_plot_chunks(centroid_chunks, C, i, coords_mouse2,Pos_X,Pos_Y,Xrange,Yrange,Xrange_m,Yrange_m,corners_x,corners_y,X,Y,coords_chunks,outliers_k,p,'good',subplot_options,data_set)
                end
%                 if err==0 && any(eig(C) >0)
%                     [ small_distance small_distance_loc ] = fn_smallest_error( centroid_chunks,i,coords_mouse );
%                     coords_mouse2(i).pos(1,:) = coords_mouse(:,small_distance_loc);
%                     ppd = mvnpdf(coords_mouse2(i).pos, centroid_chunks(i,:),C);
%                     p(i).p_values = ppd/sum(ppd);
%                     outliers_k = [];
%                     outliers(i).bad = NaN;
%                     fn_plot_chunks(centroid_chunks, C, i, coords_mouse2,Pos_X,Pos_Y,Xrange,Yrange,Xrange_m,Yrange_m,corners_x,corners_y,X,Y,coords_chunks,outliers_k,p,'good',subplot_options,data_set)
%                 else
%                     odd_voc_count = odd_voc_count + 1;
%                     odd_voc_list(odd_voc_count,1) = i;
%                     odd_voc_list(odd_voc_count,2) = 1;
%                     [ small_distance small_distance_loc ] = fn_smallest_error( centroid_chunks,i,coords_mouse );
%                     coords_mouse2(i).pos(1,:) = coords_mouse(:,small_distance_loc);
%                     p(i).p_values = NaN;
%                     outliers_k = [];
%                     outliers(i).bad = NaN;
%                     fn_plot_chunks(centroid_chunks, C, i, coords_mouse2,Pos_X,Pos_Y,Xrange,Yrange,Xrange_m,Yrange_m,corners_x,corners_y,X,Y,coords_chunks,outliers_k,p,'bad',subplot_options,data_set)
%                 end
                
            else
                odd_voc_count = odd_voc_count + 1;
                odd_voc_list(odd_voc_count,1) = i;
                odd_voc_list(odd_voc_count,2) = 2;
                centroid_chunks(i,:) = NaN;
                if isempty(coords_mouse)==0
                    [ small_distance small_distance_loc ] = fn_smallest_error( centroid_chunks,i,coords_mouse );
                    coords_mouse2(i).pos(1,:) = coords_mouse(:,small_distance_loc);
                else
                    coords_mouse2(i).pos(1,:) = NaN;
                end
                p(i).p_values = NaN;
                outliers_k = [];
                outliers(i).bad = NaN;
                C = NaN;
                fn_plot_chunks(centroid_chunks, C, i, coords_mouse2,Pos_X,Pos_Y,Xrange,Yrange,Xrange_m,Yrange_m,corners_x,corners_y,X,Y,coords_chunks,outliers_k,p,'bad',subplot_options,data_set)
            end
        else
            odd_voc_count = odd_voc_count + 1;
            odd_voc_list(odd_voc_count,1) = i;
            odd_voc_list(odd_voc_count,2) = 3;
            odd_voc = 'n';
            centroid_chunks(i,:) = NaN;
            [ small_distance small_distance_loc ] = fn_smallest_error( centroid_chunks,i,coords_mouse );
            coords_mouse2(i).pos(1,:) = coords_mouse(:,small_distance_loc);
            p(i).p_values = NaN;
            outliers_k = [];
            outliers(i).bad = NaN;
            C = NaN;
            fn_plot_chunks(centroid_chunks, C, i, coords_mouse2,Pos_X,Pos_Y,Xrange,Yrange,Xrange_m,Yrange_m,corners_x,corners_y,X,Y,coords_chunks,outliers_k,p,'bad',subplot_options,data_set)
        end
        %         close all
        %clc
        clear pos_x_tmp pos_y_tmp r_est_x_tmp r_est_y_tmp locs X Y
        clear Pos_X Pos_Y coords_chunks coords_mouse small
        clear idx dm mm C outliers_k ppd small_distance small_distance_loc
        clear R err
    end
end


