function [t_bursts,T_bursts,t_burst_starts,t_burst_ends,n_events_per]=...
  f(t_events,T_cutoff,min_events_per)

% this takes a vector of event times, and returns a vector of burst times
% it determines what a "burst" is by looking at the inter-event intervals,
% and it decides that event i is the start of a new burst if the time since
% event i-1 is greater than T_cutoff.  The first event in t_events is
% assumed to be the start of the first burst.
%
% on exit:
%   t_bursts contains the time of the median spike in each burst.
%   T_bursts contains the duration of each burst.
%   t_burst_starts contains the time of the first spike in each burst
%   t_burst_ends contains the time of the last spike in each burst

if nargin<3 || isempty(min_events_per)
  min_events_per=1;
end

% segment into bursts, without dealing w/ min_events yet
index_first_event_of_this_burst=1;
n_events=length(t_events);
t_bursts=[];
T_bursts=[];
t_burst_starts=[];
t_burst_ends=[];
n_events_per=[];
for i=1:(n_events-1)
  % check if i is the last event in the burst
  if t_events(i+1)-t_events(i) > T_cutoff
    % if so, need to calculate burst median, put it on list
    t_bursts(end+1,1)=...
      median(t_events(index_first_event_of_this_burst:i));
    T_bursts(end+1,1)=...
      t_events(i)-t_events(index_first_event_of_this_burst);
    t_burst_starts(end+1,1)=t_events(index_first_event_of_this_burst);
    t_burst_ends(end+1,1)=t_events(i);
    n_events_per(end+1,1)=i-index_first_event_of_this_burst+1;
    index_first_event_of_this_burst=i+1;
  end
end
% wrap-up: finish off the last burst
t_bursts(end+1,1)=...
  median(t_events(index_first_event_of_this_burst:end));
T_bursts(end+1,1)=...
  t_events(end)-t_events(index_first_event_of_this_burst);
t_burst_starts(end+1,1)=t_events(index_first_event_of_this_burst);
t_burst_ends(end+1,1)=t_events(end);

% now get rid of bursts without enough events in them
if min_events_per>1
  big_enough=(n_events_per>=min_events_per);
  t_bursts=t_bursts(big_enough);
  T_bursts=T_bursts(big_enough);
  t_burst_starts=t_burst_starts(big_enough);
  t_burst_ends=t_burst_ends(big_enough);
  n_events_per=n_events_per(big_enough);
end
