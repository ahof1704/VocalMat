function sse = f(A,tau,t,x,y_true)

[n_samples,t_min,t_max,T,dt,fs]=time_info(t);
y=lpf(A,tau,t,x);
err=y-y_true;
sse=dt*sum(err.^2);

