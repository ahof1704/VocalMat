clc
clear
close all

fc = 450450;
to_do = 3;

scale_size = 14;%size of ruler for scale calibration
video_fname_prefix = 'Test_D_1';
date_st_1 = '06052012';
data_set = sprintf('%s_%s',date_st_1,video_fname_prefix);
min_seg_time = 5;%ms
subplot_options.on_off = 'on';
subplot_options.num_rows = 4;
subplot_options.num_cols = 2;
subplot_options.vis = 'off';
% load('U:\Matlab\progs\v33_multiple_mice_cleaned_up\r_est_raw_for_06052012_D_voc_frame_chunk_DA3_pdfs.mat')
% load('A:\Neunuebel\ssl_sys_test\sys_test_06052012\Data_analysis3\Test_D_1_Mouse.mat')
part1 = 'A:\Neunuebel\ssl_sys_test\sys_test_06052012\';
folder1 = 'Data_analysis8\';
folder2 = 'demux\';
dir1 = sprintf('%s%s',part1,folder1);
dir2 = part1;
dir3 = sprintf('%s%s',part1,folder2);

load('U:\Matlab\progs\v33_multiple_mice_cleaned_up\r_est_raw_for_06052012_D_voc_5ms_chunk_DA8_pdfs.mat')
cd (dir1)
load('Test_D_1_Mouse.mat')

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
%%
%%%%%%%%%%%%%%%%%%%%%%%cage corner positions
strSeekFilename = [dir1,video_fname_prefix,'_RMS_signal_amp.mat'];
if ~exist(strSeekFilename,'file') %check if exist
    signal = zeros(1,size(mouse,2));
    cd (dir3)
    for i=1:size(mouse,2)
        voc_num = char(mouse(i).syl_name);
        pos1 = strfind(voc_num,'_');
        char_value = str2num(sprintf('%d',voc_num(pos1+1:end)));
        if char_value == 48;
            signal(1:4,i) = NaN;
        else
            start_ts = mouse(i).start_sample_fine;
            stop_ts = mouse(i).stop_sample_fine;
            hf = mouse(i).hf_fine;
            lf = mouse(i).lf_fine;
            foo = start_ts:stop_ts;
            if lf>hf
                tmp = lf;
                hf = lf;
                lf = tmp;
                clear tmp
            end
            tmp_sig = zeros(4,size(foo,2));
            for ch_num = 1:4
                filename_prefix1 = sprintf('%s.ch%d',video_fname_prefix,ch_num);
                fid = fopen(filename_prefix1,'r');
                fseek(fid, start_ts*4, -1);
                tmp_sig(ch_num,:) = fread(fid,size(foo,2),'float32');
                fclose(fid);
                signal(ch_num,i) = calculate_channel_rms2(tmp_sig(ch_num,:), hf, lf, fc);
                clear filename_prefix1 fid
            end
            clear tmp_sig foo lf hf start_ts stop_ts
        end
        clear voc_num pos1 char_value
    end
else
    cd (dir1);
    load('Test_D_1_RMS_signal_amp.mat')
end
clear strSeekFilename
%% asigns name
r_est = [r_est_blob_per_voc_per_trial{1,1}.r_est];
r_head = [r_est_blob_per_voc_per_trial{1,1}.r_head];
r_tail = [r_est_blob_per_voc_per_trial{1,1}.r_tail];
i_syl = [r_est_blob_per_voc_per_trial{1,1}.i_syl];
%%
error = fn_calculate_distance3( r_head, r_est);
%%
index = [mouse.index];
start_ts = [mouse.start_sample_fine];
stop_ts = [mouse.stop_sample_fine];
dur = (stop_ts-start_ts)/fc;
dur = dur*1000; %ms

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
pos_x_mat = head_error;
pos_y_mat = head_error;
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
    head_error(mouse(i).index,col) = error(1,i);
    dur_mat(mouse(i).index,col) = dur(1,i);
    pos_x_mat(mouse(i).index,col) = r_head(1,i);
    pos_y_mat(mouse(i).index,col) = r_head(2,i);
    r_est_x_mat(mouse(i).index,col) = r_est(1,i);
    r_est_y_mat(mouse(i).index,col) = r_est(2,i);
    %      num{i} = regexprep(fileName{i},'[^\d]*','');
