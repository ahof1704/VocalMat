function [ cord_based_estimate, i_pos, j_pos, box_estimated_delta_t ] = fn_box_estimated_delta_t( range_x, range_y, positions_out, Vsound, meters_2_pixels)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%function [x3,y3,val_low,distance_m1,distance_m2] = fn_vocalization_colormap(dir2, dir3, range_x, range_y, imagefile_mice_prefix, syl_num, mouse, meters_2_pixels, Vsound, positions_out )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
scale_factor = 100;
cord_based_estimate = zeros(floor(range_y(2)/scale_factor),floor(range_x(2)/scale_factor));
cord_based_estimate(1:size(cord_based_estimate,1),1:size(cord_based_estimate,2))=NaN;
count = 0;
size_x = ceil(range_x(1)/scale_factor):floor(range_x(2)/scale_factor);
size_y = ceil(range_y(1)/scale_factor):floor(range_y(2)/scale_factor);
pre_all_size = size(size_x,2)*size(size_y,2);
i_pos = zeros(pre_all_size,1);
j_pos = zeros(pre_all_size,1);
box_estimated_delta_t = zeros(pre_all_size,6);
for i = ceil(range_x(1)/scale_factor):floor(range_x(2)/scale_factor)
    for j = ceil(range_y(1)/scale_factor):floor(range_y(2)/scale_factor)
        count = count + 1;
        foo(1,1).x_head = i;
        foo(1,1).y_head = j;
        foo(1,2).x_head = i;
        foo(1,2).y_head = j;
        estimated_delta_t = fn_equations( positions_out, Vsound, foo, meters_2_pixels);
        i_pos(count,1) = i;
        j_pos(count,1) = j;
        box_estimated_delta_t(count,:) = estimated_delta_t(1,:);
        clear estimated_delta_t random_mean_mice foo
    end
end
end

