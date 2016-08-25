function strctHeadPos = fnCalcHeadPos(astrctTrackers)
iNumMice = length(astrctTrackers);
for k=1:iNumMice
    strctHeadPos(k).x = astrctTrackers(k).m_afX + astrctTrackers(k).m_afA.*cos(astrctTrackers(k).m_afTheta);
    strctHeadPos(k).y = astrctTrackers(k).m_afY - astrctTrackers(k).m_afA.*sin(astrctTrackers(k).m_afTheta);
    strctHeadPos(k).a = astrctTrackers(k).m_afTheta;
end
 

