function during_event=f(t_events,t,dt_event)

% this translates a list of event times, along with the event "width", to a
% boolean signal indicating which times are during an event

% get time info, translate dt_spike_limit into sample units
[n_t,t0,tf,T,dt,fs]=time_info(t);
di_event=round(dt_event/dt);
di_pre=di_event(1);
di_post=di_event(2);

% filter
during_event=repmat(false,size(t));
n_t=length(t);
i_events=round((t_events-t0)/dt)+1;
for k=1:length(i_events)
  i_this=i_events(k);
  i_pre=max(i_this+di_pre,1);
  i_post=min(i_this+di_post,n_t);
  during_event(i_pre:i_post)=true;
end
