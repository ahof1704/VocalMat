function [t_peri,v_peri_mean,v_peri,good_event,i_peri]=...
  event_triggered(t,v,t_events,dt_start,dt_end)

% EVENT_TRIGGERED Calculate event-triggered average
%    [t_peri,v_peri_mean] = event_triggered(t,v,t_events,dt_start,dt_end)
%    calculates the event-triggered average of the data in v, triggering
%    on the event times in t_events.  t should be an array of timestamps,
%    of the same size as v.  dt_start is the offset from the event time to
%    the start of the window, and dt_end if the offset to the end of the
%    window.  (E.g. If one wants to have ten units of time before each
%    event, and twenty units after, the dt_start should be -10, and dt_end
%    should be 20.)  The v_peri_mean returned is the event-triggered
%    average, and t_peri is a timestamp vector for it, with time zero
%    corresponding to the times of the events.  t, v, and t_events should
%    all be col vectors.  Note that the each time in t_event is effectively
%    rounded to the nearest value in t before the average is done.  I.e. no
%    fancy interpolation of values in v is done before calculating the
%    average.
%    
%    [t_peri,v_peri_mean,v_peri] = 
%      event_triggered(t,v,t_events,dt_start,dt_end) returns the
%    individual windows around each event in v_peri.  v_peri has the same
%    number of rows as t_peri, and approximately as many columns as there
%    are events in t_events.  (The "approximately" is because events too
%    close to the start or event of v are not used.  "Too close" in this
%    context means close enough that the desired window would run off the
%    start or end of the data.)  The expression 
%    all(v_peri_mean==mean(v_peri,2)) will be true on return.
%
%    [t_peri,v_peri_mean,v_peri,good_event] = 
%      event_triggered(t,v,t_events,dt_start,dt_end) returns a logical
%    array of the same size as t_events, indicating which events are
%    included in the average and in v_peri.  The expression
%    size(v_peri,2)==sum(double(good_event)) will be true on return.
%
%    [t_peri,v_peri_mean,v_peri,good_event,i_peri] =
%      event_triggered(t,v,t_events,dt_start,dt_end) returns the index
%    on which each column of v_peri is centered.

% this will be useful later
[n_samples,t_min,t_max,T,dt,fs]=time_info(t);

% convert the event times to event indices
i_events=interp1(t,transpose(1:n_samples),t_events,'*nearest');

% get rid of the ones that don't have 
% enough samples before and/or after
di_start=floor(dt_start/dt);
di_end=ceil(dt_end/dt);
min_index=i_events+di_start;
max_index=i_events+di_end;
too_early=min_index<1;
too_late=max_index>n_samples;
good_event=logical(~(too_early|too_late));
i_events=i_events(good_event);
t_events=t_events(good_event);
n_events=length(i_events);

% go through and put all the peri-stimulus records into a single matrix
n_peri_samples=di_end-di_start+1;
v_peri=zeros(n_peri_samples,n_events);
for j=1:n_events
  k=i_events(j);
  v_peri(:,j)=v(k+di_start:k+di_end);
end
i_peri=(di_start:di_end)';
t_peri=dt*i_peri;

% calc the average
v_peri_mean=mean(v_peri,2);
