function fnFigureTrackFrame(fn,i,astrctTracker)

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

% Make the figure.
figure;
imagesc(im);
colormap(gray)
set(gca,'xtick',[]);
set(gca,'ytick',[]);
if ~isempty(astrctTracker)
  clr=fnGetMiceColors();
  trackerAltThis=sliceTracker(astrctTracker,i);
    % 5 x nTracker, each col a direllipse
  nTracker=size(trackerAltThis,2);
  for j=1:nTracker
     fnDrawDirellipse(trackerAltThis(:,j),...
                      'color',clr(j,:), ...
                      'linewidth',0.5);
  end
end

end
