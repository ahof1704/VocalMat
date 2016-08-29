function n=read_int32_from_tcs(fid)

[n,count]=fread(fid,1,'int32');
if count<1
  fclose(fid);
  error(...
    sprintf(...
      'unable to read int32 from file with file ID %d',fid));
end
