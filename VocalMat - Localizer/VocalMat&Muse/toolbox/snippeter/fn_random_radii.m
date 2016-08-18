function [ range_r ] = fn_random_radii(radius, radius_step_size, meters_2_pixels)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

radius_pixels_h = floor((((radius)/1000)/meters_2_pixels)*10000);
radius_pixels_l = ceil((((radius-radius_step_size)/1000)/meters_2_pixels)*10000);
range_r = [radius_pixels_l,radius_pixels_h];
end

