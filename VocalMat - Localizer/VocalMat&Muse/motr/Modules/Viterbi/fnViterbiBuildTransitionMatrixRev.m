function a2fLogTransitionMatrix = fnViterbiBuildTransitionMatrixRev(a2iIntersectingPairs,...
    a2iAllStates, fLogZero,fSwapPenalty)
iNumStates = size(a2iAllStates,1);
a2fTransitionMatrix = eye(iNumStates);

for k=1:size(a2iIntersectingPairs,1)
    % Go over each state....
    I = a2iIntersectingPairs(k,1);
    J = a2iIntersectingPairs(k,2);
    
    for iStateIter=1:iNumStates
        aiCurrState = a2iAllStates(iStateIter,:);
        aiFlippedState = aiCurrState;
        aiFlippedState(aiCurrState == I) = J;
        aiFlippedState(aiCurrState == J) = I;        
        [fDummy,iFlippedStateIndex] = min(sum((a2iAllStates - repmat(aiFlippedState,iNumStates,1)).^2,2));
        a2fTransitionMatrix(iStateIter, iFlippedStateIndex) = 1; %^%fProbSwap;
    end;
end;

a2fTransitionMatrix = a2fTransitionMatrix ./ ...
    repmat(sum(a2fTransitionMatrix,2), 1, iNumStates);

% Compute the log
a2fLogTransitionMatrix = a2fTransitionMatrix;
a2fLogTransitionMatrix(a2fTransitionMatrix == 0) = fLogZero;
a2fLogTransitionMatrix(a2fTransitionMatrix > 0) = ...
    log(a2fTransitionMatrix(a2fTransitionMatrix > 0));

a2fLogTransitionMatrix = (1-eye(iNumStates))*fSwapPenalty + a2fLogTransitionMatrix;
%figure(11);
%imshow(a3fTransitionMatrices(:,:,iFrameIter),'InitialMagnification','fit')

return;

