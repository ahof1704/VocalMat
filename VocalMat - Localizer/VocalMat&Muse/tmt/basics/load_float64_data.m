function data = f(filename)

% this is a function to read multidimensional arrays stored in a format 
% that I made up.  I should have probably named is something other than
% load_binary_data, since it only loads binary data in this lame format I
% made up.

fid=fopen(filename,'r','ieee-be');
if (fid == -1)
    error(sprintf('Unable to open file %s',filename));
end
[rank,count]=fread(fid,1,'float64');
%rank
if (count ~= 1)
    error(sprintf('Error loading data from file %s',filename));
end
[dims,count]=fread(fid,rank,'float64');
%dims
if (count ~= rank)
    error(sprintf('Error loading data from file %s',filename));
end
dims=dims';  % Want a row vector
if (rank<=2)
    [data,count]=fread(fid,dims,'float64');
    if (count ~= prod(dims))
        error(sprintf('Error loading data from file %s',filename));
    end
elseif (rank==3)
    data=zeros(dims);
    for i=1:dims(3)
        [data(:,:,i),count]=fread(fid,dims(1:2),'float64');
        if (count ~= prod(dims(1:2)))
            error(sprintf('Error loading data from page %d of file %s',...
                          i,filename));
        end 
    end
elseif (rank==4)
    data=zeros(dims);
    for i=1:dims(3)
        for j=1:dims(4)
            [data(:,:,i,j),count]=fread(fid,dims(1:2),'float64');
            if (count ~= prod(dims(1:2)))
                error(sprintf('Error loading data from page %d of hyperpage %d of file %s',...
                              i,j,filename));
            end 
        end
    end
else
    error(sprintf('Data in file %s is of rank > 4',filename));
end
fclose(fid);
