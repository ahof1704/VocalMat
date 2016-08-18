function [astrctEllipse] = fnCov2EllipseArrayStrct(a2fMu,a3fCov)
% Converts Mu,Sig representation to [x,y,a,b,theta] representation.
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)
iNumSamples = size(a2fMu,2);
% pre-allocate the ouput, both for speed and so astrctEllipse gets set
% even if iNumSamples==0
astrctEllipse=...
  struct('m_fX',cell(1,iNumSamples),...
         'm_fY',cell(1,iNumSamples),...
         'm_fA',cell(1,iNumSamples),...
         'm_fB',cell(1,iNumSamples),...
         'm_fTheta',cell(1,iNumSamples));
% astrctEllipse is now a 1xiNumSamples struct array with the proper fields       
for k=1:iNumSamples
    if isnan(a2fMu(1,k))
        strctEllipse.m_fX = NaN;
        strctEllipse.m_fY = NaN;
        strctEllipse.m_fA = NaN;
        strctEllipse.m_fB = NaN;
        strctEllipse.m_fTheta = NaN;
    else
        [V,E]=eig(a3fCov(:,:,k));
        sqrtS = sqrt((E([1,4])));
        [fDummy, iIndex] = max(sqrtS);

        strctEllipse.m_fX = a2fMu(1,k);
        strctEllipse.m_fY = a2fMu(2,k);
        strctEllipse.m_fA =  2*max(sqrtS);
        strctEllipse.m_fB =  2*min(sqrtS);
        strctEllipse.m_fTheta = atan2(-V(2,iIndex),V(1,iIndex));
        if strctEllipse.m_fTheta < 0
            strctEllipse.m_fTheta = strctEllipse.m_fTheta + 2*pi;
        end;
    end;

    astrctEllipse(k) = strctEllipse;
end;

