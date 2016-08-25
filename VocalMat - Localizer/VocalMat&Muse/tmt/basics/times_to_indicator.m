function indicator=f(t,ts)

indicator=repmat(0,size(t));
[n_t,t0,tf,T,dt,fs]=time_info(t);
is=round((ts-t0)/dt)+1;
indicator(is)=1;
