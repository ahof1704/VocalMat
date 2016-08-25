function write_string_to_tcs(fid,str)

count=fwrite(fid,length(str),'int32');
if count<1
  fclose(fid);
  error(sprintf(['unable to write length of string %s ' ...
                 'to file ID %d'],fid,str));
end
count=fwrite(fid,str,'char');
if count<length(str)
  fclose(fid);
  error(sprintf('unable to write string %s to file ID %d',str,fid));
end
