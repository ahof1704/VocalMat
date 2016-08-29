function [aiPath, a2fLogProb] = fnViterbiForwardBackward(iNumStates, iNumFrames, a3fTransitionMatrices,a2fLikelihood)
% Initialize
a2fLogProb = zeros(iNumStates, iNumFrames);
a2iUpdateLog = zeros(iNumStates, iNumFrames);
a2fLogProb(:,1) = log(1/iNumStates) + a2fLogProb(:, 1);
for iStateIter=1:iNumStates
   a2iUpdateLog(iStateIter,1) = iStateIter;
end;
% Forward algorithm

for iFrameIter=2:iNumFrames
    if size(a3fTransitionMatrices,3) > 1
        a2fLogTransition = a3fTransitionMatrices(:,:,iFrameIter);
    else
        a2fLogTransition  = a3fTransitionMatrices;
    end;
    
    for iStateIter=1:iNumStates
        afLogTransition = a2fLogTransition(iStateIter,:);
         [fMaxLogProb, iMaxIndex] = max( a2fLogProb(:, iFrameIter-1) + afLogTransition');
        a2iUpdateLog(iStateIter, iFrameIter) = iMaxIndex;
        a2fLogProb(iStateIter,iFrameIter) = fMaxLogProb + a2fLikelihood(iStateIter,iFrameIter) ;
    end;
end;
% Backward algorithm
[fDummy, iMaxIndex] = max(a2fLogProb(:, iNumFrames));
aiPath = zeros(1,iNumFrames);
aiPath(iNumFrames) = iMaxIndex;
iCurrPos = iMaxIndex;
for iBacktrack=iNumFrames-1:-1:1
    iCurrPos = a2iUpdateLog(iCurrPos, iBacktrack+1);
    aiPath(iBacktrack) = iCurrPos;
end;
return;
