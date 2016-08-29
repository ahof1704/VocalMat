function ar=read_array_float64_from_tcs(fid)

% ar is a vector

[n,count]=fread(fid,1,'int32');
if count<1
  fclose(fid);
  error(sprintf(['unable to read length of array ' ...
                 'from file with file ID %d'],fid));
end
[ar,count]=fread(fid,n,'float64');
if count<n
  fclose(fid);
  error(sprintf('unable to read array from file with file ID %d',fid));
end
