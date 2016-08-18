function [ distance ] = fn_calculate_distance2( point1, point2)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
x_dist = (point1(1)-point2(1))^2;
y_dist = (point1(2)-point2(2))^2;
distance = sqrt(x_dist+y_dist);

end

