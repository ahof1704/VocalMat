function [t_fs,fs]=f(ts)

% this uses the event times in ts to determine the event frequency.  To
% determine the freq at the jth event, it takes the median of the
% inter-event intervals for the five events centered on the j'th event.

n_ts=length(ts);
dt=diff(ts);
fs=zeros(length(dt)-4,1);
for j=3:(n_ts-2)  % this gives the index of the central spike
  fs(j-2)=1/median(dt(j-2:j+1));
end
t_fs=ts(3:end-2);
