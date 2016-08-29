function y = f(A,tau,t,x)

[n_samples,t_min,t_max,T,dt,fs]=time_info(t);
y=A*exp_filter_1d(x,tau/dt);
