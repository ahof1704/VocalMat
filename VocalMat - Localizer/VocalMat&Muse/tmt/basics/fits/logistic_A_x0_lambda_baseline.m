function y = f(theta,x)

A=theta(1);
x0=theta(2);
lambda=theta(3);
baseline=theta(4);
y=A./(1+exp(-(x-x0)/lambda))+baseline;
