function y = f(theta,x)

A=theta(1);
x0=theta(2);
lambda_plus=theta(3);
lambda_minus=theta(4);
baseline=theta(5);
y=A./(exp(-(x-x0)./lambda_minus)+exp(+(x-x0)./lambda_plus))+baseline;

