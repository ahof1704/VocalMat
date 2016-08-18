function astrctIntervals = fnDiscardSmallIntervals(astrctIntervals, iThreshold)
aiLength = cat(1,astrctIntervals.m_iLength);
astrctIntervals = astrctIntervals(aiLength > iThreshold);
return;
