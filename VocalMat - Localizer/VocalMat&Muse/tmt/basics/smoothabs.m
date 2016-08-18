function y=f(x)

% this is a smooth version of the abs() function.  It's based on the
% observation that log(cosh()) is the
% integral of tanh(), which is a continuous version of the derivative of
% abs(), which is of course not continuous.
%
% I compute log(cosh(x)) a special way, as
% abs(x)+log(1+exp(-2*abs(x)))-log(2), instead of just taking
% log(cosh(x)).  I proved that these two expressions are equal for
% all real x.  I do it this way because cosh() will overflow for some x,
% even when log(cosh(x)) is within the range of a double
%
% the ./(1+x.^2) bit fixes a problem with log(cosh(x)) as an
% approximation of abs(x), namely that log(cosh(x)) does not approach
% abs(x) for large x, but approaches x-log(2) instead.  The
% ./(1+x,^2) makes sure that the -log(2) is 'in play' near zero but
% then goes away for large x.

y=abs(x)+log(1+exp(-2*abs(x)))-log(2)./(1+(x).^2);
