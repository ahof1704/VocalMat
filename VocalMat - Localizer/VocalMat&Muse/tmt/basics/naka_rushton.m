function y=f(x)

% The Naka-Rushton sigmoid function
% Argument x can be scalar or array
% The function returns 0   for x<=0
%              returns 0.5 for x=1
%              asymptotes at 1 as x->+Inf
% This function has the features that it has a hard threshold at x=0,
% and is continuous and smooth (but not C2).

temp=x.^2;
y=(x>0).*(temp./(1+temp));

