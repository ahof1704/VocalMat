function [ distance ] = fn_calculate_mic_distance( x1, y1, x2, y2)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
x_dist = (x1-x2)^2;
y_dist = (y1-y2)^2;
distance = sqrt(x_dist+y_dist);

end

