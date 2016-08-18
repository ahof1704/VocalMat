function mse = f(theta,x,y)

y_fit=sech_A_x0_lambda_plus_lambda_minus_baseline(theta,x);
res=y_fit-y;
mse=sum(res.^2);
