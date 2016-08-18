function [p,x]=f(x_data,x_min,x_max,dx,sigma)

if any((x_data<x_min)|(x_data>=x_max))
  warning('There is data not on [x_min,x_max) !');
end
n_samples=ceil((x_max-x_min)/dx)+1;
x=linspace(x_min,x_max,n_samples)';
n=length(x_data);
p=zeros(size(x));
for i=1:n
  p=p+normpdf(x,x_data(i),sigma);
end
p=p/n;  % normalize
