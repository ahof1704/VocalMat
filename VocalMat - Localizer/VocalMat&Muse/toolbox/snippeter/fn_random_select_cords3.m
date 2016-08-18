function [ randomized_cords ] = fn_random_select_cords3( range_x, range_y, scale_factor)
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


    randomized_cords(1) = (randi(range_x)/scale_factor);
    randomized_cords(2) = (randi(range_y)/scale_factor);

end

