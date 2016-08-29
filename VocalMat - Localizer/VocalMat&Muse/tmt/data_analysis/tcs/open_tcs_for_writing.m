function fid=open_tcs_for_writing(file_name)

% n_trace is the number of traces to be added by the time we're done

fid=fopen(file_name,'w','ieee-le');
if fid<0
  error(sprintf('unable to open file %s',file_name));
end
