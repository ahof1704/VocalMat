function [ distance ] = fn_calculate_distance( x, y, point)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
x_dist = (x-point(1))^2;
y_dist = (y-point(2))^2;
distance = sqrt(x_dist+y_dist);

end

