function t_events_out=...
  f(t_events,T_cutoff)

% first, get the isis
isis=t_events(2:end)-t_events(1:end-1);
isi_pre=isis(1:end-1);
isi_post=isis(2:end);

% find the outriggers, get rid of them
outrigger=[false;...
           (isi_pre>=T_cutoff)&...
             (isi_post>=T_cutoff);...
           false];
t_events_out=t_events(~outrigger);
