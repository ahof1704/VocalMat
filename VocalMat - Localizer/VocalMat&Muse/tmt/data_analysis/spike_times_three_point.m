function [t_spikes,i_spikes]=...
           f(t,v,T_sigma_filter,dt_spike_limit,v_spike_height)

i_spikes=spike_indices_three_point(t,v,T_sigma_filter,dt_spike_limit,v_spike_height);
t_spikes=t(i_spikes);
