function x = f(y)

% all elements of y must be in the interval (0,1)

dims=size(y);
lower_bound=repmat(1e-15,dims);
upper_bound=repmat(1-1e-15,dims);
y=max(y,lower_bound);
y=min(y,upper_bound);
x = -log(y.^(-1)-1);

