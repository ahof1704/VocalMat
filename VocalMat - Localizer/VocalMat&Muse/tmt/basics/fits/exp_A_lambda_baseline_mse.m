function mse = f(params,x,y)

y_fit=exp_A_lambda_baseline(params,x);
res=y_fit-y;
mse=sum(res.^2);
