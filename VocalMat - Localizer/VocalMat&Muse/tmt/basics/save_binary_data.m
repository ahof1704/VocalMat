function f(filename,data)

% A previous version of this function only saved float64 data.  That
% version is now called save_float_64_data.

fid=fopen(filename,'w','ieee-be');
if (fid == -1)
  error(sprintf('Unable to open file %s',filename));
end
el_type=class(data);
rank=uint64(ndims(data));
dims=uint64(size(data));
count=fwrite(fid,rank,'*uint64');
if (count ~= 1)
  fclose(fid);
  error(sprintf('Error writing data to file %s',filename));
end
count=fwrite(fid,dims,'*uint64');
if (count ~= rank)
  fclose(fid);
  error(sprintf('Error writing data to file %s',filename));
end
count=fwrite(fid,data,sprintf('*%s',el_type));
if (count ~= prod(dims))
  fclose(fid);
  error(sprintf('Error writing data to file %s',filename));
end
fclose(fid);

