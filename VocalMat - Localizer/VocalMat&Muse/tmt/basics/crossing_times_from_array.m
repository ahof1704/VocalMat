function [crossing_times,crossing_sign]=f(t,x,x_star,crossings_array)

% [crossing_times,crossing_sign]=f(t,x,x_star,crossings_array)
%
% This function interpolates the time at which x crosses x_star, given that
% a crossing occurs at all samples where crossings_array is true
% 
% t                   Vector of timestamps
% x                   Vector, same shape as t
% x_star              The threshold, scalar or vector with same shape as t
% crossings_array     Vector of when crossings occur, must be same shape 
%                     as t except for having one less element in the
%                     non-singleton dimension.  This vector maps one-to-one
%                     onto the 'spaces' between elements of x, i.e. 
%                     crossings_array(i) tells about the crossiness of the
%                     transition from x(i) to x(i+1).  Elements of this
%                     vector must be -1, 0, or +1.  -1 means a falling
%                     crossing, 0 means no crossing, +1 means a rising
%                     crossing
%
% crossing_times      Interpolated times at which crossings occur, according
%                     to crossings_array.  A row vector.
% crossing_sign       The sign of each crossing returned in crossing_times,
%                     also a row vector
%
% ALT 2/2001

[n,t_min,t_max,T,dt,fs]=time_info(t);
crossings=abs(crossings_array);
crossing_indices=find(crossings);
n_crossings=length(crossing_indices);
crossing_times=zeros(n_crossings,1);
x_sub_star=x-x_star;
for i=1:n_crossings
  j=crossing_indices(i);
  crossing_times(i)=t(j)+dt*x_sub_star(j)/(x_sub_star(j)-x_sub_star(j+1));
  crossing_sign(i)=crossings_array(j);
end
