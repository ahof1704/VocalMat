function x=read_float64_from_tcs(fid)

% x is a scalar

[x,count]=fread(fid,1,'float64');
if count<1
  fclose(fid);
  error(sprintf('unable to read float64 from file with file ID %d',fid));
end
