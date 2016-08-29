function data = f(filename)

% this is a function to read multidimensional arrays stored in a format that
% I made up.  I should have probably named is something other than
% load_binary_data, since it only loads binary data in this lame format I
% made up.
%
% A previous version of this function only loaded float64 data.  That
% version is now called load_float64_data.

% open the file
fid=fopen(filename,'r','ieee-be');
if (fid == -1)
  error(sprintf('Unable to open file %s',filename));
end

% get the element type
[el_type_code,count]=fread(fid,1,'*uint64');
if (count ~= 1)
  fclose(fid);
  error(sprintf('Error loading data from file %s',filename));
end
switch el_type_code
  case 0,
    el_type='float64';
  case 1,
    el_type='uint8';
  otherwise,
    fclose(fid);
    error(sprintf('Unrecognized element type in file %s',filename));
end
convert_string=sprintf('*%s',el_type);

% get the rank
[rank,count]=fread(fid,1,'*uint64');
if (count ~= 1)
  fclose(fid);
  error(sprintf('Error loading data from file %s',filename));
end

% get the dimensions
[dims,count]=fread(fid,rank,'*uint64');
if (count ~= rank)
  fclose(fid);
  error(sprintf('Error loading data from file %s',filename));
end
dims=dims';  % Want a row vector

% read the data
if (rank<=2)
  [data,count]=fread(fid,dims,convert_string);
  if (count ~= prod(dims))
    fclose(fid);
    error(sprintf('Error loading data from file %s',filename));
  end
elseif (rank==3)
  data=zeros(dims,el_type);
  for i=1:dims(3)
    [data(:,:,i),count]=fread(fid,dims(1:2),convert_string);
    if (count ~= prod(dims(1:2)))
      fclose(fid);
      error(sprintf('Error loading data from page %d of file %s',...
                    i,filename));
    end
  end
elseif (rank==4)
  data=zeros(dims,el_type);
  for i=1:dims(3)
    for j=1:dims(4)
      [data(:,:,i,j),count]=fread(fid,dims(1:2),convert_string);
      if (count ~= prod(dims(1:2)))
        fclose(fid);
        error(sprintf('Error loading data from page %d of hyperpage %d of file %s',...
                      i,j,filename));
      end
    end
  end
else
  fclose(fid);
  error(sprintf('Data in file %s is of rank > 4',filename));
end

% close the file
fclose(fid);
