function str=read_string_from_tcs(fid)

[n,count]=fread(fid,1,'int32');
if count<1
  fclose(fid);
  error(sprintf(['unable to read length of string ' ...
                 'from file with file ID %d'],fid));
end
[str,count]=fread(fid,[1 n],'*char');
if count<n
  fclose(fid);
  error(sprintf('unable to read string from file with file ID %d',fid));
end
