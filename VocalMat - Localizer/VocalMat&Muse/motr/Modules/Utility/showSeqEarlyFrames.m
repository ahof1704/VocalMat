function showSeqEarlyFrames(input_file_name)

% Shows the first 100 or so frames of the input .seq file.  Typically used
% to test that the Motr functions for reading .seq files will work on a
% file in question.

% Read the input file information
seq_file=fnReadSeqInfo(input_file_name);
n_frames=seq_file.m_iNumFrames;
if n_frames==0
  error('.seq file %s says it has zero frames',input_file_name);
end
n_frames_to_show=min(n_frames,100);
frame_this=fnReadFrameFromSeq(seq_file,1);
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
  frame_this=fnReadFrameFromSeq(seq_file,i);
  set(h_im,'cdata',frame_this);
  drawnow;
end

end
