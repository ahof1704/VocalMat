function a2iIdentities = fnCorrectIdentities(astrctTrackers, strctAdditionalInfo, aiFramesToAnalyze)
%
%Copyright (c) 2008 Shay Ohayon, California Institute of Technology. 
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)
global g_bVERBOSE
g_bVERBOSE=false;
bLOAD_GT = false;

drawnow

iNumMice = length(astrctTrackers);
iNumClassifiers =size(strctAdditionalInfo.m_strctMiceIdentityClassifier.a2fW,2);
iNumFrames = length(aiFramesToAnalyze);
a2iAllStates = fliplr(perms(1:iNumMice));
iNumStates = size(a2iAllStates,1);

if bLOAD_GT
    aiCurrectStatePath = fnAuxLoadGT(iNumFrames,iNumMice,iNumStates,a2iAllStates,astrctTrackers);
end;

a2fLikelihood = fnAuxComputeLikelihood1AA_V2(iNumStates,iNumMice, iNumClassifiers, iNumFrames,...
    astrctTrackers,a2iAllStates,strctAdditionalInfo,aiFramesToAnalyze);

%figure;imagesc((bsxfun(@rdivide, exp(a2fLikelihood), sum(exp(a2fLikelihood),1))))
% Noramlize likelihood
a2fLikelihood = log(bsxfun(@rdivide, exp(a2fLikelihood), sum(exp(a2fLikelihood),1)));

[astrctIntersectIntervals,acIntersectingPairs,a3fIntersectionArea] = ...
    fnAuxFindIntersection(iNumMice, iNumFrames, astrctTrackers,aiFramesToAnalyze);

fSwapPenalty = -50;
a3fTransitionMatrices = fnAuxcomputeTransitionMatrices(...
    iNumFrames, iNumStates,a2iAllStates, astrctIntersectIntervals,...
    acIntersectingPairs, fSwapPenalty);

fprintf('Running Viterbi...');
aiPath = fndllViterbi(a3fTransitionMatrices,a2fLikelihood);
a2iIdentities = a2iAllStates(aiPath,:);
fprintf('Done!\n');
%[aiPath, a2fLogProb] = fnViterbiForwardBackward(iNumStates, iNumFrames, ...
%    a3fTransitionMatrices,a2fLikelihood);

if g_bVERBOSE
    figure(11);
    clf;
    imagesc(a2fLikelihood);
    hold on;
    plot(aiPath,'g.');
    set(gca,'YTick',1:24)
    axis xy
    xlabel('Frames');
    ylabel('States');
   
    figure(14);
    clf;
    hold on;
    for k=1:length(astrctIntersectIntervals)
        hPatch = fnBoxPatch(astrctIntersectIntervals(k).m_iStart,...
            astrctIntersectIntervals(k).m_iEnd,1,24, [0.95 0.9 0.85 ]);
    end;
    plot(aiFramesToAnalyze,aiPath,'m.');
    
    % [fDummy, aiMaxIndex] = max(a2fLikelihood,[],1);
    % h2=plot(aiFramesToAnalyze,aiMaxIndex,'b.','MarkerSize',5);
    xlabel('Frames');
    ylabel('States');

    if bLOAD_GT
         plot(aiCurrectStatePath,'co');
    end
    %h3=plot(aiFramesToAnalyze,aiPath,'m.');
    %legend([h1,h2,h3],'Intersection','ML','Viterbi')
end;

% Remove spurious swaps during intersections...
% 
% for k=1:length(astrctIntersectIntervals)
%     if astrctIntersectIntervals(k).m_iStart > 1 && astrctIntersectIntervals(k).m_iEnd < iNumFrames
%         if aiPath(astrctIntersectIntervals(k).m_iStart-1) == aiPath(astrctIntersectIntervals(k).m_iEnd+1) 
%             aiPath(astrctIntersectIntervals(k).m_iStart:astrctIntersectIntervals(k).m_iEnd) = ...
%                 aiPath(astrctIntersectIntervals(k).m_iStart-1);
%         end;
%     end;
% end;


if g_bVERBOSE
    aiMLEState = zeros(1,iNumFrames);
    for iFrameIter=1:iNumFrames
        [fDummy, aiMLEState(iFrameIter)] = max(a2fLikelihood(:,iFrameIter));
    end;
    figure(11);
    imagesc((a2fLikelihood));
    colorbar
    hold on;
    if bLOAD_GT
        h1=plot(aiCurrectStatePath,'c.','MarkerSize',17);
    end;
    h2=plot(aiPath,'m.','MarkerSize',5);
    %legend([h1,h2],'GT','MLE');
    xlabel('Frames');
    ylabel('States');
    title('Observation likelihood');
