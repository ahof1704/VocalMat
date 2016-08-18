function y_interp=interp1_fast(x,y,x_interp)

% faster interpolation for regularly spaced data
% x and y should be col vectors

% x_interp should be a matrix
% y_interp is the same shape as x_interp

n_x=length(x);
x0=x(1);
xf=x(end);
dx=(xf-x0)/(n_x-1);

[M,N]=size(x_interp);
y_interp=zeros(M,N);
k_frac=(x_interp-x0)/dx+1;
k_lo=floor(k_frac);
k_hi=k_lo+1;
w_hi=k_frac-k_lo;
w_lo=1-w_hi;
y_interp=w_lo.*y(k_lo)+w_hi.*y(k_hi);

end
