function write_float64_to_tcs(fid,x)

% x is a scalar

count=fwrite(fid,x,'float64');
if count<1
  fclose(fid);
  error(sprintf('unable to write float64 %f to file ID %d',x,fid));
end
