function r=rate_from_times_and_timeline_simple(t,ts)

N=length(t);
t0=t(1);
dt=(t(end)-t0)/(N-1);
is=round((ts-t0)/dt)+1;  % index into t of each spike
r=zeros(size(t));
r(is)=1/dt;
