function rate=f(t_events,t_burst_starts,t_burst_ends)

% t_start, t_end are col vectors of burst start times, burst end times

n_bursts=length(t_burst_starts);
t_edges=zeros(2*n_bursts,1);
% collate the starts and ends, shift them a bit to include all spikes
% in burst
t_edges(1:2:end)=t_burst_starts-1e-6;
t_edges(2:2:end)=t_burst_ends+1e-6;
count=histc(t_events,t_edges);
count=count(1:2:end);
T_bursts=t_burst_ends-t_burst_starts;
rate=(count-1)./T_bursts;
