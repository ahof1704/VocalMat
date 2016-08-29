function ts_out=f(ts,ts_bad,dt)

if nargin<3 
  dt=[];
end

ts_out=ts;
n_bad=length(ts_bad);
for i=1:n_bad
  ts_out=delete_event_near(ts_out,ts_bad(i),dt);
end

