function [times,signs,indices]=f(t,x,x_star)

% this function returns an array of times at which x crosses x_star.
% whether a crossing has occured is determined by looking at whether
% x-x_star changes sign.  In this context, zero is considered a positive
% number.
%
% t and x must be vectors of same size
% x_star can be scalar or vector of same size as x
% each element of signs is positive or negative depending on the
%   sign of the crossing
%
% If the inputs are col vectors, the outputs are too.  Ditto for row
% vectors.
%
% ALT 8/2007

n=length(t);
t_is_col_vector=(size(t,2)==1);
x_sub_star=x-x_star;
x_sub_star_sign=sign(x_sub_star);
x_sub_star_nonneg=(x_sub_star_sign>=0);  % nans in x_sub_star_sign -> false
crossings_raw=(x_sub_star_nonneg(2:n)~=x_sub_star_nonneg(1:n-1));
x_sub_star_sign_nan=isnan(x_sub_star_sign);
nanified=(x_sub_star_sign_nan(2:n)|x_sub_star_sign_nan(1:n-1));
crossings=(crossings_raw&~nanified);
indices=find(crossings);
n_crossings=length(indices);
if n_crossings==0
  if t_is_col_vector
    times=zeros(0,1);
    signs=zeros(0,1);
  else
    times=zeros(1,0);
    signs=zeros(1,0);
  end    
else
  if t_is_col_vector
    times=zeros(n_crossings,1);
    signs=zeros(n_crossings,1);
  else
    times=zeros(1,n_crossings);
    signs=zeros(1,n_crossings);
  end    
  for i=1:n_crossings
    j=indices(i);
    times(i)=t(j)+ ...
             (t(j+1)-t(j))*x_sub_star(j)/(x_sub_star(j)-x_sub_star(j+1));
    signs(i)=sign(x_sub_star(j+1)-x_sub_star(j));
  end
end
