function kernel = f(tau,n)

if nargin<2
  n=ceil(5*tau);
end
x_grid=(0:(n-1))';
kernel_prenorm=exp(-x_grid/tau);
% normalize
kernel=kernel_prenorm/sum(kernel_prenorm);

