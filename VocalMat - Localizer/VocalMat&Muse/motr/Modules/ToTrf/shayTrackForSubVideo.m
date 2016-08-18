function astrctTrackers=shayTrackForSubVideo(astrctTrackers,iFirst,iLast)

% Produces a Shay-style astrctTrackers structure array for a "subvideo"
% of the original, that goes from frame iFirst to frame iLast (1-indexed), 
% inclusive.

n_mice=length(astrctTrackers);
for k=1:n_mice
  astrctTrackers(k).m_afX=astrctTrackers(k).m_afX(iFirst:iLast);
  astrctTrackers(k).m_afY=astrctTrackers(k).m_afY(iFirst:iLast);
  astrctTrackers(k).m_afA=astrctTrackers(k).m_afA(iFirst:iLast);
  astrctTrackers(k).m_afB=astrctTrackers(k).m_afB(iFirst:iLast);
  astrctTrackers(k).m_afTheta=astrctTrackers(k).m_afTheta(iFirst:iLast);
end

end
