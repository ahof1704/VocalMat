function astrctTrackers=shayTrackFromTrx(trx)

% Convert a Ctrax/Jaaba-style trx structure array to a Shay-style 
% astrctTrackers structure array

n_mice=length(trx);
astrctTrackers= ...
  struct('m_afX',cell(n_mice,1), ...
         'm_afY',cell(n_mice,1), ...
         'm_afA',cell(n_mice,1), ...
         'm_afB',cell(n_mice,1), ...
         'm_afTheta',cell(n_mice,1));
for k=1:n_mice
  astrctTrackers(k).m_afX=trx(k).x;
  astrctTrackers(k).m_afY=trx(k).y;
  astrctTrackers(k).m_afA=2*trx(k).a;  % convert from quarter-major to semi-major
  astrctTrackers(k).m_afB=2*trx(k).b;  % convert from quarter-major to semi-major
  astrctTrackers(k).m_afTheta= -trx(k).theta;  % trx files use a different (and probably better) theta convention
end

end
