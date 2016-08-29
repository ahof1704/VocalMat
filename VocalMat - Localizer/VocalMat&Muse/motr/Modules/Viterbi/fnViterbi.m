function a2iIdentities = fnViterbi(astrctTrackers, strctAdditionalInfo, aiFramesToAnalyze)
%
%Copyright (c) 2008 Shay Ohayon, California Institute of Technology. 
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_bVERBOSE

bLOAD_GT = false;

iNumMice = length(astrctTrackers);
iNumClassifiers =iNumMice*(iNumMice-1)/2;
iNumFrames = length(aiFramesToAnalyze);
a2iAllStates = fliplr(perms(1:iNumMice));
iNumStates = size(a2iAllStates,1);

if bLOAD_GT
    aiCurrectStatePath = fnAuxLoadGT(iNumFrames,iNumMice,iNumStates,a2iAllStates,astrctTrackers);
end;

a2fLikelihood = fnAuxComputeLikelihood(iNumStates,iNumMice, iNumClassifiers, iNumFrames,...
    astrctTrackers,a2iAllStates,strctAdditionalInfo,aiFramesToAnalyze);

[astrctIntersectIntervals,acIntersectingPairs] = ...
    fnAuxFindIntersection(iNumMice, iNumFrames, astrctTrackers,aiFramesToAnalyze);

a3fTransitionMatrices = fnAuxcomputeTransitionMatrices(...
    iNumFrames, iNumStates,a2iAllStates, astrctIntersectIntervals,acIntersectingPairs);

aiPath = fndllViterbi(a3fTransitionMatrices,a2fLikelihood);
%[aiPath, a2fLogProb] = fnViterbiForwardBackward(iNumStates, iNumFrames, ...
%    a3fTransitionMatrices,a2fLikelihood);

if g_bVERBOSE
figure(10);
clf;
hold on;
for k=1:length(astrctIntersectIntervals)
    aiInterval = astrctIntersectIntervals(k).m_iStart:...
        astrctIntersectIntervals(k).m_iEnd;
    for j=aiInterval
        plot([aiFramesToAnalyze(j) aiFramesToAnalyze(j)],[0 24],'g');
    end;
end;
if bLOAD_GT
    plot(aiCurrectStatePath,'co');
end
plot(aiFramesToAnalyze,aiPath,'.');

end;

% Use a small running median filter to remove spurious switching during
% intersection intervals...
a2iIdentities = a2iAllStates(aiPath,:);

if g_bVERBOSE
    aiMLEState = zeros(1,iNumFrames);
    for iFrameIter=1:iNumFrames
        [fDummy, aiMLEState(iFrameIter)] = max(a2fLikelihood(:,iFrameIter));
    end;
    figure(10);
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

    for k=1:length(astrctIntersectIntervals)
        aiInterval = astrctIntersectIntervals(k).m_iStart:...
            astrctIntersectIntervals(k).m_iEnd;
        for j=aiInterval
            plot([j j],[0 24],'g');
        end;
    end;
end;

function aiCurrectStatePath = fnAuxLoadGT(iNumFrames,iNumMice,iNumStates,a2iAllStates,astrctTrackers)
fprintf('Generating ground truth to test viterbi...\n');
[strFile,strPath] = uigetfile('GroundTruth*.mat');
strctGT = load([strPath,strFile]);%'GroundTruth00.mat');
a2iGTPerm = zeros(iNumFrames,iNumMice);
aiCurrectStatePath = zeros(1,iNumFrames);
for iFrameIter=1:iNumFrames
    strctP1 = fnGetTrackersAtFrame(astrctTrackers, iFrameIter);
    strctP2 = fnGetTrackersAtFrame(strctGT.astrctTrackers, iFrameIter);
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

    aiAssignment = fnMatchJobToPrevFrame(strctP1, strctP2);
    for iMouseIter=1:iNumMice
        a2iGTPerm(iFrameIter,iMouseIter) = aiAssignment(2,find(aiAssignment(1,:)==iMouseIter));
    end;
    aiCurrectStatePath(iFrameIter) = find( sum(abs(a2iAllStates - repmat(a2iGTPerm(iFrameIter,:),iNumStates,1)),2) == 0);
end;

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

a2fLikelihood  = zeros(iNumStates,iNumFrames);
for iFrameIter=1:iNumFrames
    a2fLikelihood(:,iFrameIter) = fnViterbiProbObsAllStates(a2iAllStates, ...
        a3fObs(:,:,iFrameIter), a2fMu,a2fSig);
