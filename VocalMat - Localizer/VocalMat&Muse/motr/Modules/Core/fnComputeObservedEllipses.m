function astrctObservedEllipses = fnComputeObservedEllipses(a2iLForeground, iNumBlobs)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

% Fits an ellipse to each of the _blobs_ in a2iLForeground.  These are
% returned in a 1 x iNumBlobs structure array with the usual direllipse
% fields (m_fX, m_fY, m_fA, m_fB, m_fTheta).

a2fMu = zeros(2,iNumBlobs);
a3fCov = zeros(2,2,iNumBlobs);
for iBlobIter=1:iNumBlobs
    [aiY,aiX] = find(a2iLForeground == iBlobIter);
    [a2fMu(:,iBlobIter), a3fCov(:,:,iBlobIter)] = fnFitGaussian([aiX,aiY]);
end;
astrctObservedEllipses = fnCov2EllipseArrayStrct(a2fMu,a3fCov);

return;

