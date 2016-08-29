function showMj2EarlyFrames(input_file_name)

% Shows the first 100 or so frames of the input .mj2 file.  Typically used
% to test that a Motion JPEG 2000 file is valid.

% Read the input file information
vr=VideoReader(input_file_name);
info=get(vr);
n_frames=info.NumberOfFrames;
if n_frames==0
  error('.mj2 file %s says it has zero frames',input_file_name);
end
n_frames_to_show=min(n_frames,100);
frame_this=vr.read(1);
[n_rows,n_cols]=size(frame_this);
h_fig=figure('color','w');  %#ok
colormap(gray(256));
h_axes=axes('box','on', ...
            'layer','top', ...
            'ydir','reverse', ...
            'dataaspectratio',[1 1 1], ...
            'xlim',[0.5 n_cols+0.5], ...
            'ylim',[0.5 n_rows+0.5]);
h_im=image('parent',h_axes,'cdata',frame_this);
drawnow;
title(input_file_name,'interpreter','none');
drawnow;
for i=2:n_frames_to_show
  frame_this=vr.read(i);
  set(h_im,'cdata',frame_this);
  drawnow;
end

end

