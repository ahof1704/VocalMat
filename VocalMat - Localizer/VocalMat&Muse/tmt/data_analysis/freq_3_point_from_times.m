function [t_fs,fs]=f(ts)

% this uses the event times in ts to determine the event frequency.  To
% determine the freq at the jth event, it takes one over the mean of the
% inter-event intervals on either side of the j'th event.

n_ts=length(ts);
dt=diff(ts);
dt_mean=(dt(1:end-1)+dt(2:end))/2;
fs=1./dt_mean;
t_fs=ts(2:end-1);
