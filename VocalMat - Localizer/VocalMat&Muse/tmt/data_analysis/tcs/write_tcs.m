function write_tcs(file_name,name,t,x,units)

fid=open_tcs_for_writing(file_name);
n_trace=length(name);
write_int32_to_tcs(fid,n_trace);
for i=1:n_trace
  write_trace_to_tcs(fid,name{i},t{i},x{i},units{i});
end
close_tcs(fid);
