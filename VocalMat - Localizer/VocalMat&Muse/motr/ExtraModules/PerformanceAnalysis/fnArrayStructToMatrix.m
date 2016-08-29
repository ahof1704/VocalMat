function a2fData = fnArrayStructToMatrix(astrctTracker)
iNumFrames = length(astrctTracker.m_afX);
a2fData = zeros(5, iNumFrames);
a2fData(1,:) = astrctTracker.m_afX;
a2fData(2,:) = astrctTracker.m_afY;
a2fData(3,:) = astrctTracker.m_afA;
a2fData(4,:) = astrctTracker.m_afB;
a2fData(5,:) = astrctTracker.m_afTheta;
return;
