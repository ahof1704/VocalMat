function stack = load_tiff_series(file_name_template)

% figure out n_row, n_col
frame=imread(sprintf(file_name_template,0));  % read frame 0
[n_row,n_col]=size(frame);

% figure out how many frames there are
i=0;
found_end=false;
while ~found_end
  fid=fopen(sprintf(file_name_template,i),'r');
  if fid==-1
    % unable to open file
    found_end=true;
    n_frame=i-1;
  else
    % opened file
    fclose(fid);
    i=i+1;
  end
end

% load frames
stack=zeros(n_row,n_col,n_frame,'uint16');
for i=1:n_frame
  frame=imread(sprintf(file_name_template,i));
  stack(:,:,i)=frame;
end
