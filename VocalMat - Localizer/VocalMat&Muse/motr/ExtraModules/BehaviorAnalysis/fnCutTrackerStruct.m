function astrctTracker = fnCutTrackerStruct(astrctTracker, iStartFrame, iEndFrame)
%
if iStartFrame > length(astrctTracker(1).m_afX)
    astrctTracker = [];
end
iEndFrame = min(length(astrctTracker(1).m_afX), iEndFrame);
for i=1:length(astrctTracker)
    astrctTracker(i).m_afX = astrctTracker(i).m_afX(iStartFrame:iEndFrame);
    astrctTracker(i).m_afY = astrctTracker(i).m_afY(iStartFrame:iEndFrame);
    astrctTracker(i).m_afA = astrctTracker(i).m_afA(iStartFrame:iEndFrame);
    astrctTracker(i).m_afB = astrctTracker(i).m_afB(iStartFrame:iEndFrame);
    astrctTracker(i).m_afTheta = astrctTracker(i).m_afTheta(iStartFrame:iEndFrame);
end
