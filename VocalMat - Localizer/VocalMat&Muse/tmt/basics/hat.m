function x_hat=f(x)

% returns a unit vector with the same direction as the input vector
% if the input has zero norm, leaves it alone

l=norm(x);
if l~=0
  x_hat=x/l;
else
  x_hat=x;
end
