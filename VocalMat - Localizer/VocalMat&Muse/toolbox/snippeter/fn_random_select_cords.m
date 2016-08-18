function [ randomized_cords foo ] = fn_random_select_cords( range_x, range_y, i, randomized_cords)
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
for j = 1:2:3
    x = (randi(range_x)/scale_factor);
    y = (randi(range_y)/scale_factor);
    randomized_cords(i,j) = x;
    randomized_cords(i,j+1) = y;
    clear x y
end

foo(1,1).x_head = randomized_cords(i,1);
foo(1,1).y_head = randomized_cords(i,2);
foo(1,1).x_tail = NaN;
foo(1,1).y_tail = NaN;
foo(1,2).x_head = randomized_cords(i,3);
foo(1,2).y_head = randomized_cords(i,4);
foo(1,2).x_tail = NaN;
foo(1,2).y_tail = NaN;

end

