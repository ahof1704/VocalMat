function [v_troughs,t_troughs,i_troughs]=f(t,v,t_spikes)

[n_t,t0,tf,T,dt,fs]=time_info(t);
i_spikes=round((t_spikes-t0)/dt)+1;
n_spikes=length(t_spikes);
n_troughs=n_spikes-1;
v_troughs=zeros(n_troughs,1);
i_troughs=zeros(n_troughs,1);
for j=1:n_troughs
  v_this=v(i_spikes(j):i_spikes(j+1));
  [v_troughs(j),i_troughs(j)]=min(v_this);
  i_troughs(j)=i_troughs(j)+i_spikes(j)-1;  % want index in v, not v_this
end
t_troughs=t0+dt*(i_troughs-1);
