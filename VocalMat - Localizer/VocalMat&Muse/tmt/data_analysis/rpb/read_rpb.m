function [borders,labels]=read_rpb(filename)

%
% load in the ROI data from the file, w/ error checking
%

% want a short version of filename for possible error messages
[~,base_name,ext]=fileparts(filename);
filename_short=[base_name ext];

% open the file
fid=fopen(filename,'r','ieee-be');
if (fid == -1)
  error('read_rpb:unable_to_open_file', ...
        'Unable to open file %s',filename_short);
end

% read the number of rois
[n_rois,count]=fread(fid,1,'uint32');
%n_rois
if (count ~= 1)
  fclose(fid);
  error('read_rpb:error_loading_rois', ...
        'Error loading ROIs from file %s',filename_short);
end

% dimension cell arrays to hold the ROI labels and vertex lists
labels=cell(n_rois,1);
borders=cell(n_rois,1);

% for each ROI, read the label and the vertex list
for j=1:n_rois
  % the label
  [n_chars,count]=fread(fid,1,'uint32');
  if (count ~= 1)
    fclose(fid);
    error('read_rpb:error_loading_rois', ...
          'Error loading ROIs from file %s',filename_short);
  end
  [temp,count]=fread(fid,[1 n_chars],'uchar');
  if (count ~= n_chars)
    fclose(fid);
    error('read_rpb:error_loading_rois', ...
          'Error loading ROIs from file %s',filename_short);
  end
  labels{j}=char(temp);
  % the vertex list
  [n_vertices,count]=fread(fid,1,'uint32');
  if (count ~= 1)
    fclose(fid);
    error('read_rpb:error_loading_rois', ...
          'Error loading ROIs from file %s',filename_short);
  end
  %this_border=zeros(2,n_vertices);
  [this_border,count]=fread(fid,[2 n_vertices],'float32');
  %this_border
  if (count ~= 2*n_vertices)
    fclose(fid);
    error('read_rpb:error_loading_rois', ...
          'Error loading ROIs from file %s',filename_short);
  end
  borders{j}=this_border;
end

% close the file
fclose(fid);

end
