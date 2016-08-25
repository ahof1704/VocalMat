function [bFailed,astrctReliableEllipses,fTotalError] = fnRiskyInit(a2iFrame, strctAdditionalInfo,iNumMice,iNumReinitializations)
a2fFrame = double(a2iFrame)/255;
fTotalError = 0;

[a2iForeground,iNumBlobs] = fnSegmentForegroundWithoutBackgroundSubtraction(a2fFrame, strctAdditionalInfo);
if iNumBlobs >= iNumMice
    a2bClosed=imclose(a2iForeground>0,ones(5,5));
    [a2iForeground,iNumBlobs] = bwlabel(a2bClosed);
end;

abReliable = zeros(1,iNumBlobs)>0;
clear astrctReliableEllipses
afArea = zeros(1,iNumBlobs);
for iBlobIter=1:iNumBlobs
    a2bTmp = a2iForeground == iBlobIter;
    [aiY,aiX]=find(a2bTmp);
    [afMu, a2fCov]=fnFitGaussian([aiX,aiY]);
    astrctReliableEllipses(iBlobIter) = fnCov2EllipseArrayStrct(afMu, a2fCov);
    abReliable(iBlobIter) = fnIsReasonableMouseBlob2(astrctReliableEllipses(iBlobIter));
    afArea(iBlobIter) = length(aiX);
end;
if all(abReliable) && iNumBlobs < iNumMice
    % Take largest blob and make it unreliable....
    [fDummy,iIndex] = max(afArea);
    abReliable(iIndex) = false;
end;
if all(abReliable) && iNumBlobs < iNumMice
    bFailed= true;
    astrctReliableEllipses = [];
    return;
end;

astrctReliableEllipses = astrctReliableEllipses(abReliable);

iNumUnreliableBlobs = sum(~abReliable);
iNumReliable = sum(abReliable);

if iNumReliable == iNumMice && iNumBlobs == iNumMice
    bFailed= false;
    return;
end;
 
    
iNumMiceNeededToBeDetected = iNumMice - iNumReliable;
iNumMicePerBlob = iNumMiceNeededToBeDetected / iNumUnreliableBlobs;
if iNumMicePerBlob == 1 || round(iNumMicePerBlob) ~= iNumMicePerBlob 
    bFailed= true;
    astrctReliableEllipses = [];
    return;
end;
aiUnreliable = find(~abReliable);
astrctOpt = cell(1,length(aiUnreliable));
bFailed = false;

for iBlobIter=1:length(aiUnreliable)
    a2bTmp = a2iForeground == aiUnreliable(iBlobIter);
    [aiY,aiX]=find(a2bTmp);

    % maybe repeat this step...

    [idx, Clusters] = kmeans([aiX,aiY], iNumMicePerBlob);
    % estimate ellipses and run EM
    a2fMu = zeros(2,iNumMicePerBlob);
    a3fCov = zeros(2,2,iNumMicePerBlob);
    for iEllipseIter=1:iNumMicePerBlob
        [a2fMu(:,iEllipseIter), a3fCov(:,:,iEllipseIter)] = ...
            fnFitGaussian([aiX(idx==iEllipseIter),aiY(idx==iEllipseIter)]);
    end;
    astrctKMeansEllipses = fnCov2EllipseArrayStrct(a2fMu, a3fCov);

    [astrctOpt{iBlobIter},fMinError] = fnSolveUsingConstrainedEM(astrctKMeansEllipses, ...
        [aiX,aiY], strctAdditionalInfo,a2iFrame,iNumReinitializations,true);
    fTotalError = fTotalError + fMinError;
    if isempty(astrctOpt{iBlobIter})
        bFailed= true;
        astrctReliableEllipses = [];
        return;
    end;
end;

iCounter = length(astrctReliableEllipses)+1;
for iBlobIter=1:length(aiUnreliable)

    astrctReliableEllipses(iCounter:iCounter+length(astrctOpt{iBlobIter})-1) = ...
        astrctOpt{iBlobIter};
    iCounter=iCounter+length(astrctOpt{iBlobIter});
end;

return;