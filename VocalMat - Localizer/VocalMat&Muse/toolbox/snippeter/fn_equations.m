function [m] = fn_equations( positions_out, Vsound, mouse, meters_2_pixels)
%fn_equations
%   function calculates estimated time of delays based on the positions of
%   the mouse between different microphones 
%
%   OUTPUT (m) is the estimated time delays in seconds between pairs of 
%   microphones based on position of the mouse
%
%   For the following, i = mouse number
%   
%   m(i,1) = mic 1 vs mic2
%   m(i,2) = mic 1 vs mic3
%   m(i,3) = mic 1 vs mic4
%   m(i,4) = mic 2 vs mic3
%   m(i,5) = mic 2 vs mic4
%   m(i,6) = mic 3 vs mic4
%
%   Variables:
%
%   positions_out = positions of microphones (struct)
%   Vsound = velocity of sound (m/s)
%   mouse = position of mouse
%   meters_2_pixels = conversion factor
%   
%   **********************************************************************
%
%   NOTE:
%       we are assuming that the z position of the mouse is 0
%

m = zeros(size(mouse,2),6);
for i = 1:size(mouse,2)
    x = mouse(i).x_head*meters_2_pixels;
    y = mouse(i).y_head*meters_2_pixels;
    z = 0*meters_2_pixels;
    %estimated delay between mic 1 vs mic2
    m(i,1) = (sqrt((positions_out(1).x_m-x)^(2)+(positions_out(1).y_m-y)^(2)+(positions_out(1).z_m-z)^(2))-sqrt((positions_out(2).x_m-x)^(2)+(positions_out(2).y_m-y)^(2)+(positions_out(2).z_m-z)^(2)))/Vsound;
    %estimated delay between mic 1 vs mic3
    m(i,2) = (sqrt((positions_out(1).x_m-x)^(2)+(positions_out(1).y_m-y)^(2)+(positions_out(1).z_m-z)^(2))-sqrt((positions_out(3).x_m-x)^(2)+(positions_out(3).y_m-y)^(2)+(positions_out(3).z_m-z)^(2)))/Vsound;
    %estimated delay between mic 1 vs mic4
    m(i,3) = (sqrt((positions_out(1).x_m-x)^(2)+(positions_out(1).y_m-y)^(2)+(positions_out(1).z_m-z)^(2))-sqrt((positions_out(4).x_m-x)^(2)+(positions_out(4).y_m-y)^(2)+(positions_out(4).z_m-z)^(2)))/Vsound;
    %estimated delay between mic 2 vs mic3
    m(i,4) = (sqrt((positions_out(2).x_m-x)^(2)+(positions_out(2).y_m-y)^(2)+(positions_out(2).z_m-z)^(2))-sqrt((positions_out(3).x_m-x)^(2)+(positions_out(3).y_m-y)^(2)+(positions_out(3).z_m-z)^(2)))/Vsound;
    %estimated delay between mic 2 vs mic4
    m(i,5) = (sqrt((positions_out(2).x_m-x)^(2)+(positions_out(2).y_m-y)^(2)+(positions_out(2).z_m-z)^(2))-sqrt((positions_out(4).x_m-x)^(2)+(positions_out(4).y_m-y)^(2)+(positions_out(4).z_m-z)^(2)))/Vsound;
    %estimated delay between mic 3 vs mic4
    m(i,6) = (sqrt((positions_out(3).x_m-x)^(2)+(positions_out(3).y_m-y)^(2)+(positions_out(3).z_m-z)^(2))-sqrt((positions_out(4).x_m-x)^(2)+(positions_out(4).y_m-y)^(2)+(positions_out(4).z_m-z)^(2)))/Vsound;
    
    clear x y z
end
end

