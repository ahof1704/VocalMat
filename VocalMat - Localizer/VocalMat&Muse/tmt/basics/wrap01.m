function theta_normed=f(theta)

% This takes an
% angle in radians and returns an equivalent angle on [0,1], in units of
% cycles

theta_normed=mod(theta/(2*pi),1);
