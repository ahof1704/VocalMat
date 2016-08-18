function [name,t,x,units]=read_tcs(file_name)

% write the stuff
fid=open_tcs_for_reading(file_name);
n_trace=read_int32_from_tcs(fid);
name=cell(n_trace,1);
t=cell(n_trace,1);
x=cell(n_trace,1);
units=cell(n_trace,1);
for i=1:n_trace
  [name_this,t_this,x_this,units_this]=read_trace_from_tcs(fid);
  name{i}=name_this;
  t{i}=t_this;
  x{i}=x_this;
  units{i}=units_this;
end
close_tcs(fid);
