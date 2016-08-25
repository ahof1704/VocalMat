function write_rpb(filename,border,label)

% get the ROI info
n_roi=length(border);

% want a short version of filename for possible error messages
[~,base_name,ext]=fileparts(filename);
filename_short=[base_name ext];

% open the file for writing
fid=fopen(filename,'w','ieee-be');
if (fid == -1)
  error('write_rpb:unable_to_open_file', ...
        'Unable to open file %s',filename_short);
end

% write the number of ROIs
count=fwrite(fid,n_roi,'uint32');
if (count ~= 1)
  fclose(fid);
  error('write_rpb:problem_writing_rois', ...
        'Error writing ROIs to file %s',filename_short);
end

% for each ROI, write a label and a vertex list
for j=1:n_roi
  % first the label
  label_string=label{j};
  n_chars=length(label_string);
  fwrite(fid,n_chars,'uint32');
  count=fwrite(fid,label_string,'uchar');
  if (count ~= n_chars)
    fclose(fid);
    error('write_rpb:problem_writing_rois', ...
          'Error writing ROIs to file %s',filename_short);
  end
  % then the vertex list
  vl=border{j};
  n_vertices=size(vl,2);
  % write it
  fwrite(fid,n_vertices,'uint32');
  count=fwrite(fid,vl,'float32');
  if (count ~= 2*n_vertices)
    fclose(fid);
    error('write_rpb:problem_writing_rois', ...
          'Error writing ROIs to file %s',filename_short);
  end
end  

% close the file
fclose(fid);

end