end
%%
% figure('color','w')
% tmp_dur = dur(color_loc);
% tmp_error = error(color_loc);
% short = find(dur<min_seg_time);
% signal(:,short) = NaN;
% step_size = 100;
% for i = 1:size(signal,1)+1
%     if i<=size(signal,1)
%         locs = isnan(signal(i,:))==0;
% %         tmp_signal = log(signal(i,locs));
% %         xlabel_s = sprintf('Log Signal Amplitude ch%d (rms)',i);
%         tmp_signal = (signal(i,locs));
%         xlabel_s = sprintf('Signal Amplitude ch%d (rms)',i);
%     else
%         tmp = min(signal,[],1);
%         locs = isnan(tmp(1,:))==0;
% %         tmp_signal = log(tmp(1,locs));
% %         xlabel_s = 'Log Signal Amplitude Smallest Ch (rms)';
%         tmp_signal = (tmp(1,locs));
%         xlabel_s = 'Signal Amplitude Smallest Ch (rms)';
%     end
% %     tmp_error = log(error(locs));
% %     ylabel_s = 'Log Error (m)';
%     tmp_error = (error(locs));
%     ylabel_s = 'Error (m)';
%
%     x2 = linspace(min(tmp_error), max(tmp_error),step_size);
%     y2 = linspace(min(tmp_signal), max(tmp_signal),step_size);
%     nbins = [size(x2,2),size(y2,2)];
%
%     data = [tmp_signal' tmp_error'];
%     figure('color','w')
%     hold on
%     n = hist3(data,nbins);
%     n1 = n';
%     n1( size(n,1) + 1 ,size(n,2) + 1 ) = 0;
%     xb = linspace(min(data(:,1)),max(data(:,1)),size(n,1)+1);
%     yb = linspace(min(data(:,2)),max(data(:,2)),size(n,1)+1);
%     imagesc(xb,yb,n1)
%     colormap(jet(254))
%     xlim([xb(1) xb(end)])
%     ylim([yb(1) yb(end)])
% %     hl1 = line([min_seg_time min_seg_time],[0 0.9]);
% %     hl2 = line([7 7],[0 0.9]);
%     colorbar
%     xlabel(xlabel_s)
%     ylabel(ylabel_s)
%     title('06052012-D-solo male')
% %     set(hl1,'color','r','linestyle','-','linewidth',3)
% %     set(hl2,'color','r','linestyle',':','linewidth',3)
%     disp(1)
%
% end
%%
% checking to see if correlation in data to determine if each chunk is independent
if to_do <= 1
    for i = 1:size(r_est_x_mat,1)
        r_est_x_tmp =  r_est_x_mat(i,:);
        r_est_y_tmp = r_est_y_mat(i,:);
        small = fn_find_short_chunks(min_seg_time,dur_mat,i);
        r_est_x_tmp(1,small) = NaN;
        r_est_y_tmp(1,small) = NaN;
        locs = isnan(r_est_x_tmp)==0;
        X_tmp = r_est_x_tmp(1,locs);
        Y_tmp = r_est_y_tmp(1,locs);
        if i == 1
            Xs = X_tmp(2:end-1);
            Xsplus = X_tmp(3:end);
            Ys = Y_tmp(2:end-1);
            Ysplus = Y_tmp(3:end);
        else
            Xs = cat(2,Xs,X_tmp(2:end-1));
            Xsplus = cat(2,Xsplus,X_tmp(3:end));
            Ys = cat(2,Ys,Y_tmp(2:end-1));
            Ysplus = cat(2,Ysplus,Y_tmp(3:end));
        end
        clear X_tmp Y_tmp locs
    end
    figure
    scatter(Xs,Xsplus,'filled')
    xlabel('R EST X n')
    ylabel('R EST X n+1')
    x_corr = corr(Xs',Xsplus');
    title(x_corr)
    figure
    scatter(Ys,Ysplus,'filled')
    xlabel('R EST Y n')
    ylabel('R EST Y n+1')
    y_corr = corr(Ys',Ysplus');
    title(y_corr)
