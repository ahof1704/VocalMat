function [times,signs,indices]=f(t,x,dx,x_star,dx_thresh)

% this does what crossing_times() does, but also checks that the
% first derivative is big enough, to exclude spurious crossings
%

[times_raw,signs_raw,indices_raw]=crossing_times(t,x,x_star);
n_crossings_raw=length(times_raw);
dx_times_raw=interp1(t,dx,times_raw);
above_thresh=(abs(dx_times_raw)>dx_thresh);
times=times_raw(above_thresh);
signs=signs_raw(above_thresh);
indices=indices_raw(above_thresh);
