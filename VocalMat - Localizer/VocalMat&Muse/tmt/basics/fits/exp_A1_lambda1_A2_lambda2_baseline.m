function y = f(params,x)

A1=params(1);
lambda1=params(2);
A2=params(3);
lambda2=params(4);
baseline=params(5);
y=A1*exp(-x/lambda1)+A2*exp(-x/lambda2)+baseline;
if ~all(isfinite(y))
  A1
  lambda1
  A2
  lambda2
  baseline
  warning('y not all finite!');
end