end

%a2fLikelihoodNormalized = log(exp(a2fLikelihood) ./ repmat(sum(exp(a2fLikelihood),1),iNumStates,1));

return;


function [astrctIntersectIntervals,acIntersectingPairs] = ...
    fnAuxFindIntersection(iNumMice, iNumFrames, astrctTrackers,aiFramesToAnalyze)
% Do fine grain analysis in intersection frames.
fPositionJumpThreshold = 10;

fprintf('Computing ellipse intersections...\n');
a3bIntersect = zeros(iNumMice,iNumMice, iNumFrames);
abIntersecting = zeros(1,iNumFrames);
a2bIntersect = zeros(iNumFrames,iNumMice);
acIntersectingPairs = cell(1,iNumFrames);
for iFrameIter=1:iNumFrames
    [a3bIntersect(:,:,iFrameIter),a2iIntersectingPairs] = ...
        fnEllipseIntersectionMatrix(astrctTrackers, aiFramesToAnalyze(iFrameIter));
    acIntersectingPairs{iFrameIter} = a2iIntersectingPairs;
    abIntersecting(iFrameIter) = sum(sum(a3bIntersect(:,:,iFrameIter))) > 0;
     if abIntersecting(iFrameIter)
         Tmp = zeros(1,iNumMice);
         Tmp(a2iIntersectingPairs(:)) =1;
         a2bIntersect(iFrameIter,:) = Tmp;
    end;
end;

astrctIntersectIntervals = fnGetIntervals(abIntersecting>0);

%afMaxdA = zeros(1, length(astrctIntersectIntervals));
%afMaxdB = zeros(1, length(astrctIntersectIntervals));
afMaxdXY = zeros(1, length(astrctIntersectIntervals));
for iIter=1:length(astrctIntersectIntervals)
    if astrctIntersectIntervals(iIter).m_iLength > 1
        aiInterval = astrctIntersectIntervals(iIter).m_iStart:astrctIntersectIntervals(iIter).m_iEnd;
        aiMiceInvovled = find(sum(a2bIntersect(aiInterval,:),1)>0);
        for iMouseIter=1:length(aiMiceInvovled)
%             dA = astrctTrackers(aiMiceInvovled(iMouseIter)).m_afA(aiInterval(2:end)) - ...
%                  astrctTrackers(aiMiceInvovled(iMouseIter)).m_afA(aiInterval(1:end-1));
%             dB = astrctTrackers(aiMiceInvovled(iMouseIter)).m_afB(aiInterval(2:end)) - ...
%                 astrctTrackers(aiMiceInvovled(iMouseIter)).m_afB(aiInterval(1:end-1));
            dX = astrctTrackers(aiMiceInvovled(iMouseIter)).m_afX(aiFramesToAnalyze(aiInterval(2:end)))- ...
                astrctTrackers(aiMiceInvovled(iMouseIter)).m_afX(aiFramesToAnalyze(aiInterval(1:end-1)));
            dY = astrctTrackers(aiMiceInvovled(iMouseIter)).m_afY(aiFramesToAnalyze(aiInterval(2:end)))- ...
                astrctTrackers(aiMiceInvovled(iMouseIter)).m_afY(aiFramesToAnalyze(aiInterval(1:end-1)));
%            afMaxdA(iIter) = max(afMaxdA(iIter), max(abs(dA)));
%            afMaxdB(iIter) = max(afMaxdB(iIter), max(abs(dB)));
            afMaxdXY(iIter) = max(afMaxdXY(iIter), max(sqrt(dX.^2+dY.^2)));
        end;
    end;
end;
aiPotentialSwapIntervals = find(afMaxdXY > fPositionJumpThreshold);


astrctIntersectIntervals = astrctIntersectIntervals(aiPotentialSwapIntervals);
if 0
% TODO
% Narrow down intervals only to middle frame.
% do it only for ones that have same intersecting ellipses...
abI = zeros(1,iNumFrames);
for k=1:length(astrctIntersectIntervals)
    abI(astrctIntersectIntervals(k).m_iStart:astrctIntersectIntervals(k).m_iEnd) = 1;
end;


%Convert intersecting pairs into a unique number
aiUniqueNumber = zeros(1,iNumFrames);
aiPowerTwo = 2.^(0:iNumMice^2-1);
for iFrameIter=1:iNumFrames
    a2iTmp = zeros(iNumMice,iNumMice);
    a2iIntersectingPairs = acIntersectingPairs{iFrameIter};
    for j=1:size(a2iIntersectingPairs,1)
        a2iTmp(a2iIntersectingPairs(j,1),a2iIntersectingPairs(j,2)) = 1;
    end;
    aiUniqueNumber(iFrameIter) = sum(aiPowerTwo(find(a2iTmp(:))));
