function a2bCorrectIdentification = fnGenerateIdentityErrorPlotAuxNew(astrctResultGT, astrctResultTrackers, aiSubset)

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
a2bCorrectIdentification =  zeros(iNumFrames, iNumMice);
for iIter=1:iNumFrames
    iFrameIter= (iIter);
    
    a2fDist = zeros(iNumMice,iNumMice);
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
        end
    end
    
    a2fDist(isnan(a2fDist)) = 5000;
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
    a2bCorrectIdentification(iIter,:) = double(a2iAllPerm(iMinIndex,:) == [1,2,3,4]);
    a2bCorrectIdentification(iIter,a2fDist(aiInd)== 5000) = NaN;
 end


return;
