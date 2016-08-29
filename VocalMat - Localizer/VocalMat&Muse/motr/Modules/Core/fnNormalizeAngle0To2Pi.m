function theta=fnNormalizeAngle0To2Pi(theta)

% Convert an angle in radians to be on [0,2*pi].  Also works with
% arrays of angles.

theta=atan2(sin(theta),cos(theta));
fix=(theta<0);
theta(fix)=theta(fix)+2*pi;

end
