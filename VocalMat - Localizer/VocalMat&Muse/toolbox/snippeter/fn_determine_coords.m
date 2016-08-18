function [coords_chunks,coords_mouse,delete_locs,odd_voc] = fn_determine_coords(par_loop_number,num_mice,chunk_start_num,MUSE_index,dur,hot_pix,r_est,r_head,min_seg_time,hot_pix_threshold)
%for each segment will retrieve the coordinates of each 5ms chunk and
%and mouse position at corresponding 5 ms chunk  
%data points are included above a minumum time and hot pixel intensity
%
%Input:
%  dur = duration of all 5 ms chunks
%  hot_pix = number of freq_contour points in corresponding 5 ms and 2000
%    hz window
%  r_est = sound source estimate for each 5 ms 2000 hz chunk (muse output)
%  r_head = position of mouse during each 5 ms 2000 hz chunk (muse output)
%  min_seg_tim = threshold of min segment
%  hot_pixel_threshold = minimum number of points in bin that allows
%  accurate localization
%
%Output:
%  coords_chunks
%  coords_mouse

idx = find(MUSE_index==par_loop_number);
idx = idx(chunk_start_num:end);

dur_this = dur(:,idx);

hot_pix_this = hot_pix(:,idx);
coords_chunks = r_est(:,idx); %x and y ssl estimates for all chunks associated with vocal segment i

if num_mice == 1
    tmp1 = r_head(:,num_mice*(idx)-(num_mice-1));
    coords_mouse = cat(3,tmp1);
end

if num_mice == 2
    tmp1 = r_head(:,num_mice*(idx)-1);
    tmp2 = r_head(:,num_mice*(idx));
    coords_mouse = cat(3,tmp1,tmp2);
end

if num_mice == 4
    tmp1 = r_head(:,num_mice*(idx)-(num_mice-1));
    tmp2 = r_head(:,num_mice*(idx)-(num_mice-2));
    tmp3 = r_head(:,num_mice*(idx)-(num_mice-3));
    tmp4 = r_head(:,num_mice*(idx)-(num_mice-4));
    coords_mouse = cat(3,tmp1,tmp2,tmp3,tmp4);
end

%deletes all repeated values and flags voc number
x_diff = diff(coords_chunks(1,:));
y_diff = diff(coords_chunks(2,:));

if sum(x_diff) == 0 || sum(y_diff) == 0
    odd_voc = 1;
    coords_chunks(:,:) = NaN;
    coords_mouse(:,:,:) = NaN;
else
    odd_voc = 0;
end
same_x = x_diff==0;
same_y = y_diff==0;
sum_x_y_same = same_x+same_y;
delete_locs = find(sum_x_y_same==2)+1;
coords_chunks(:,delete_locs) = NaN;
coords_mouse(:,delete_locs,:) = NaN;
hot_pix_this(1,delete_locs) = NaN;

%finds and removes small chunks from dur_this
small = fn_find_short_chunks(min_seg_time,dur_this,1);
coords_chunks(:,small) = NaN;
coords_mouse(:,small,:) = NaN;
hot_pix_this(1,small) = NaN;

%finds and removes low hot pixels
large_hot_pix = find(hot_pix_this<hot_pix_threshold);
coords_chunks(:,large_hot_pix) = NaN;
coords_mouse(:,large_hot_pix,:) = NaN;

%removes NaN;
locs = find(isnan(coords_chunks(1,:))==1);
coords_chunks(:,locs) = [];
coords_mouse(:,locs,:) = [];

end

