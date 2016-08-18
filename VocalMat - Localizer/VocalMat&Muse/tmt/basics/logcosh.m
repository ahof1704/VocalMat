function y=f(x)

% this is a smooth version of the abs() function log(cosh()) is the
% integral of tanh(), which is a continuous version of the derivative of
% abs(), which is of course not continuous
%
% I forget why I compute it this way, instead of just taking
% log(cosh(x)).  I guess probably cosh() will overflow for some x,
% even when log(cosh(x)) is within the range of a double
%
% I subtract log(2) to make it s.t. logcosh(0)==0.  This means that
% the positive asymptote is not y=x, but y=x-log(2).  You can take
% out the -log(2) if you want the asymptote to be right, but then
% logcosh(0)==log(2).  Do this to see what I'm talking about:
%
% x=-10:0.1:+10;
% figure; plot(x,abs(x),x,logcosh(x),x,logcosh(x)+log(2));

y=abs(x)+log(1+exp(-2*abs(x)))-log(2);
