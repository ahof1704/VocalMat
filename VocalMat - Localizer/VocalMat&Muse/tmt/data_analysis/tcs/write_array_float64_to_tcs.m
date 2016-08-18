function write_array_float64_to_tcs(fid,ar)

% ar is a vector

count=fwrite(fid,length(ar),'int32');
if count<1
  fclose(fid);
  error(sprintf(['unable to write length of array ' ...
                 'to file ID %d'],fid));
end
count=fwrite(fid,ar,'float64');
if count<length(ar)
  fclose(fid);
  error(sprintf('unable to write array to file ID %d',fid));
end
