function crossings=f(x,x_star)

% this function returns an array which is nonzero when x crosses x_star.  
% whether a crossing has occured is determined by looking at whether
% x-x_star changes sign.  in this context, zero is considered a positive
% number.
%
% t and x must be vectors of same size
% x_star can be scalar or vector of same size at t and x
%
% crossings is an array which is
% zero where there's no crossing, +1 for a rising crossing, 
% and -1 for a falling
% crossing.  the elements of crossings correspond with the spaces 
% between the
% elements of x.  i.e. crossing(i) tells about the crossiness of the
% transition from x(i) to x(i+1).  thus crossings is of length
% length(x)-1

n=length(x);
x_sub_star=x-x_star;
x_sub_star_sign=sign(x_sub_star);
x_sub_star_nonneg=(x_sub_star_sign>=0);
crossings=diff(x_sub_star_nonneg);
% need to filter out "crossings" that are next to a NaN in x
nan_before=isnan(x(1:end-1));
nan_after =isnan(x(2:end  ));
crossings(nan_before)=0;
crossings(nan_after )=0;
