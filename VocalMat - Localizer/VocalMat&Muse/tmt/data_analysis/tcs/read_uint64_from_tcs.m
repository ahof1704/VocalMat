function i=read_uint64_from_tcs(fid)

% i is a natural number

[i,count]=fread(fid,1,'uint64');
if count<1
  fclose(fid);
  error(sprintf('unable to read uint64 from file with file ID %d',fid));
end
