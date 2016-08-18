function [ Vsound ] = fn_velocity_sound( T )
%   This function calculates the velocity of sound based on the temp during
%       recording 
%
%   formula for speed of sound in air taken from signals, sound and
%       sensation (hartmann)
%
%   T is the temp in Celcius

Vsound=331.3*sqrt(1+(T/273.16)); 


end