end;

aiUniqueNumber(~abI) = 0;

astrctIntersectIntervals2 = fnGetIntervalsNonBinary(aiUniqueNumber);
% Shrink it down to 1 frame
for k=1:length(astrctIntersectIntervals2)
    iMiddle = round( (astrctIntersectIntervals2(k).m_iStart+astrctIntersectIntervals2(k).m_iEnd)/2);
    astrctIntersectIntervals2(k).m_iStart = iMiddle;
    astrctIntersectIntervals2(k).m_iEnd = iMiddle;
    astrctIntersectIntervals2(k).m_iLength = 1;
end;
astrctIntersectIntervals = astrctIntersectIntervals2;
end;
return;


function a3fTransitionMatrices = fnAuxcomputeTransitionMatrices(...
    iNumFrames, iNumStates,a2iAllStates, astrctIntersectIntervals,acIntersectingPairs)
%% Compute transition matrices.
a3fTransitionMatrices = zeros(iNumStates,iNumStates,iNumFrames);
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
        iMiddleFrame = round((astrctIntersectIntervals(k).m_iStart+astrctIntersectIntervals(k).m_iEnd)/2);
        for iFrameIter=aiInterval
            a3fTransitionMatrices(:,:,iFrameIter) = ...
                  fnViterbiBuildTransitionMatrix(acIntersectingPairs{iFrameIter},...
                  a2iAllStates,fLogZero);
        end;
end;
return;


% %% Alternative algorithm to Viterbi...
% astrctReducedIntervals = astrctIntersectIntervals(aiPotentialSwapIntervals);
% abV = zeros(1,iNumFrames)>0;
% for k=1:length(astrctReducedIntervals)
%     abV(astrctReducedIntervals(k).m_iStart:astrctReducedIntervals(k).m_iEnd)=1;
% end;
% astrctNoSwap = fnGetIntervals(~abV);
% aiMaxLikelihoodPath = zeros(1,iNumFrames);
% for k=1:length(astrctNoSwap)
%     afProb = sum(a2fLikelihood(:,astrctNoSwap(k).m_iStart:astrctNoSwap(k).m_iEnd),2);
%     [fDummy, iMaxIndex] = max(afProb);
%     aiMaxLikelihoodPath(astrctNoSwap(k).m_iStart:astrctNoSwap(k).m_iEnd) = iMaxIndex;
% end;
% 
% plot(aiCurrectStatePath,'c');
% 
% 
% 
% % 
% % figure(2);
% % plot(a2fLogProb(:,2));
% 
% if g_bVERBOSE
% 
% % Plot Scenario
% figure(100);
% clf;
% hold on;
% aiCol = {'r.','g.','b.','c.','y.','m.'};
% for iFrameIter=1:iNumFrames
%     iFrame = aiInterval(iFrameIter);
%     for iMouseIter=1:iNumMice
%      plot(astrctTrackers(iMouseIter).m_afX(iFrame),...
%          astrctTrackers(iMouseIter).m_afY(iFrame),aiCol{iMouseIter});
%     end;
% end
% legend('1','2','3','4')
% axis ij
% aiCol = {'ro','go','bo','co','y.','m.'};
% for iFrameIter=1:iNumFrames
%     iFrame = aiInterval(iFrameIter);
%     for iMouseIter=1:iNumMice
%      plot(Train.astrctTrackers(iMouseIter).m_afX(iFrame),...
%          Train.astrctTrackers(iMouseIter).m_afY(iFrame),aiCol{iMouseIter});
%     end;
% end;
% 
% 
% 
% 
% a2iIdentity = zeros(iNumMice,iNumFrames);
% for iFrameIter=1:iNumFrames
%     iFrame = aiInterval(iFrameIter);
%     for iMouseIter=1:iNumMice
%         a2iIdentity(iMouseIter,iFrameIter) = ...
%             astrctTrackers(iMouseIter).m_astrctClass(iFrame).m_iIdentity;
%     end;
% end;
% 
% figure(2);
% plot(aiInterval,a2iIdentity','LineWidth',2)
% axis([aiInterval(1) aiInterval(end) -1 5])
% legend('R','G','B','C');
% 
% end;
