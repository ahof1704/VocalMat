function [a2iAssignment, a2fMatchError, afMinPos] = fnGenerateIdentityErrorPlotAux(astrctResultGT, astrctResultTrackers, aiSubset)

strctStandardDeviation.m_fX= 1.9700;
strctStandardDeviation.m_fY=1.8150;
strctStandardDeviation.m_fA= 2.4089;
strctStandardDeviation.m_fB= 1.4079;
strctStandardDeviation.m_fTheta= 0.0941;


if ~exist('aiSubset','var')
    iNumFrames = size(astrctResultGT.m_a2fX,1);
else
    iNumFrames = length(aiSubset);

end

iNumMice = 4;

a2iAssignment = zeros(iNumFrames, iNumMice);
a2fMatchError =  zeros(iNumFrames, iNumMice);
afMinPos = zeros(1,iNumFrames);

for iIter=1:iNumFrames
    iFrameIter= aiSubset(iIter);
    
    a2fDist = zeros(iNumMice,iNumMice);
    a2fPosDist = zeros(iNumMice,iNumMice);
    for iMouseIter1=1:iNumMice
        strctEllipse1.m_fX = astrctResultGT.m_a2fX(iFrameIter,iMouseIter1);
        strctEllipse1.m_fY = astrctResultGT.m_a2fY(iFrameIter,iMouseIter1);
        strctEllipse1.m_fA = astrctResultGT.m_a2fA(iFrameIter,iMouseIter1);
        strctEllipse1.m_fB = astrctResultGT.m_a2fB(iFrameIter,iMouseIter1);
        strctEllipse1.m_fTheta = astrctResultGT.m_a2fTheta(iFrameIter,iMouseIter1);
        
        for iMouseIter2=1:iNumMice
            strctEllipse2.m_fX = astrctResultTrackers.m_a2fX(iFrameIter,iMouseIter2);
            strctEllipse2.m_fY = astrctResultTrackers.m_a2fY(iFrameIter,iMouseIter2);
            strctEllipse2.m_fA = astrctResultTrackers.m_a2fA(iFrameIter,iMouseIter2);
            strctEllipse2.m_fB = astrctResultTrackers.m_a2fB(iFrameIter,iMouseIter2);
            strctEllipse2.m_fTheta = astrctResultTrackers.m_a2fTheta(iFrameIter,iMouseIter2);
              
            a2fDist(iMouseIter1,iMouseIter2) = fnNormalizedDistance(strctEllipse1,strctEllipse2, strctStandardDeviation);
            a2fPosDist(iMouseIter1,iMouseIter2) = sqrt((astrctResultGT.m_a2fX(iFrameIter,iMouseIter1)-astrctResultGT.m_a2fX(iFrameIter,iMouseIter2)).^2+...
                                                                                (astrctResultGT.m_a2fY(iFrameIter,iMouseIter1)-astrctResultGT.m_a2fY(iFrameIter,iMouseIter2)).^2);
        end
    end
    
    % For each possible permutation, compute the associated cost
    a2iAllPerm = fliplr(perms(1:iNumMice));
    iNumPerms = size(a2iAllPerm,1);
    afPermCost = zeros(1,iNumPerms);
    for iPermIter=1:iNumPerms
        % Map strctP1[1,2,3,4] to strctP2[a2iAllPerm(iPermIter,:)]
        aiInd = sub2ind(size(a2fDist), 1:iNumMice, a2iAllPerm(iPermIter,:));
        afPermCost(iPermIter) = sum(a2fDist(aiInd));
    end
    [fDummy,iMinIndex]= min(afPermCost);
    a2iAssignment(iIter,:) = a2iAllPerm(iMinIndex,:);
    aiInd = sub2ind(size(a2fDist), 1:iNumMice, a2iAllPerm(iMinIndex,:));
    a2fMatchError(iIter,:) = a2fDist(aiInd);
    
    % Huddling?
    afMinPos(iIter)= min(a2fPosDist(a2fPosDist>0));
end


return;
