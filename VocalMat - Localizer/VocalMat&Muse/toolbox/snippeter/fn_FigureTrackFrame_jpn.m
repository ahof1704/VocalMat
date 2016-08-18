function fn_FigureTrackFrame_jpn(fn,i,astrctTracker)

% Makes a figure showing the track at frame i.
% fn is the filename of a .seq file.
% astrctTrack is a 1 x nMice structure array, with
%   fields m_fX, m_fY, m_fA, m_fB, m_fTheta
%
% If astrctTrack is not given, just plot the frame.

% Deal with args
if nargin<3
  astrctTracker=[];
end
  
% Get the frame.
info=fnReadVideoInfo(fn);
im=fnReadFrameFromVideo(info,i);
%%%%%CHANGED on 10/29/12 by jpn
% image_matrix_r = imrotate(im,270);%rotates by 90  
% im = image_matrix_r;
% image_matrix_r = im;
% Make the figure.
figure;
imagesc(im);%%%%%CHANGED on 10/29/12 by jpn
colormap(gray)
% set(gca,'xtick',[]);
% set(gca,'ytick',[]);
set(gca,'dataaspectratio',[1 1 1])
%%%%%CHANGED on 10/29/12 by jpn
% axis ij
axis xy 
if ~isempty(astrctTracker)
  clr=fnGetMiceColors();
  trackerAltThis=sliceTracker(astrctTracker,i);
    % 5 x nTracker, each col a direllipse
  nTracker=size(trackerAltThis,2);
  for j=1:nTracker
     drawDirellipse(trackerAltThis(:,j),...
                    'color',clr(j,:), ...
                    'linewidth',0.5);
  end
end

end
