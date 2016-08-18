function x_bounded=f(x,x_lb,x_ub)

n=size(x,2);
x_bounded=max(min(x,repmat(x_ub,[1 n])),repmat(x_lb,[1 n]));
