function write_int32_to_tcs(fid,i)

count=fwrite(fid,i,'int32');
if count<1
  fclose(fid);
  error(sprintf('unable to write int32 %d to file with file ID %d',i,fid));
end