% 
%     for k=1:length(astrctIntersectIntervals)
%         aiInterval = astrctIntersectIntervals(k).m_iStart:...
%             astrctIntersectIntervals(k).m_iEnd;
%         for j=aiInterval
%             plot([j j],[0 24],'g');
%         end;
%     end;
end;
return;

function aiCurrectStatePath = fnAuxLoadGT(iNumFrames,iNumMice,iNumStates,a2iAllStates,astrctTrackers)
fprintf('Generating ground truth to test viterbi...\n');
[strFile,strPath] = uigetfile('D:\Data\Janelia Farm\GroundTruth\*.mat');
strctGT = load([strPath,strFile]);%'GroundTruth00.mat');
a2iGTPerm = zeros(iNumFrames,iNumMice);
aiCurrectStatePath = zeros(1,iNumFrames);
% 
% if isfield(strctGT.astrctTrackers(1).m_astrctClass(1),'m_iIdentity')
%     for iMouseIter=1:iNumMice
%         for iFrameIter=1:iNumFrames
%             strctGT.astrctTrackers(iMouseIter).m_astrctClass(iFrameIter) = ...
%                 rmfield(  strctGT.astrctTrackers(iMouseIter).m_astrctClass(iFrameIter),{'m_iIdentity','m_afDist','m_aiDecision'})
%         end;
%     end;
% end;

for iFrameIter=1:iNumFrames
    strctP2 = fnGetTrackersAtFrame(astrctTrackers, iFrameIter);
    strctP1 = fnGetTrackersAtFrame(strctGT.astrctTrackers, iFrameIter);
%     
% figure(11);
% clf;hold on;
% aiCol = 'rgbcym';
% for k=1:4
%     fnPlotEllipse(strctP1(k).m_fX,...
%                   strctP1(k).m_fY,...
%                   strctP1(k).m_fA,...
%                   strctP1(k).m_fB,...
%                   strctP1(k).m_fTheta,aiCol(k),2);
%     fnPlotEllipse(strctP2(k).m_fX,...
%                   strctP2(k).m_fY,...
%                   strctP2(k).m_fA,...
%                   strctP2(k).m_fB,...
%                   strctP2(k).m_fTheta,aiCol(k),1);
% end;

    a2iAssignment = fnMatchJobToPrevFrame(strctP1, strctP2);
    aiAssignment = zeros(1,iNumMice);
	aiAssignment(a2iAssignment(1,:)) = a2iAssignment(2,:);
    aiCurrectStatePath(iFrameIter) = find( sum(abs(a2iAllStates - repmat(aiAssignment,iNumStates,1)),2) == 0);
end;

return;


function a2fLikelihood = fnAuxComputeLikelihood1AA(iNumStates,iNumMice, iNumClassifiers, iNumFrames,astrctTrackers,...
    a2iAllStates,strctAdditionalInfo,aiFramesToAnalyze)
fprintf('Computing Likelihood...\n');
% Compute the probability of a state from the probability of individual
% mice classifiers output value (xi).
% 
%
% Pr(State | x1,x2,x3,x4) = Pr(x1,x2,x3,x4 | State) * Pr(State) / Pr(x1,x2,x3,x4)]
%
% Pr(x1,x2,x3,x4) | state] * Pr(State) + Pr(x1,x2,x3,x4) | ~state] * Pr(~State) 

fLogZero = -10;
a3fLogProb = zeros(length(aiFramesToAnalyze),iNumClassifiers,iNumMice,'single');
for iMouseIter=1:iNumMice
    a2fValues = cat(1,astrctTrackers(iMouseIter).m_astrctClass(aiFramesToAnalyze).m_afValue);
        a2fProbValues = reshape(interp1( strctAdditionalInfo.m_strctMiceIdentityClassifier.a2fX(:,iMouseIter), ...
             strctAdditionalInfo.m_strctMiceIdentityClassifier.a2fProb(:,iMouseIter),  a2fValues(:),'linear','extrap'), size(a2fValues));
    a2fLogProbValues = log(a2fProbValues);
    a3fLogProb(:,:,iMouseIter) = a2fLogProbValues;
