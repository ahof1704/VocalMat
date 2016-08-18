function [a2fMu, a3fCov] = fnEllipseArrayToCov(astrctEllipses)
% Converts [x,y,a,b,theta] representation to Mu,Sig representation 
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology. 
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

iNumSamples = length(astrctEllipses);

a2fMu = zeros(2, iNumSamples);
a3fCov = zeros(2,2, iNumSamples);

for k=1:iNumSamples    
    a2fMu(:,k) = [astrctEllipses(k).m_fX;astrctEllipses(k).m_fY];
    fTheta = astrctEllipses(k).m_fTheta + pi/2;
    Vt = [cos(fTheta),sin(fTheta);
          -sin(fTheta),cos(fTheta)];
       Et = [(astrctEllipses(k).m_fB/2).^2,0;
           0, (astrctEllipses(k).m_fA/2).^2];
    a3fCov(:,:,k) = Vt*Et*Vt';
end;

return;
