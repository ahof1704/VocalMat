function theta=fnNormalizeAngleSymmetric(theta)

% Convert an angle in radians to be on [-pi,+pi].  Also works with
% arrays of angles.

theta=atan2(sin(theta),cos(theta));

end