end;
a3fLogProb(isinf(a3fLogProb)) = fLogZero;

a2fLikelihood = fnViterbiLikelihood1AA(a2iAllStates', a3fLogProb);

%This is a bit awkward, but the likelihood was computed as the
%permutation from tracker to identity, while in the end, we want
% to use something like identity[i] = tracker [perm[i]]
% this means we need to flip the permutation

aiAssignment = zeros(1,iNumMice);
aiNewOrder = zeros(1,iNumStates);
for k=1:iNumStates
    aiAssignment(a2iAllStates(k,:)) = 1:iNumMice;
    aiNewOrder(k) = find( sum(abs(a2iAllStates - repmat(aiAssignment,iNumStates,1)),2) == 0);
end;
% figure; imagesc(a2fLikelihood);
a2fLikelihood = a2fLikelihood(aiNewOrder,:);

% 
% a2fLikelihood  = zeros(iNumStates,iNumFrames);
% for iStateIter=1:iNumStates
%     for iFrameIter = 1:iNumFrames
%         fLogProb = 0;
%         for iMouseIter=1:iNumMice
%             fLogProb = fLogProb + a3fLogProb(iFrameIter, a2iAllStates(iStateIter,iMouseIter),iMouseIter);
%         end;
%         a2fLikelihood(iStateIter, iFrameIter) = fLogProb;
%     end;
% end;
% A=a2fLikelihood2-a2fLikelihood;
return;




function a2fLikelihood = fnAuxComputeLikelihood1AA_V2(iNumStates,iNumMice, iNumClassifiers, iNumFrames,astrctTrackers,...
    a2iAllStates,strctAdditionalInfo,aiFramesToAnalyze)
fprintf('Computing Likelihood...\n');
% Compute the probability of a state from the probability of individual
% mice classifiers output value (xi).
% 
%
% Pr(State | x1,x2,x3,x4) = Pr(x1,x2,x3,x4 | State) * Pr(State) / Pr(x1,x2,x3,x4)]
%
% Pr(x1,x2,x3,x4) | state] * Pr(State) + Pr(x1,x2,x3,x4) | ~state] * Pr(~State) 

fLogZero = -10;
a3fLogProb = zeros(length(aiFramesToAnalyze),iNumClassifiers,iNumMice,'single');
for iMouseIter=1:iNumMice
    a2fValues = astrctTrackers(iMouseIter).m_a2fClassifer(aiFramesToAnalyze,:);
    a2fProbValues = reshape(interp1( strctAdditionalInfo.m_strctMiceIdentityClassifier.a2fX(:,iMouseIter), ...
             strctAdditionalInfo.m_strctMiceIdentityClassifier.a2fProb(:,iMouseIter),  ...
             a2fValues(:),'linear','extrap'), size(a2fValues));
    a2fLogProbValues = log(a2fProbValues);
    a3fLogProb(:,:,iMouseIter) = a2fLogProbValues;
end;
a3fLogProb(isinf(a3fLogProb)) = fLogZero;

