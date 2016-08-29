function [x_lo,x_hi] = f(x,dx)

x_lo=dx*(floor((min(x(:))/dx)));
x_hi=dx*( ceil((max(x(:))/dx)));
