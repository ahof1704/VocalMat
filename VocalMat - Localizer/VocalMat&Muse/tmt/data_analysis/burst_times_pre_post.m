function [t_bursts,T_bursts,t_burst_starts,t_burst_ends]=...
  f(t_events,T_intra_cutoff,T_inter_cutoff,in_burst_initial)

% this takes a vector of event times, and returns a vector of burst times.
% we step through the events, keeping track of whether we're currently in a
% burst or not.  If we're not currently in a burst, an event is a burst- 
% starter if the previous ISI is longer than T_start_cutoff.  If we _are_
% currently in a burst, an event is a burst-ender if the next ISI is longer
% than T_end_cutoff.  Whether or not the first event is part of a burst is
% set by in_burst_initial, which is false by default.  If we're in a burst
% when we get to the last event, that event is a burst-ender.
%
% on exit:
%   t_bursts contains the time of the median spike in each burst.
%   T_bursts contains the duration of each burst.
%   t_burst_starts contains the time of the first spike in each burst
%   t_burst_ends contains the time of the last spike in each burst

if nargin<4 || isempty(in_burst_initial)
  in_burst_initial=false;
end

% now, go through and classify spikes
n_events=length(t_events);
t_bursts=[];
T_bursts=[];
t_burst_starts=[];
t_burst_ends=[];
if in_burst_initial
  in_burst=true;
  index_first_event_of_this_burst=1;
else
  in_burst=false;
  index_first_event_of_this_burst=NaN;  % this is unnecessary  
end
for i=2:(n_events-1)
  if in_burst
    % check if event i is a burst ender
    if t_events(i+1)-t_events(i) > T_end_cutoff
      % if so, need to calculate burst median, put it on list
      t_bursts(end+1,1)=...
        median(t_events(index_first_event_of_this_burst:i));
      T_bursts(end+1,1)=...
        t_events(i)-t_events(index_first_event_of_this_burst);
      t_burst_starts(end+1,1)=t_events(index_first_event_of_this_burst);
      t_burst_ends(end+1,1)=t_events(i);
      in_burst=false;
    end
  else  % if we're not in a burst
    % check if event i is a burst starter
    if t_events(i)-t_events(i-1) > T_start_cutoff
      in_burst=true;
      index_first_event_of_this_burst=i;
    end
  end
end
% wrap-up: if we're in a burst, the last event is the burst end
if in_burst
  t_bursts(end+1,1)=...
    median(t_events(index_first_event_of_this_burst:end));
  T_bursts(end+1,1)=...
    t_events(end)-t_events(index_first_event_of_this_burst);
  t_burst_starts(end+1,1)=t_events(index_first_event_of_this_burst);
  t_burst_ends(end+1,1)=t_events(end);
end
