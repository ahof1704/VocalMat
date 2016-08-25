function [a2fMu, a3fCov] = fnTrackerArrayToCov(astrctTrackers)
% Converts [x,y,a,b,theta] representation to Mu,Sig representation 
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology. 
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

iNumMice = length(astrctTrackers);
iNumFrames = length(astrctTrackers(1).m_afX);

a2fMu = zeros(2, iNumMice, iNumFrames);
a3fCov = zeros(2,2, iNumMice, iNumFrames);

for k=1:iNumMice
   a2fMu(1,k,:) = astrctTrackers(k).m_afX;
   a2fMu(2,k,:) = astrctTrackers(k).m_afY;
end
% for f=1:iNumFrames    
%    for k=1:iNumMice
%       fTheta = astrctTrackers(k).m_afTheta(f) + pi/2;
%       Vt = [cos(fTheta),sin(fTheta);
%          -sin(fTheta),cos(fTheta)];
%       Et = [(astrctTrackers(k).m_afB(f)/2).^2, 0;
%          0, (astrctTrackers(k).m_afA(f)/2).^2];
%       a3fCov(:,:,k,f) = Vt*Et*Vt';
%    end;
% end;

return;
