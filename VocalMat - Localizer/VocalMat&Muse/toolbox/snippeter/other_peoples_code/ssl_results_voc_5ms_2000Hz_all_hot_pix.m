clc
clear
% close all

fc = 450450;
num_mice = 1;
to_do = 1;

scale_size = 14;%size of ruler for scale calibration
video_fname_prefix = 'Test_D_1';
date_st_1 = '06052012';
data_set = sprintf('%s_%s',date_st_1,video_fname_prefix);
min_seg_time = 5;%ms
subplot_options.on_off = 'on';
subplot_options.num_rows = 4;
subplot_options.num_cols = 2;
subplot_options.vis = 'on';
% load('U:\Matlab\progs\v33_multiple_mice_cleaned_up\r_est_raw_for_06052012_D_voc_frame_chunk_DA3_pdfs.mat')
% load('A:\Neunuebel\ssl_sys_test\sys_test_06052012\Data_analysis3\Test_D_1_Mouse.mat')
part1 = 'A:\Neunuebel\ssl_sys_test\sys_test_06052012\';
folder1 = 'Data_analysis9\';
folder2 = 'demux\';
dir1 = sprintf('%s%s',part1,folder1);
dir2 = part1;
dir3 = sprintf('%s%s',part1,folder2);

load('U:\Matlab\progs\v33_multiple_mice_cleaned_up\r_est_for_06052012_D_Data_analysis9.mat')
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
pos_x_mat = head_error;
pos_y_mat = head_error;
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
        
        %     head_error(mouse(i).index,col) = error(1,i);
        dur_mat(mouse(count).index,col) = dur(1,count);
        hot_pix_mat(mouse(count).index,col) = hot_pix(1,count);
        r_est_x_mat(mouse(count).index,col) = r_est(1,count);
        r_est_y_mat(mouse(count).index,col) = r_est(2,count);
        head_error(mouse(count).index,col) = error(1,count);
        for j = 1:num_mice
            pos_x_mat(mouse(count).index,col,j) = r_head(1,count,j);
            pos_y_mat(mouse(count).index,col,j) = r_head(2,count,j);
        end
    end
end
disp(1)
%%
color_loc = find(color_list>1);
tmp_dur = dur(color_loc);
tmp_error = error(color_loc);
tmp_hot_pix = hot_pix(color_loc);

figure('color','w')
step_size = 100;
x2 = linspace(min(tmp_error), max(tmp_error),step_size);
y2 = linspace(min(tmp_hot_pix), max(tmp_hot_pix),step_size);
nbins = [size(x2,2),size(y2,2)];

data = [tmp_hot_pix' tmp_error'];
hold on
n = hist3(data,nbins);
n1 = n';
n1( size(n,1) + 1 ,size(n,2) + 1 ) = 0;
xb = linspace(min(data(:,1)),max(data(:,1)),size(n,1)+1);
yb = linspace(min(data(:,2)),max(data(:,2)),size(n,1)+1);
imagesc(xb,yb,n1)
colormap(jet)
xlim([xb(1) xb(end)])
ylim([yb(1) yb(end)])
hl1 = line([11 11],[0 0.9]);
% hl2 = line([15 15],[0 0.9]);
colorbar
xlabel('Number hot pixels')
ylabel('Error (m)')
title('06052012-D-solo male')
set(hl1,'color','r','linestyle','-','linewidth',2)
% set(hl2,'color','r','linestyle',':','linewidth',2)%%
% checking to see if correlation in data to determine if each chunk is independent


