function [ range_x, range_y ] = fn_range_x_y_cords( corners_out )
%fn_range_x_y_cords 
%
%   This function determines the range of possible x and y cords in the box
%   Lowest value in the range rounds the smallest pixel size up
%   Largest value in the range rounds the largest pixel size down
%
%   OUTPUT (range_x, range_y) are matrices with the largest and smallest x
%   and y coords in pixels.  Each matrix has two values.
%
%   Variables:
%   
%   Corners_out = the locations of the corners and has the following vars:
%       x_pix, y_pix, x_m, y_m, and z_m
    scale_factor = 10;
    for i = 1:4
        x_pos(i,1) = corners_out(i).x_pix;
        y_pos(i,1) = corners_out(i).y_pix;
    end
    x_pos = sort(x_pos);
    y_pos = sort(y_pos);
    xmax = floor(x_pos(end,1)*scale_factor);
    ymax = floor(y_pos(end,1)*scale_factor);
    xmin = ceil(x_pos(1,1)*scale_factor);
    ymin = ceil(y_pos(1,1)*scale_factor);
    range_x = [xmin,xmax];
    range_y = [ymin,ymax];

end

