function during_spike=...
           f(t,v,T_sigma_filter,dt_spike_detect,v_spike_height,...
             dt_spike_filter)

% get time info, translate dt_spike_limit into sample units
[n_t,t0,tf,T,dt,fs]=time_info(t);
di_spike_filter=round(dt_spike_filter/dt);
di_pre_filter=di_spike_filter(1);
di_post_filter=di_spike_filter(2);

% filter
during_spike=repmat(false,size(v));
n_t=length(t);
n_trace=size(v,2);
for j=1:n_trace
  v_this=v(:,j);
  i_spikes=spike_indices_three_point(t,v_this,...
                                     T_sigma_filter,dt_spike_detect,v_spike_height);
  for k=1:length(i_spikes)
    i_this=i_spikes(k);
    i_pre=max(i_this+di_pre_filter,1);
    i_post=min(i_this+di_post_filter,n_t);
    during_spike(i_pre:i_post,j)=true;
  end
end