end
%%
%diff in whole vs. chunk error
if to_do<=2
    step_size = 0.05;
    tmp = head_error;
    for i = 1:size(tmp,2)
        tmp2 = dur_mat(:,i);
        short = find(tmp2<min_seg_time);
        tmp(short,i) = NaN;
        clear short tmp2
    end
    for i = 2:size(tmp,2)
        diff_wv_chunk = tmp(:,1)-tmp(:,i);
        %         figure
        %         hist(diff_wv_chunk,min(diff_wv_chunk):step_size:max(diff_wv_chunk))
        %         title(i)
        if i == 2
            all_diff_wv_chunk =diff_wv_chunk;
        else
            all_diff_wv_chunk = cat(1,all_diff_wv_chunk,diff_wv_chunk);
        end
    end
    figure
    hist(all_diff_wv_chunk,min(all_diff_wv_chunk):step_size:max(all_diff_wv_chunk))
    title('All')
    locs = find(isnan(all_diff_wv_chunk)==0);
    median_all_diff_wv_chunk = median(all_diff_wv_chunk(locs));
    max_y = max(get(gca,'ylim'));
    hold on
    plot([median_all_diff_wv_chunk median_all_diff_wv_chunk],[0 max_y],'r')
    min_x = min(get(gca,'xlim'));
    xlim([min_x abs(min_x)])
    clear locs
end
close all
%%
%sets up tmp data
clear tmp1 tmp2 tmp3 tmp4 tmp5
tmp1 = dur_mat(:,2:end);
tmp2 = pos_x_mat(:,2:end);
tmp3 = pos_y_mat(:,2:end);
tmp4 = r_est_x_mat(:,2:end);
tmp5 = r_est_y_mat(:,2:end);
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
num_virtual_mice = 3;
odd_voc_count = 0;

odd_voc = 'n';
if to_do<=3
    for i = 1:size(head_error,1)
        %gets all data from single segment
        pos_x_tmp = tmp2(i,:);
        pos_y_tmp = tmp3(i,:);
        r_est_x_tmp = tmp4(i,:);
        r_est_y_tmp = tmp5(i,:);
        
        %finds and removes small chunks at i from tmp1 -  whole voc ssl
        %estimate removed
        small = fn_find_short_chunks(min_seg_time,tmp1,i);
        pos_x_tmp(1,small) = NaN;
        pos_y_tmp(1,small) = NaN;
        r_est_x_tmp(1,small) = NaN;
        r_est_y_tmp(1,small) = NaN;
        
        %removes NaN;
        locs = isnan(r_est_x_tmp)==0;
        X = r_est_x_tmp(1,locs);
        Y = r_est_y_tmp(1,locs);
        if size(X,2)>1
            if max(diff(X))==0 && max(diff(Y))==0
                odd_voc = 'y';
            end
        end
        Pos_X = pos_x_tmp(1,locs);
        Pos_Y = pos_y_tmp(1,locs);
        
        coords_chunks = cat(1,X,Y);
        coords_mouse = cat(1,Pos_X,Pos_Y);
        
        for vm = 1:num_virtual_mice
            rc = fn_random_select_cords3( range_x, range_y, scale_factor);
            coords_mouse2(i).pos(vm+1,:) = rc;
            clear rc
        end
        if strcmp(odd_voc,'n')==1
            if size(coords_chunks,2)>3
                [idx,dm,mm,C] = kur_rce(coords_chunks',0);
                outliers_k = find(idx==1);
                centroid_chunks(i,:) = mm';
                
                [ small_distance small_distance_loc ] = fn_smallest_error( centroid_chunks,i,coords_mouse );
                coords_mouse2(i).pos(1,:) = coords_mouse(:,small_distance_loc);
                
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
                    [ small_distance small_distance_loc ] = fn_smallest_error( centroid_chunks,i,coords_mouse );
                    coords_mouse2(i).pos(1,:) = coords_mouse(:,small_distance_loc);
                    p(i).p_values = NaN;
                    outliers_k = [];
                    outliers(i).bad = NaN;
                    fn_plot_chunks(centroid_chunks, C, i, coords_mouse2,Pos_X,Pos_Y,Xrange,Yrange,Xrange_m,Yrange_m,corners_x,corners_y,X,Y,coords_chunks,outliers_k,p,'bad',subplot_options,data_set)
                else
                    [ small_distance small_distance_loc ] = fn_smallest_error( centroid_chunks,i,coords_mouse );
                    coords_mouse2(i).pos(1,:) = coords_mouse(:,small_distance_loc);
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
        clc
        clear pos_x_tmp pos_y_tmp r_est_x_tmp r_est_y_tmp locs X Y
        clear Pos_X Pos_Y coords_chunks coords_mouse small
        clear idx dm mm C outliers_k ppd small_distance small_distance_loc
        clear R err
    end
end


