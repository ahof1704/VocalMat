function a2fLogTransitionMatrix = fnViterbiBuildTransitionMatrix(a2iIntersectingPairs,...
    a2iAllStates, fLogZero, a2fArea,afVelocities,afAxisChange)
iNumStates = size(a2iAllStates,1);
a2fTransitionMatrix = eye(iNumStates);
% a2fTransitionMatrix = zeros(iNumStates);

for k=1:size(a2iIntersectingPairs,1)
    % Go over each state....
    I = a2iIntersectingPairs(k,1);
    J = a2iIntersectingPairs(k,2);
%     
%     fVel = max(afVelocities([I,J]));
%     fArea = a2fArea(I,J);
%     fAx = max(afAxisChange([I,J]));
%     fProbSwap=fnGetSwapProb(fVel, fArea, fAx);
    
    for iStateIter=1:iNumStates
        aiCurrState = a2iAllStates(iStateIter,:);
        aiFlippedState = aiCurrState;
        aiFlippedState(aiCurrState == I) = J;
        aiFlippedState(aiCurrState == J) = I;        
        [fDummy,iFlippedStateIndex] = min(sum((a2iAllStates - repmat(aiFlippedState,iNumStates,1)).^2,2));
        a2fTransitionMatrix(iStateIter, iFlippedStateIndex) = 1; %^%fProbSwap;
    end;
end;
% Normalize transition matrix
% for iStateIter=1:iNumStates
%     a2fTransitionMatrix(iStateIter, iStateIter) = ...
%         1-max(a2fTransitionMatrix(iStateIter, setdiff(1:iNumStates,iStateIter)));
% end;
%     

a2fTransitionMatrix = a2fTransitionMatrix ./ ...
    repmat(sum(a2fTransitionMatrix,2), 1, iNumStates);

% Compute the log
a2fLogTransitionMatrix = a2fTransitionMatrix;
a2fLogTransitionMatrix(a2fTransitionMatrix == 0) = fLogZero;
a2fLogTransitionMatrix(a2fTransitionMatrix > 0) = ...
    log(a2fTransitionMatrix(a2fTransitionMatrix > 0));

fSwapPenalty = -500;
a2fLogTransitionMatrix = (1-eye(iNumStates))*fSwapPenalty + a2fLogTransitionMatrix;
%figure(11);
%imshow(a3fTransitionMatrices(:,:,iFrameIter),'InitialMagnification','fit')

return;

function fProbSwap=fnGetSwapProb(fVel, fArea, fAx)
if fVel > 20
    fProbVel = 0.95;
elseif fVel > 12
    fProbVel = 0.8;
else
    fProbVel = 0.2;
end;

if fArea > 300
    fProbVel = 0.95;
elseif fArea > 260
    fProbVel = 0.8;
else
    fProbVel = 0.2;
end;


if fAx > 10
    fProbAx = 0.95;
elseif fAx > 6
    fProbAx = 0.8;
else
    fProbAx = 0.2;
end;

fProbSwap = fProbVel * fProbVel * fProbAx;

return;
