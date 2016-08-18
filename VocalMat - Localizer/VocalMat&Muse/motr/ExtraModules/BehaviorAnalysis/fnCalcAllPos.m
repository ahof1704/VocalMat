function astrctAllPos = fnCalcAllPos(astrctTrackers)
iNumMice = length(astrctTrackers);
for k=1:iNumMice
    astrctAllPos(k).Cx = astrctTrackers(k).m_afX;
    astrctAllPos(k).Cy = astrctTrackers(k).m_afY;
    astrctAllPos(k).Hx = astrctTrackers(k).m_afX + 0.7*astrctTrackers(k).m_afA.*cos(astrctTrackers(k).m_afTheta);
    astrctAllPos(k).Hy = astrctTrackers(k).m_afY - 0.7*astrctTrackers(k).m_afA.*sin(astrctTrackers(k).m_afTheta);
    astrctAllPos(k).Bx = astrctTrackers(k).m_afX - 0.7*astrctTrackers(k).m_afA.*cos(astrctTrackers(k).m_afTheta);
    astrctAllPos(k).By = astrctTrackers(k).m_afY + 0.7*astrctTrackers(k).m_afA.*sin(astrctTrackers(k).m_afTheta);
    astrctAllPos(k).Nx = astrctTrackers(k).m_afX + astrctTrackers(k).m_afA.*cos(astrctTrackers(k).m_afTheta);
    astrctAllPos(k).Ny = astrctTrackers(k).m_afY - astrctTrackers(k).m_afA.*sin(astrctTrackers(k).m_afTheta);
    astrctAllPos(k).Tx = astrctTrackers(k).m_afX - astrctTrackers(k).m_afA.*cos(astrctTrackers(k).m_afTheta);
    astrctAllPos(k).Ty = astrctTrackers(k).m_afY + astrctTrackers(k).m_afA.*sin(astrctTrackers(k).m_afTheta);
    astrctAllPos(k).a   = astrctTrackers(k).m_afTheta;
    astrctAllPos(k).e   = astrctTrackers(k).m_afA ./ astrctTrackers(k).m_afB;
end
 

