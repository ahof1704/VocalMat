function acOption = fnTagOptions(acOption, trackFile)
%
load(trackFile);
X = cat(1, astrctTrackers.m_afX);
Y = cat(1, astrctTrackers.m_afY);
A = cat(1, astrctTrackers.m_afA);
B = cat(1, astrctTrackers.m_afB);
T = cat(1, astrctTrackers.m_afTheta);
for i=1:length(acOption)
   iFrame = acOption{i}.iFrame;
   for j=1:size(X,1)
      baseEllipses(j) = struct('m_fX',X(j,iFrame), 'm_fY',Y(j,iFrame), 'm_fA',A(j,iFrame), 'm_fB',B(j,iFrame), 'm_fTheta',T(j,iFrame));
   end
   acEllipses = acOption{i}.acEllipses;
   iOptionNum = length(acEllipses);
   afMatchDist = zeros(1,iOptionNum);
   for j=1:iOptionNum
      [aiAssignment, afMatchDist(j)] = fnMatchTrackers(baseEllipses, acEllipses{j});
   end
   [fMax, acOption{i}.iTrueInd] = min(afMatchDist); 
end
