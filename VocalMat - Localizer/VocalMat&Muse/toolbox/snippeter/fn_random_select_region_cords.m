function [ randomized_cords ] = fn_random_select_region_cords(cage_x, cage_y, i, randomized_cords,num_virtual_mice)
%fn_random_select_cords
%
%   function that randomly selects possible locations (x and y) in the box
%
%   OUTPUT 
%       1) randomized_cords is a matrix with all randomly generated cords  
%           1st column is the x cords for mouse 1 and 2nd column is the y  
%           cords for mouse 1 3rd column is the x cords for mouse 2 and 4th  
%           column is the y cords for mouse 2
%       2) foo is a signal randomization trial that will be stored in 
%           randomized_cords and used for determing mean diff between
%           position and TDOA
%
%   Variables
%       range_x = matrix with the largest and smallest x coords in pixels
%       range_y = matrix with the largest and smallest y coords in pixels
%       i = iteration number
%       randomized_cords = matrix with the previously generated random
%           cords
scale_factor = 10;
range_size = 200; %+ and -
for j = 1:2:(2*num_virtual_mice)-1
    
    tmp_x = (randomized_cords(i-1,j)*scale_factor);
    tmp_y = (randomized_cords(i-1,j+1)*scale_factor);
    range_x = [tmp_x-range_size,tmp_x+range_size];
    range_y = [tmp_y-range_size,tmp_y+range_size];
    x = (randi(range_x));
    while (x<=cage_x(1) || x>=cage_x(2))  
        x = (randi(range_x));
    end
    x = x/scale_factor;
    y = (randi(range_y));
    while (y<=cage_y(1) || y>=cage_y(2))  
        y = (randi(range_y));
    end    
    y = y/scale_factor;
    randomized_cords(i,j) = x;
    randomized_cords(i,j+1) = y;
    clear x y tmp_x tmp_y range_x range_y
end
end

