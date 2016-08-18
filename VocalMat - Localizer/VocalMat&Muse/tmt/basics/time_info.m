function [n_samples,t_min,t_max,T,dt,fs]=f(t)

n_samples=length(t);
t_min=t(1);
t_max=t(n_samples);
T=t_max-t_min;
dt=(t_max-t_min)/(n_samples-1);
fs=1/dt;
