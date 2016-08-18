function stack = load_multi_image_tiff_file(file_name)

%tic

% old way: very slow on mac
% info=imfinfo(file_name);
% n_frame=length(info);
% for i=1:n_frame
%   frame=imread(file_name,'info',info,'index',i);
%   if i==1
%     [n_row,n_col]=size(frame);
%     stack=zeros(n_row,n_col,n_frame,class(frame));
%   end
%   stack(:,:,i)=frame;
% end

% New way: ~ 4x faster on Mac.

% Save the current state of an annoying warning that the 
% Tiff class seems to throw a lot of.
s=warning('query','MATLAB:imagesci:Tiff:libraryWarning');
state_warning=s.state;

% Turn off said annoying warning.
warning('off','MATLAB:imagesci:Tiff:libraryWarning');

% Read the file.
info=imfinfo(file_name);
n_frame=length(info);
tiff=Tiff(file_name,'r');
for i=1:n_frame
  frame=tiff.read();
  if i==1
    [n_row,n_col]=size(frame);
    stack=zeros(n_row,n_col,n_frame,class(frame));
  end
  stack(:,:,i)=frame;
  if i<n_frame  
    tiff.nextDirectory();
  end
end
tiff.close();

% Restore the state of the annoying warnings.
warning(state_warning,'MATLAB:imagesci:Tiff:libraryWarning');

%toc

end
