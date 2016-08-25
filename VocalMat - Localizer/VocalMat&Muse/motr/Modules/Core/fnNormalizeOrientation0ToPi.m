function theta=fnNormalizeOrientation0ToPi(theta)

% Convert an angle in radians _that represents an orientation_ to be on 
% [0,pi].  By "orientation", I mean the angle a line segment relative to 
% the horizontal, if you don't consider one end the head and one the tail.
% E.g. if you add pi to the orientation, you get the same orientation.  So
% an orientation of zero is the same as pi.
%
% Also works with arrays of orientation.

theta=atan2(sin(2*theta),cos(2*theta))/2;  % on [-pi/2,+pi/2]
fix=(theta<0);
theta(fix)=theta(fix)+pi;

end
