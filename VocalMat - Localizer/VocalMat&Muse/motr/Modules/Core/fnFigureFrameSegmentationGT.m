function fnFigureFrameSegmentationGT(im,astrctEllipse)

% Makes a figure showing the GT ellipses on the image im.
% astrctEllipse is a 1-D structure array, with
%   fields m_fX, m_fY, m_fA, m_fB, m_fTheta
%
% If astrctEllipse is not given, just plot the frame.

% Deal with args
if nargin<2
  astrctEllipse=[];
end
  
% Make the figure.
figure;
imagesc(im);
colormap(gray)
set(gca,'xtick',[]);
set(gca,'ytick',[]);
if ~isempty(astrctEllipse)
  clr=fnGetMiceColors();
  nEllipse=length(astrctEllipse);
  for j=1:nEllipse
     fnDrawEllipseGT(astrctEllipse(j),...
                     'color',clr(j,:), ...
                     'linewidth',1.5);
  end
end

end
