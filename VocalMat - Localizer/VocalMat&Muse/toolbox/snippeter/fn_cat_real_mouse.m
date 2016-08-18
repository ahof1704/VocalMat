function [ rc_cat ] =  fn_cat_real_mouse(mm,num_mice,coords_mouse)
%Function that concatenates real mouse position data
%  -finds coordinates for each real mouse that are closest to the mean x 
%   and mean y of every 5ms chunk related to the segment 
%Input:
%  num_mice = number of real mice in experimental recording
%  mm = mean x and mean y (cm)
%  coords_mouse = coordinates for each mouse a each 5 ms chunk 
%
%Output:
%  rc_cat = concatenated structure with real mouse head position


[ small_distance small_distance_loc ] = fn_smallest_error2(mm', num_mice, coords_mouse);
if num_mice == 1;
    rc_cat = coords_mouse(:,small_distance_loc(1,1),1);
end
if num_mice == 2;
    rc_tmp1 = coords_mouse(:,small_distance_loc(1,1),1);
    rc_tmp2 = coords_mouse(:,small_distance_loc(1,2),2);
    rc_cat = cat(2,rc_tmp1,rc_tmp2);
end
if num_mice == 3;
    rc_tmp1 = coords_mouse(:,small_distance_loc(1,1),1);
    rc_tmp2 = coords_mouse(:,small_distance_loc(1,2),2);
    rc_tmp3 = coords_mouse(:,small_distance_loc(1,3),3);
    rc_cat = cat(2,rc_tmp1,rc_tmp2,rc_tmp3);
end
if num_mice == 4;
    rc_tmp1 = coords_mouse(:,small_distance_loc(1,1),1);
    rc_tmp2 = coords_mouse(:,small_distance_loc(1,2),2);
    rc_tmp3 = coords_mouse(:,small_distance_loc(1,3),3);
    rc_tmp4 = coords_mouse(:,small_distance_loc(1,4),4);
    rc_cat = cat(2,rc_tmp1,rc_tmp2,rc_tmp3,rc_tmp4);
end

end

