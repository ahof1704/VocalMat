function [ randomized_cords_r foo ] = fn_random_select_cords_radius( range_r, theta, i, x, y, randomized_cords_r)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    
    r = (randi(range_r)/10000);
    t = randi(theta);
    random_x = x + r*cos(t);
    random_y = y + r*sin(t);
    randomized_cords_r(i,1) = random_x;
    randomized_cords_r(i,2) = random_y;
    
    foo(1,1).x = randomized_cords_r(i,1);
    foo(1,1).y = randomized_cords_r(i,2);
    
end

