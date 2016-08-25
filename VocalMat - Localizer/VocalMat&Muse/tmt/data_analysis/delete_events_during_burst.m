function t_result=f(t_events,t_burst_starts,t_burst_ends)

% we assume the inputs are all col vectors

n_events=length(t_events);
n_bursts=length(t_burst_starts);
t_events_matrix=repmat(t_events,[1 n_bursts]);
t_burst_starts_matrix=repmat(t_burst_starts',[n_events 1]);
t_burst_ends_matrix=repmat(t_burst_ends',[n_events 1]);
event_in_burst=(t_events_matrix>=t_burst_starts_matrix) & ...
               (t_events_matrix<=t_burst_ends_matrix);
event_in_some_burst=any(event_in_burst,2);
t_result=t_events(~event_in_some_burst);
