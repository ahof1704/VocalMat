function fnDrawScene(a2iLForeground, astrctPredictedEllipses,astrctObservedEllipses)
iNumBlobs = length(astrctObservedEllipses);
figure(2);
H = axis;
%clf;
imshow(a2iLForeground,[]);
hold on;
for i=1:length(astrctPredictedEllipses)
    fnPlotEllipse(astrctPredictedEllipses(i).m_fX,...
        astrctPredictedEllipses(i).m_fY,...
        astrctPredictedEllipses(i).m_fA,...
        astrctPredictedEllipses(i).m_fB,...
        astrctPredictedEllipses(i).m_fTheta,'r',1);
    text(double(astrctPredictedEllipses(i).m_fX),double(astrctPredictedEllipses(i).m_fY),num2str(i),'color','r');
end;
for i=1:iNumBlobs
    text(double(astrctObservedEllipses(i).m_fX+10),...
    double(astrctObservedEllipses(i).m_fY+5),['blob ',num2str(i)],'color','b');
end;
if ~all(abs(H - [0 1 0 1]) == 0)
    axis(H);
end;
hold off;
%title(sprintf('The assignment problem (%d x %d)', iNumMiceTrackers, iNumBlobs));
return;
