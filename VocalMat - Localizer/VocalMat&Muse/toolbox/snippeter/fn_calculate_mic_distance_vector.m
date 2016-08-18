function [ distance ] = fn_calculate_mic_distance_vector( x1, y1, x2, y2)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
x_dist = (x1-x2).*(x1-x2);
y_dist = (y1-y2).*(y1-y2);
distance = sqrtm(x_dist+y_dist);
disp(1);

end

