function write_trace_to_tcs(fid,name,t,x,units)

% fid is a file ID returned by open_tcs_for_writing()
% name is a string holding the names of some channels
% t is a col vector of timestamps,
% x is the data, a single column
% units is a units string

% get timeline info                            
n_t=length(t);
t0=t(1);
dt=(t(end)-t0)/(n_t-1);

% write the trace
write_string_to_tcs(fid,name);
write_string_to_tcs(fid,units);
write_float64_to_tcs(fid,t0);
write_float64_to_tcs(fid,dt);
write_array_float64_to_tcs(fid,x);
