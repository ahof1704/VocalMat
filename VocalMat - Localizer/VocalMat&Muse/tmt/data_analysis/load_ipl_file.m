function data = load_ipl_file(filename)

% On exit, data is a nrows*ncols*nframes array of data 

% 8/12/97: Changed code to reflect the fact that IP lab saves
%            frames in usual raster-scan order, not bottom-row-
%            first raster scan

% These files are big-endian (most significant byte first)

fileid=fopen(filename,'r','ieee-be');
if ( fileid == -1 )
  fprintf(2,'Unable to open file %s\n',filename);
  data = [];
  return;
end

[headerpart1,count] = fread(fileid,6,'uint8');
if (count ~= 6)
  fclose(fileid);
  error('TMT:load_ipl_file:header_error','Problem reading %s\n',filename);
end  

[framedims,count] = fread(fileid,2,'uint32');
if (count ~= 2)
  fclose(fileid);
  error('TMT:load_ipl_file:header_error','Problem reading %s\n',filename);
end  
ncols=framedims(1);
nrows=framedims(2);

[headerpart2,count] = fread(fileid,6,'uint8');
if (count ~= 6)
  fclose(fileid);
  error('TMT:load_ipl_file:header_error','Problem reading %s\n',filename);
end  

[nframes,count] = fread(fileid,1,'uint16');
if (count ~= 1)
  fclose(fileid);
  error('TMT:load_ipl_file:header_error','Problem reading %s\n',filename);
end  

[headerpart3,count] = fread(fileid,2098,'uint8');
if (count ~= 2098)
  fclose(fileid);
  error('TMT:load_ipl_file:header_error','Problem reading %s\n',filename);
end  

ppf=ncols*nrows;
npels=ppf*nframes;
transposed_frame=zeros(ncols,nrows);
data=zeros(nrows,ncols,nframes);

for i=1:nframes
  [transposed_frame,count]=fread(fileid,[ncols nrows],'int16');
  if (count ~= ppf)
    fclose(fileid);
    error('TMT:load_ipl_file:frame_error', ...
          'Problem reading frame %d of %s\n',i,filename);
  end
  data(:,:,i)=transposed_frame';
end

fclose(fileid);

return;


