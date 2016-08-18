function astrctBehaviors = fnDetectHeadProximity(headDist, miceInd)
%
[iNumPairs, iNumFrames] = size(headDist);
j = 1;

for pairInd=1:iNumPairs
    distThrHystExt = 16;
    distThrHyst = 20;
    distThr = 16;
    iFrameStart = find(headDist(pairInd,2:end) < distThr & headDist(pairInd,1:end-1) > distThr) + 1;
    iFrameEnd = find(headDist(pairInd,2:end) > distThr & headDist(pairInd,1:end-1) < distThr);
    if iFrameStart(1) > iFrameEnd(1)
        iFrameStart = [1, iFrameStart];
    end
    if iFrameEnd(end) < iFrameStart(end)
        iFrameEnd = [iFrameEnd iNumFrames];
    end
    for i=1:length(iFrameEnd)-1
        if sum(headDist(pairInd,iFrameEnd(i):iFrameStart(i+1))-distThrHyst) < distThrHystExt
            iFrameEnd(i) = 0; iFrameStart(i+1) = 0;
        end
    end
    iFrameStart = iFrameStart(find(iFrameStart>0));
    iFrameEnd = iFrameEnd(find(iFrameEnd>0));
   
    aMiceInd = miceInd(pairInd,:);
    for i=1:length(iFrameStart)
        astrctBehaviors(j).m_aMice = aMiceInd;
        astrctBehaviors(j).m_iPair = pairInd;
        astrctBehaviors(j).m_iStart = iFrameStart(i);
        astrctBehaviors(j).m_iEnd = iFrameEnd(i);
        j = j+1;
    end
end
[fs, perm] = sort([astrctBehaviors.m_iStart]);
astrctBehaviors = astrctBehaviors(perm);

