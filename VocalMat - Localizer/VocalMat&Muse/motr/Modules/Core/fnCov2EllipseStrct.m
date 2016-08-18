function [strctEllipse] = fnCov2EllipseStrct(a2fMu,a3fCov)
% Converts Mu,Sig representation to [x,y,a,b,theta] representation.
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)
iNumSamples = size(a2fMu,2);
strctEllipse.m_afX = zeros(1,iNumSamples);
strctEllipse.m_afY = zeros(1,iNumSamples);
strctEllipse.m_afA = zeros(1,iNumSamples);
strctEllipse.m_afB = zeros(1,iNumSamples);
strctEllipse.m_afTheta = zeros(1,iNumSamples);

for k=1:iNumSamples
    if isnan(a2fMu(1,k))
        strctEllipse.m_afX(k) = NaN;
        strctEllipse.m_afY(k) = NaN;
        strctEllipse.m_afA(k) = NaN;
        strctEllipse.m_afB(k) = NaN;
        strctEllipse.m_afTheta(k) = NaN;
    else
        [V,E]=eig(a3fCov(:,:,k));
        sqrtS = sqrt((E([1,4])));
        [fDummy, iIndex] = max(sqrtS);


        strctEllipse.m_afX(k) = a2fMu(1,k);
        strctEllipse.m_afY(k) = a2fMu(2,k);
        strctEllipse.m_afA(k) =  2*max(sqrtS);
        strctEllipse.m_afB(k) =  2*min(sqrtS);
        strctEllipse.m_afTheta(k) = atan2(-V(2,iIndex),V(1,iIndex));
        if strctEllipse.m_afTheta(k) < 0
            strctEllipse.m_afTheta(k) = strctEllipse.m_afTheta(k) + 2*pi;
        end;
    end;

 end;

