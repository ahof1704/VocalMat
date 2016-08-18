function [t,r]=f(dt,T,t0,ts)

N=round(T/dt);
T=N*dt;  % make sure dt and T are consistent
t=(t0:dt:t0+T-dt)';  % timeline
is=round((ts-t0)/dt)+1;  % index into t of each spike
r=zeros([N 1]);
r(is)=1/dt;
