function [name,t,x,units]=read_trace_from_tcs(fid)

name=read_string_from_tcs(fid);
units=read_string_from_tcs(fid);
t0=read_float64_from_tcs(fid);
dt=read_float64_from_tcs(fid);
x=read_array_float64_from_tcs(fid);
n=length(x);
t=t0+dt*(0:(n-1))';
