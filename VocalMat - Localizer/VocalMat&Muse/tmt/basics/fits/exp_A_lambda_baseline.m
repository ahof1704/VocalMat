function y = f(params,x)

A=params(1);
lambda=params(2);
baseline=params(3);
y=A*exp(-x/lambda)+baseline;
all_y_finite=all(isfinite(y));
if ~all_y_finite
  A
  lambda
  baseline
  warning('y not all finite!');
end