a2fLikelihood = fnViterbiLikelihood1AA(a2iAllStates', a3fLogProb);

%This is a bit awkward, but the likelihood was computed as the
%permutation from tracker to identity, while in the end, we want
% to use something like identity[i] = tracker [perm[i]]
% this means we need to flip the permutation

aiAssignment = zeros(1,iNumMice);
aiNewOrder = zeros(1,iNumStates);
for k=1:iNumStates
    aiAssignment(a2iAllStates(k,:)) = 1:iNumMice;
    aiNewOrder(k) = find( sum(abs(a2iAllStates - repmat(aiAssignment,iNumStates,1)),2) == 0);
end;
% figure; imagesc(a2fLikelihood);
a2fLikelihood = a2fLikelihood(aiNewOrder,:);

% 
% a2fLikelihood  = zeros(iNumStates,iNumFrames);
% for iStateIter=1:iNumStates
%     for iFrameIter = 1:iNumFrames
%         fLogProb = 0;
%         for iMouseIter=1:iNumMice
%             fLogProb = fLogProb + a3fLogProb(iFrameIter, a2iAllStates(iStateIter,iMouseIter),iMouseIter);
%         end;
%         a2fLikelihood(iStateIter, iFrameIter) = fLogProb;
%     end;
% end;
% A=a2fLikelihood2-a2fLikelihood;
return;



function a2fLikelihood = fnAuxComputeLikelihood(iNumStates,iNumMice, iNumClassifiers, iNumFrames,astrctTrackers,...
    a2iAllStates,strctAdditionalInfo,aiFramesToAnalyze)
% extract observation matrix
fprintf('Computing Likelihood...\n');
a3fObs = zeros(iNumMice, iNumClassifiers, iNumFrames);
for iMouseIter=1:iNumMice
    for iFrameIter=1:iNumFrames
        a3fObs(iMouseIter, :, iFrameIter) = ...
            astrctTrackers(iMouseIter).m_astrctClass(aiFramesToAnalyze(iFrameIter)).m_afValue;  
    end;
end;
a3fObs = a3fObs * 1e4;

a2fMu = strctAdditionalInfo.m_strctMiceIdentityClassifier.a2fMu;
a2fSig = strctAdditionalInfo.m_strctMiceIdentityClassifier.a2fSig;


[a2fLikelihood] = fnViterbiLikelihood(a2iAllStates',a3fObs, a2fMu, a2fSig);

% 
% a2fLikelihood  = zeros(iNumStates,iNumFrames);
% for iFrameIter=1:iNumFrames
%     a2fLikelihood(:,iFrameIter) = fnViterbiProbObsAllStatesExp(a2iAllStates, ...
%         a3fObs(:,:,iFrameIter), a2fMu,a2fSig);
% end

%a2fLikelihoodNormalized = log(exp(a2fLikelihood) ./ repmat(sum(exp(a2fLikelihood),1),iNumStates,1));

return;


function [astrctIntersectIntervals,acIntersectingPairs,a3fIntersectArea] = ...
    fnAuxFindIntersection(iNumMice, iNumFrames, astrctTrackers,aiFramesToAnalyze)
% Do fine grain analysis in intersection frames.
fprintf('Computing ellipse intersections...\n');
% 
% X=cat(1,astrctTrackers.m_afX);
% Y=cat(1,astrctTrackers.m_afY);
% A=cat(1,astrctTrackers.m_afA);
% B=cat(1,astrctTrackers.m_afB);
% T=cat(1,astrctTrackers.m_afTheta);
% 
% a3bIntersections = fnEllipseBBoxIntersection(X,Y,A,B,T);
% abIntersecting = squeeze(sum(sum(a3bIntersections,1),2));
% 


a3bIntersect = zeros(iNumMice,iNumMice, iNumFrames);
a3fIntersectArea = zeros(iNumMice,iNumMice, iNumFrames);
abIntersecting = zeros(1,iNumFrames);
acIntersectingPairs = cell(1,iNumFrames);

for iFrameIter=1:iNumFrames
    [a3bIntersect(:,:,iFrameIter),a2iIntersectingPairs,a3fIntersectArea(:,:,iFrameIter)] = ...
        fnEllipseIntersectionMatrix(astrctTrackers, aiFramesToAnalyze(iFrameIter));
    acIntersectingPairs{iFrameIter} = a2iIntersectingPairs;
    abIntersecting(iFrameIter) = sum(sum(a3bIntersect(:,:,iFrameIter))) > 0;
end;
astrctIntersectIntervals = fnGetIntervals(abIntersecting>0);

return;


function a3fTransitionMatrices = fnAuxcomputeTransitionMatrices(...
    iNumFrames, iNumStates,a2iAllStates, astrctIntersectIntervals,...
    acIntersectingPairs,fSwapPenalty)
%% Compute transition matrices.
a3fTransitionMatrices = zeros(iNumStates,iNumStates,iNumFrames,'single');
% Initialize all transition matrices to default...
fLogZero = -50000;
a2fDefaultLogMatrix = (1-eye(iNumStates)) * fLogZero;
for iIter=1:iNumFrames
    a3fTransitionMatrices(:,:,iIter) = a2fDefaultLogMatrix;
end;

fprintf('Preparing transition matrices...\n');
for k=1:length(astrctIntersectIntervals)
        aiInterval = astrctIntersectIntervals(k).m_iStart:...
            astrctIntersectIntervals(k).m_iEnd;
        for iFrameIter=aiInterval
            a3fTransitionMatrices(:,:,iFrameIter) = ...
                  fnViterbiBuildTransitionMatrixRev(acIntersectingPairs{iFrameIter},...
                  a2iAllStates,fLogZero,fSwapPenalty);
        end;
end;
return;

