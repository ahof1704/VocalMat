function write_traces_to_tcs(fid,name,t,x,units)

% fid is a file ID returned by open_tcs_for_writing()
% name is a cell array holding the names of some channels
% t is a col vector of timestamps, common to all data
% x is the data, with each trace a column
% units is a cell array holding a units string for each channel

% get timeline info                            
n_t=length(t);
t0=t(1);
dt=(t(end)-t0)/(n_t-1);

% write the traces
n_trace=length(name);
for i=1:n_trace
  name_this=name{i};
  units_this=units{i};
  x_this=x(:,i);
  write_trace_to_tcs(fid,name_this,t,x_this,units_this)
end
