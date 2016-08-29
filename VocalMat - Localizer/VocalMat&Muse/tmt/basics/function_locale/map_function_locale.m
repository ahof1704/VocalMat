function [x_values,f_values,in_bounds]=...
    this(f,x,x_scale,dx_scaled,x_lb,x_ub,n_steps,varargin)

% this version is designed to keep the x limits exactly as set by x_lower
% and x_upper.  If these are outside of [x_lb,x_ub], NaN's get put in where
% they're outside.  This behavior is preferable in some cases.
%
% this version allows a scale to be provided for the x vector, and the
% width of the scanned area is some fixed fraction (dx_scaled) of the scale

% set the bounds
x_lower=x-dx_scaled*x_scale;
x_upper=x+dx_scaled*x_scale;

% Convert f to inline function as needed
f=fcnchk(f,length(varargin));
fx=feval(f,x,varargin{:});

% get the number of dimensions
dim=length(x);

% init vars to store the results
n_steps_half=round(n_steps/2);
n_steps=2*n_steps_half;
n_points=n_steps+1;
x_values=zeros(dim,n_points);
f_values=zeros(dim,n_points);
in_bounds=false(dim,n_points);

% for each dimension, raster-scan
for i=1:dim
  % figure out which values of x to eval at
  x_values_this=linspace(x_lower(i),x_upper(i),n_points);
  x_values(i,:)=x_values_this;
  % eval f at all the x values
  x_test=x;
  for j=1:n_points
    x_test(i)=x_values(i,j);
    f_values(i,j)=feval(f,x_test,varargin{:});
    in_bounds(i,j)=((x_lb(i)<=x_values(i,j))&&(x_values(i,j)<=x_ub(i)));
    fprintf(1,'.');
  end
  fprintf(1,'\n');
end
