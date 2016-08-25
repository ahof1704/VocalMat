function theta_normed=f(theta)

% this is the complement of the Matlab built-in unwrap().  It takes an
% angle in radians and returns an equivalent angle on [-pi,+pi].

theta_normed=mod(theta+pi,2*pi)-pi;
