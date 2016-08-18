function [ distance ] = fn_calculate_distance3( matrix1, matrix2)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
% x_dist = (point1(1)-point2(1))^2;
% y_dist = (point1(2)-point2(2))^2;

x_dist = matrix1(1,:)-matrix2(1,:);
y_dist = matrix1(2,:)-matrix2(2,:);
x_dist2 = times(x_dist,x_dist);
y_dist2 = times(y_dist,y_dist);
sum_xy = y_dist2+x_dist2;
distance = sqrt(sum_xy);

end

