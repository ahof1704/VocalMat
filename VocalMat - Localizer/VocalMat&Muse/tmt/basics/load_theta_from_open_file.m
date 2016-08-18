function [Isyn,phi,Iinj] = f(dataFID)

dims=fscanf(dataFID,'%f',2);
ncols=dims(1);
nrows=dims(2);
if (nrows~=ncols)
  errorMsg=sprintf('Isyn in %s is not square',filename);
  error(errorMsg)
end
Isyn=fscanf(dataFID,'%f',[nrows ncols]);
Isyn=Isyn';
nels=fscanf(dataFID,'%f',1);
if (nels~=nrows)
  errorMsg=sprintf('Isyn and phi have inconsistent dimensions in %s',filename);
  error(errorMsg)
end
phi=fscanf(dataFID,'%f',[nrows 1]);
nels=fscanf(dataFID,'%f',1);
if (nels~=nrows)
  errorMsg=sprintf('Isyn and Iinj have inconsistent dimensions in %s',filename);
  error(errorMsg)
end
Iinj=fscanf(dataFID,'%f',[nrows 1]);
