function ts_filt=f(ts,T_refract)

% the first event goes into ts_filt.  Subsequent events in ts get added to
% the end of ts_filt only if they are more than T_refract _after_ the last
% event in ts_filt.
%
% basically this is good for filtering an event channel that has event from
% more than one neuron, to ensure that the instantaneous spike rate is not
% too big.

if length(ts)==0
  ts_filt=ts;
else
  ts_filt=ts(1);
  S=length(ts);
  for s=2:S
    if ts(s)-ts_filt(end)>T_refract
      ts_filt(end+1)=ts(s);
    end
  end
end
