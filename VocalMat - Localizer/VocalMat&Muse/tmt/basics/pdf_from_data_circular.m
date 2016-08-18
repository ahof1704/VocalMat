function [p,x]=f(x_data,x_min,x_max,dx,sigma)

if any((x_data<x_min)|(x_data>=x_max))
  warning('There is data not on [x_min,x_max) !');
end
n_samples=ceil((x_max-x_min)/dx)+1;
n_samples_pad=ceil(5*sigma/dx);
x_padded=linspace(x_min-n_samples_pad*dx,x_max+n_samples_pad*dx,...
                  n_samples+2*n_samples_pad)';
n=length(x_data);
p_padded=zeros(size(x_padded));
for i=1:n
  p_padded=p_padded+normpdf(x_padded,x_data(i),sigma);
end
p_padded=p_padded/n;  % normalize
% wrap
x=x_padded(n_samples_pad+1:end-n_samples_pad);
p=p_padded(n_samples_pad+1:end-n_samples_pad);
p(1:n_samples_pad)=p(1:n_samples_pad)+p_padded(end-n_samples_pad+1:end);
p(end-n_samples_pad+1:end)=p(end-n_samples_pad+1:end)+...
                           p_padded(1:n_samples_pad);
