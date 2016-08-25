function f()

global SPIKE_TIMES;

if length(SPIKE_TIMES)>0
  SPIKE_TIMES=SPIKE_TIMES(1:end-1);
end
