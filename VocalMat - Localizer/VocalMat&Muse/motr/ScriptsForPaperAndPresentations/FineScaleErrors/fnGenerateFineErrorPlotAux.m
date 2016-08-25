function strctDiff = fnGenerateFineErrorPlotAux(aiAnnotatedFrames, strctGT1,strctGT2)
%% Compute the difference between annotators...
iNumAnnotatedFrames = length(aiAnnotatedFrames);
iNumMice = 4;
a2fDiffPos = zeros(iNumAnnotatedFrames,iNumMice);
a2fDiffPosX = zeros(iNumAnnotatedFrames,iNumMice);
a2fDiffPosY = zeros(iNumAnnotatedFrames,iNumMice);
a2fDiffOriDeg = zeros(iNumAnnotatedFrames,iNumMice);
a2fDiffAspectRatio = zeros(iNumAnnotatedFrames,iNumMice);
a2fDiffMajorAxis = zeros(iNumAnnotatedFrames,iNumMice);
a2fDiffMinorAxis= zeros(iNumAnnotatedFrames,iNumMice);
for iIter=1:iNumAnnotatedFrames
    for iMouseIter=1:iNumMice
        fDiffX = strctGT1.m_astrctEllipses(iIter).m_astrctEllipse(iMouseIter).m_fX - ...
            strctGT2.m_astrctEllipses(iIter).m_astrctEllipse(iMouseIter).m_fX ;
        
        fDiffY = strctGT1.m_astrctEllipses(iIter).m_astrctEllipse(iMouseIter).m_fY - ...
            strctGT2.m_astrctEllipses(iIter).m_astrctEllipse(iMouseIter).m_fY ;
        
        a2fDiffPos(iIter,iMouseIter) =  sqrt(fDiffX.^2+fDiffY.^2);
        a2fDiffPosX(iIter,iMouseIter) =  fDiffX;
        a2fDiffPosY(iIter,iMouseIter) =  fDiffY;
        
        fDiffOri = (strctGT1.m_astrctEllipses(iIter).m_astrctEllipse(iMouseIter).m_fTheta - strctGT2.m_astrctEllipses(iIter).m_astrctEllipse(iMouseIter).m_fTheta)/pi*180;

        
        
        if 360-abs(fDiffOri) < abs(fDiffOri)
            fDiffOri = (360-abs(fDiffOri)) * sign(fDiffOri);
        end
        
        if 180-abs(fDiffOri) < abs(fDiffOri)
            fDiffOri = (180-abs(fDiffOri)) * sign(fDiffOri);
        end
                
        
        a2fDiffOriDeg(iIter,iMouseIter) = fDiffOri ;
        a2fDiffMajorAxis(iIter,iMouseIter) =(strctGT1.m_astrctEllipses(iIter).m_astrctEllipse(iMouseIter).m_fA - strctGT2.m_astrctEllipses(iIter).m_astrctEllipse(iMouseIter).m_fA);
        a2fDiffMinorAxis(iIter,iMouseIter) =(strctGT1.m_astrctEllipses(iIter).m_astrctEllipse(iMouseIter).m_fB - strctGT2.m_astrctEllipses(iIter).m_astrctEllipse(iMouseIter).m_fB);        

        a2fDiffAspectRatio(iIter,iMouseIter) =(strctGT1.m_astrctEllipses(iIter).m_astrctEllipse(iMouseIter).m_fA/strctGT1.m_astrctEllipses(iIter).m_astrctEllipse(iMouseIter).m_fB - ...
        strctGT2.m_astrctEllipses(iIter).m_astrctEllipse(iMouseIter).m_fA/strctGT2.m_astrctEllipses(iIter).m_astrctEllipse(iMouseIter).m_fB);
        
    end
end


strctDiff.m_a2fDiffPos = a2fDiffPos; 
strctDiff.m_a2fDiffPosX = a2fDiffPosX; 
strctDiff.m_a2fDiffPosY  = a2fDiffPosY; 
strctDiff.m_a2fDiffOriDeg  = a2fDiffOriDeg; 
strctDiff.m_a2fDiffAspectRatio  = a2fDiffAspectRatio;
strctDiff.m_a2fDiffMajorAxis = a2fDiffMajorAxis;
strctDiff.m_a2fDiffMinorAxis = a2fDiffMinorAxis;

return;
