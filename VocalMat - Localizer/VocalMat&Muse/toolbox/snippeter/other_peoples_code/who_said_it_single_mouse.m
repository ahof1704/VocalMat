clc
clear
close all

fc = 450450;

num_virtual_mice = 0;
num_mice = 2;

calculate_error = 'n';

to_do = 3;
chunk_start_num = 2;  %1 if whole segment was omitted or 2 if whole segment was localized
scale_size = 14;%size of ruler for scale calibration
% video_fname_prefix = 'Test_D_1';
video_fname_prefix = 'Merged_results_1';
% date_st_1 = '06052012';
% data_set = sprintf('%s_%s',date_st_1,video_fname_prefix);
data_set = video_fname_prefix;
min_seg_time = 5;%ms
subplot_options.on_off = 'on';
subplot_options.num_rows = 4;
subplot_options.num_cols = 2;
subplot_options.vis = 'off';

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
% %%
% %%%%%%%%%%%%%%%%%%%%%%%cage corner positions
% strSeekFilename = [dir1,video_fname_prefix,'_RMS_signal_amp.mat'];
% if ~exist(strSeekFilename,'file') %check if exist
%     signal = zeros(1,size(mouse,2));
%     cd (dir3)
%     for i=1:size(mouse,2)
%         voc_num = char(mouse(i).syl_name);
%         pos1 = strfind(voc_num,'_');
%         char_value = str2num(sprintf('%d',voc_num(pos1+1:end)));
%         if char_value == 48;
%             signal(1:4,i) = NaN;
%         else
%             start_ts = mouse(i).start_sample_fine;
%             stop_ts = mouse(i).stop_sample_fine;
%             hf = mouse(i).hf_fine;
%             lf = mouse(i).lf_fine;
%             foo = start_ts:stop_ts;
%             if lf>hf
%                 tmp = lf;
%                 hf = lf;
%                 lf = tmp;
%                 clear tmp
%             end
%             tmp_sig = zeros(4,size(foo,2));
%             for ch_num = 1:4
%                 filename_prefix1 = sprintf('%s.ch%d',video_fname_prefix,ch_num);
%                 fid = fopen(filename_prefix1,'r');
%                 fseek(fid, start_ts*4, -1);
%                 tmp_sig(ch_num,:) = fread(fid,size(foo,2),'float32');
%                 fclose(fid);
%                 signal(ch_num,i) = calculate_channel_rms2(tmp_sig(ch_num,:), hf, lf, fc);
%                 clear filename_prefix1 fid
%             end
%             clear tmp_sig foo lf hf start_ts stop_ts
%         end
%         clear voc_num pos1 char_value
%     end
% else
%     cd (dir1);
%     load('Test_D_1_RMS_signal_amp.mat')
% end
% clear strSeekFilename
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
%might want to remove outliers and track which chunks were removed
%(i.e., r_est estimates that were located outside of cage)


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
        
        voc_num{count,1} = char(i_syl{count});
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
% tmp2 = r_est_x_mat(:,2:end);
% tmp3 = r_est_y_mat(:,2:end);
% tmp4 = pos_x_mat(:,2:end,:);
% tmp5 = pos_y_mat(:,2:end,:);
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
area = nan(1,size(head_error,1));
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
        large_hot_pix = find(hot_pix_tmp<=11);
        pos_x_tmp(1,large_hot_pix,:) = NaN;
        pos_y_tmp(1,large_hot_pix,:) = NaN;
        r_est_x_tmp(1,large_hot_pix) = NaN;
        r_est_y_tmp(1,large_hot_pix) = NaN;
        hot_pix_tmp(1,large_hot_pix) = NaN;

        %removes NaN;
        locs = isnan(r_est_x_tmp)==0;
        X = r_est_x_tmp(1,locs);
        Y = r_est_y_tmp(1,locs);
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
                coords_mouse2(i).pos(vm+num_mice,:) = rc;
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
                    coords_mouse2(i).pos(mn,:) = coords_mouse(:,small_distance_loc(1,mn),mn);
                end
                
                ppd = mvnpdf(coords_mouse2(i).pos, centroid_chunks(i,:),C);
                p(i).p_values = ppd/sum(ppd);
                if isempty(outliers_k) == 0
                    outliers(i).bad = outliers_k;
                else
                    outliers(i).bad = NaN;
                end
                area(1,i) = fn_plot_chunks(centroid_chunks, C, i, coords_mouse2,Pos_X,Pos_Y,Xrange,Yrange,Xrange_m,Yrange_m,corners_x,corners_y,X,Y,coords_chunks,outliers_k,p,'good',subplot_options,data_set);
            elseif size(coords_chunks,2)>1 && size(coords_chunks,2)<=3
                centroid_chunks(i,1) = mean(X);
                centroid_chunks(i,2) = mean(Y);
                
                C = cov(X,Y);
                [R,err] = cholcov(C,0);
                if err>0 || any(eig(C) <=0)==1                 
                    odd_voc_count = odd_voc_count + 1;
                    odd_voc_list(odd_voc_count,1) = i;
                    odd_voc_list(odd_voc_count,2) = 1;
                    [ small_distance small_distance_loc ] = fn_smallest_error( centroid_chunks,i,coords_mouse );
                    coords_mouse2(i).pos(1,:) = coords_mouse(:,small_distance_loc);
                    p(i).p_values = NaN;
                    outliers_k = [];
                    outliers(i).bad = NaN;
                    area(1,i) = fn_plot_chunks(centroid_chunks, C, i, coords_mouse2,Pos_X,Pos_Y,Xrange,Yrange,Xrange_m,Yrange_m,corners_x,corners_y,X,Y,coords_chunks,outliers_k,p,'bad',subplot_options,data_set);
                else
                    [ small_distance small_distance_loc ] = fn_smallest_error( centroid_chunks,i,coords_mouse );
                    coords_mouse2(i).pos(1,:) = coords_mouse(:,small_distance_loc);
                    ppd = mvnpdf(coords_mouse2(i).pos, centroid_chunks(i,:),C);
                    p(i).p_values = ppd/sum(ppd);
                    outliers_k = [];
                    outliers(i).bad = NaN;
                    area(1,i) = fn_plot_chunks(centroid_chunks, C, i, coords_mouse2,Pos_X,Pos_Y,Xrange,Yrange,Xrange_m,Yrange_m,corners_x,corners_y,X,Y,coords_chunks,outliers_k,p,'good',subplot_options,data_set);
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
                area(1,i) = fn_plot_chunks(centroid_chunks, C, i, coords_mouse2,Pos_X,Pos_Y,Xrange,Yrange,Xrange_m,Yrange_m,corners_x,corners_y,X,Y,coords_chunks,outliers_k,p,'bad',subplot_options,data_set);
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
            area(1,i) = fn_plot_chunks(centroid_chunks, C, i, coords_mouse2,Pos_X,Pos_Y,Xrange,Yrange,Xrange_m,Yrange_m,corners_x,corners_y,X,Y,coords_chunks,outliers_k,p,'bad',subplot_options,data_set);
        end
        %         close all
        clc
        clear pos_x_tmp pos_y_tmp r_est_x_tmp r_est_y_tmp locs X Y
        clear Pos_X Pos_Y coords_chunks coords_mouse small
        clear idx dm mm C outliers_k ppd small_distance small_distance_loc
        clear R err
    end
end
cd (dir1)
save('Results_who_said_it_single_mouse.mat','area','odd_voc_list','outliers','p')

