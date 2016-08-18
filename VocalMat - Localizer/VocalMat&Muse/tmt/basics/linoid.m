function y=f(x)

% this function computes x/(exp(x)-1), but 'patches' the singularity
% at x=0.  It can be shown that the limit of the function at this point is
% 1, and that the limit of the derivative at this point is -1/2.  So in a
% small region around x=0, we return 1-x/2, instead of x/(exp(x)-1).

epsilon=1e-6;
size_x=size(x);
if length(size_x)==2 & size_x(1)==1 & size_x(2)==1
  % this case is for scalar x
  if -epsilon<x & x<epsilon
    y=1-x/2;
  else
    y=x/(exp(x)-1);
  end  
else
  % this case is for non-scalar x
  x_serial=x(:);
  n=length(x_serial);
  y_serial=zeros(n,1);
  for i=1:n
    x_this=x_serial(i);
    if -epsilon<x_this & x_this<epsilon
      y_serial(i)=1-x_this/2;
    else
      y_serial(i)=x_this/(exp(x_this)-1);
    end
  end
  y=zeros(size(x));
  y(:)=y_serial;
end
