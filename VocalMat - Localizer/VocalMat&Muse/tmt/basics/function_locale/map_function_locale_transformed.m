function [v_values,f_values,in_bounds,f_est_values]=...
  this(f,x,Basis,dv_size,x_lb,x_ub,n_steps,fx,g,H,varargin)

% x is the point about which we want to look. it really should be 
% unitless
%
% v_values will be 1   x n_points
% f_values will be dim x n_points also

% get the number of dimensions
dim=length(x);

% set the bounds
v_lower=-dv_size;
v_upper=+dv_size;

% init vars to store the results
n_steps_half=round(n_steps/2);
n_steps=2*n_steps_half;
n_points=n_steps+1;
v_values=linspace(-dv_size,+dv_size,n_points);
f_values=zeros(dim,n_points);
in_bounds=false(dim,n_points);
f_est_values=zeros(dim,n_points);

% for each basis vector, raster-scan
for i=1:dim
  for j=1:n_points
    dx=v_values(j)*Basis(:,i);
    x_test=x+dx;
    f_values(i,j)=feval(f,x_test,varargin{:});
    in_bounds(i,j)=(all(x_lb<=x_test)&&all(x_test<=x_ub));
    f_est_values(i,j)=fx+g*dx+dx'*(H*dx);
    fprintf(1,'.');
  end
  fprintf(1,'\n');
end

% functions that deal w/ this output expect a vector
v_values=repmat(v_values,[dim 1]);
