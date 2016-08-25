function ts_out=f(ts,ts_new)

ts_out=ts;
n_new=length(ts_new);
for i=1:n_new
  ts_out=add_event(ts_out,ts_new(i));
end
