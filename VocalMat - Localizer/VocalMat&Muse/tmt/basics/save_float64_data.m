function f(filename,data)

fid=fopen(filename,'w','ieee-be');
if (fid == -1)
  error(sprintf('Unable to open file %s',filename));
end
rank=ndims(data);
dims=size(data);
count=fwrite(fid,rank,'float64');
if (count ~= 1)
  error(sprintf('Error writing data to file %s',filename));
end
count=fwrite(fid,dims,'float64');
if (count ~= rank)
  error(sprintf('Error writing data to file %s',filename));
end
count=fwrite(fid,data,'float64');
if (count ~= prod(dims))
  error(sprintf('Error writing data to file %s',filename));
end
fclose(fid);

