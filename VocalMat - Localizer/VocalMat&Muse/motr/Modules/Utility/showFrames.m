function h_fig=showFrames(vid)

% Throw up a figure that shows all the frames in vid.  Mainly used for
% testing purposes.

% Read the input file information
[n_rows,n_cols,n_frames]=size(vid);
if n_frames==0
  return
end
frame_this=vid(:,:,1);
h_fig=figure('color','w');
colormap(gray(256));
h_axes=axes('box','on', ...
            'layer','top', ...
            'ydir','reverse', ...
            'dataaspectratio',[1 1 1], ...
            'clim',[0 255], ...
            'xlim',[0.5 n_cols+0.5], ...
            'ylim',[0.5 n_rows+0.5]);
h_im=image('parent',h_axes,'cdata',frame_this);
drawnow;
for i=2:n_frames
  frame_this=vid(:,:,i);
  set(h_im,'cdata',frame_this);
  drawnow;
end

end

