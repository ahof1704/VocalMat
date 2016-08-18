function v_naned=f(t,v,ts,dt_filter);

[n_t,t0,tf,T,dt,fs]=time_info(t);
is=round((ts-t0)/dt)+1;
di_filter=round(dt_filter/dt);
di_pre=di_filter(1);
di_post=di_filter(2);
v_naned=v;
for j=1:length(is)
  i_this=is(j);
  v_naned(i_this+di_pre:i_this+di_post)=NaN;
end
