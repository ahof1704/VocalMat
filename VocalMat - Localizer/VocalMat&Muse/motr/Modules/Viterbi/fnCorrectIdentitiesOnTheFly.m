function [astrctTrackers,afFrameReliability] = fnCorrectIdentitiesOnTheFly(astrctTrackers, strctMiceIdentityClassifiers, abLargeTimeGap, bLOAD_GT,fSwapPenalty)
% A State represents the correct assignment from trackers to identeties.
% For example, state [2,1,3,4] means:
% True identity:
% Red    - take values from 2nd tracker
% Green  - take values from 1st tracker
% Blue   - take values from 3rd tracker
% Cyan   - take values from 4th tracker
%
% In other words:
% astrctMicePosition(iMouseID, iFrame) = astrctTrackers( State[iMouseID, iFrameIter])
%

%Copyright (c) 2008 Shay Ohayon, California Institute of Technology. 
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_bVERBOSE g_strctGlobalParam

iNumMice = length(astrctTrackers);
iNumClassifiers = iNumMice;%size(strctAdditionalInfo.m_strctMiceIdentityClassifier.a2fW,2);
iNumFrames = length(astrctTrackers(1).m_afX);
a2iAllStates = fliplr(perms(1:iNumMice));
iNumStates = size(a2iAllStates,1);

if bLOAD_GT
    aiCurrectStatePath = fnAuxLoadGT(iNumFrames,iNumMice,iNumStates,a2iAllStates,astrctTrackers);
end;

fprintf('Computing Likelihood...\n');

if   strcmpi(g_strctGlobalParam.m_strctClassifiers.m_strType,'Tdist')
a2fLikelihood = fnAuxComputeLikelihood1AA_Tdist(iNumStates,iNumMice, iNumClassifiers, iNumFrames,...
    astrctTrackers,a2iAllStates);
elseif strcmpi(g_strctGlobalParam.m_strctClassifiers.m_strType,'RobustLDA')
a2fLikelihood = fnAuxComputeLikelihood1AA_Robust(iNumStates,iNumMice, iNumClassifiers, iNumFrames,...
    astrctTrackers,a2iAllStates);

elseif    strcmpi(g_strctGlobalParam.m_strctClassifiers.m_strType,'LDA_Logistic')
a2fLikelihood = fnAuxComputeLikelihood1AA_Logistic(iNumStates,iNumMice, iNumClassifiers, iNumFrames,...
    astrctTrackers,a2iAllStates);
a2fLikelihood = log(bsxfun(@rdivide, exp(a2fLikelihood), sum(exp(a2fLikelihood),1)));

else    
a2fLikelihood = fnAuxComputeLikelihood1AA_V2(iNumStates,iNumMice, iNumClassifiers, iNumFrames,...
    astrctTrackers,a2iAllStates,strctMiceIdentityClassifiers);
a2fLikelihood = log(bsxfun(@rdivide, exp(a2fLikelihood), sum(exp(a2fLikelihood),1)));

end
fprintf('Done!\n');

%figure;imagesc((bsxfun(@rdivide, exp(a2fLikelihood), sum(exp(a2fLikelihood),1))))
% Noramlize likelihood

a2fX=cat(1,astrctTrackers.m_afX);
a2fY=cat(1,astrctTrackers.m_afY);
a2fA=cat(1,astrctTrackers.m_afA);
a2fB=cat(1,astrctTrackers.m_afB);
a2fTheta=cat(1,astrctTrackers.m_afTheta);

fIdentitySwapJumpPix = 0; % OA - 10->0

fprintf('Running Viterbi...\n');
tic
[aiPath] = fndllViterbiOnTheFly(a2iAllStates', a2fLikelihood, ...
    a2fX, a2fY, a2fA, a2fB, a2fTheta, fSwapPenalty, abLargeTimeGap,fIdentitySwapJumpPix);
toc
aiSampleLikelihoodInd = sub2ind(size(a2fLikelihood),aiPath,1:iNumFrames);
afFrameReliability = exp(a2fLikelihood(aiSampleLikelihoodInd));
%afSmoothFrameReliability = conv(afFrameReliability, fspecial('gaussian',[1 800], 100),'same');

a2iIdentities = a2iAllStates(aiPath,:);
fprintf('Done!\n');

if 0
    save('ViterbiOnTheDly','a2iAllStates','a2fLikelihood','a2fX', 'a2fY', 'a2fA', 'a2fB', 'a2fTheta', 'fSwapPenalty', 'abLargeTimeGap');
    save('ViterbiOnTheFly_ResultsDebug','aiPath','a2fLogProb','a2iUpdateLog', 'a3bIntersections');
[a2fTransition] = fndllViterbiOnTheFlyDebug(a2iAllStates', a2fLikelihood, ...
    a2fX, a2fY, a2fA, a2fB, a2fTheta, fSwapPenalty,610297 - 1);
    
end;
%%
if 0
    fLogZero = -10;
    a3fLogProb = zeros(iNumMice, iNumClassifiers, iNumFrames,'single');
    for iMouseIter=1:iNumMice
        a2fLogProbValues = log(reshape(interp1( strctMiceIdentityClassifiers.m_a2fX(:,iMouseIter), ...
            strctMiceIdentityClassifiers.m_a2fProb(:,iMouseIter),  ...
            astrctTrackers(iMouseIter).m_a2fClassifer(:),'linear','extrap'), size(astrctTrackers(iMouseIter).m_a2fClassifer))');
        a3fLogProb(iMouseIter,:,:) = a2fLogProbValues;
    end;
    a3fLogProb(isinf(a3fLogProb)) = fLogZero;
end

astrctTrackers = rmfield(astrctTrackers,'m_a2fClassifer');

%%
fprintf('Correcting indices...');

aiX = 1:iNumFrames;
for iMouseIter=1:iNumMice
    aiY = a2iIdentities(:,iMouseIter)';
    aiCorrectInd = sub2ind(size(a2fX), aiY, aiX);
    astrctTrackers(iMouseIter).m_afX = a2fX(aiCorrectInd);
    astrctTrackers(iMouseIter).m_afY = a2fY(aiCorrectInd);
    astrctTrackers(iMouseIter).m_afA = a2fA(aiCorrectInd);
    astrctTrackers(iMouseIter).m_afB = a2fB(aiCorrectInd);
    astrctTrackers(iMouseIter).m_afTheta = a2fTheta(aiCorrectInd);
    %aiInd = sub2ind(size(a3fLogProb), a2iAllStates(aiPath, iMouseIter)',ones(1,iNumFrames)*iMouseIter,1:iNumFrames);
    %astrctTrackers(iMouseIter).m_afLogProb = a3fLogProb(aiInd);
end

%astrctTrackers = rmfield(astrctTrackers,'m_a2fClassifer');
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


if 0
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


function a2fLikelihood = fnAuxComputeLikelihood1AA_V2(iNumStates,iNumMice, iNumClassifiers, iNumFrames,astrctTrackers,...
    a2iAllStates,strctMiceIdentityClassifiers)
% Compute the probability of a state from the probability of individual
% mice classifiers output value (xi).
% 
%
% Pr(State | x1,x2,x3,x4) = Pr(x1,x2,x3,x4 | State) * Pr(State) / Pr(x1,x2,x3,x4)]%
% 
fLogZero = -10;
a3fLogProb = zeros(iNumFrames,iNumClassifiers,iNumMice,'single');
for iMouseIter=1:iNumMice
    a2fProbValues = reshape(interp1( strctMiceIdentityClassifiers.m_a2fX(:,iMouseIter), ...
             strctMiceIdentityClassifiers.m_a2fProb(:,iMouseIter),  ...
             astrctTrackers(iMouseIter).m_a2fClassifer(:),'linear','extrap'), size(astrctTrackers(iMouseIter).m_a2fClassifer));
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



function a2fLikelihood = fnAuxComputeLikelihood1AA_Tdist(iNumStates,iNumMice, iNumClassifiers, iNumFrames,astrctTrackers,...
    a2iAllStates)
% The likelihood of obvserving a measurement given the true state
fLogZero = -10;
a3fLogProb = zeros(iNumFrames,iNumClassifiers,iNumMice,'single');
for iMouseIter=1:iNumMice
    a3fLogProb(:,:,iMouseIter) = log(astrctTrackers(iMouseIter).m_a2fClassifer); % P(Xi | Id)
end
a3fLogProb(isinf(a3fLogProb)) = fLogZero;
a2fLikelihood = fnViterbiLikelihood1AA(a2iAllStates', a3fLogProb);
return;

function a2fLikelihood = fnAuxComputeLikelihood1AA_Robust(iNumStates,iNumMice, iNumClassifiers, iNumFrames,astrctTrackers,...
    a2iAllStates)
% The likelihood of obvserving a measurement given the true state
fLogZero = -10;
a3fLogProb = zeros(iNumFrames,iNumClassifiers,iNumMice,'single');
for iMouseIter=1:iNumMice
    a3fLogProb(:,:,iMouseIter) = log(astrctTrackers(iMouseIter).m_a2fClassifer);
end
a3fLogProb(isinf(a3fLogProb)) = fLogZero;
a2fLikelihood = fnViterbiLikelihood1AA(a2iAllStates', a3fLogProb);
a2fLikelihood = log(bsxfun(@rdivide, exp(a2fLikelihood), sum(exp(a2fLikelihood),1)));

return;

function a2fLikelihood = fnAuxComputeLikelihood1AA_Logistic(iNumStates,iNumMice, iNumClassifiers, iNumFrames,astrctTrackers,...
    a2iAllStates)
% The likelihood of obvserving a measurement given the true state
% % % % X = [4,9,8,10;
% % % %      7,0,8,9;
% % % %      7,8,7,4;
% % % %      7,2,7,0];
% % % % for k=1:4
% % % %     astrctTrackers(k).m_a2fClassifer(1,:) =  exp(X(k,:));
% % % % end

%%
fLogZero = -10;
a3fLogProb = zeros(iNumFrames,iNumClassifiers,iNumMice,'single');
for iMouseIter=1:iNumMice
    a3fLogProb(:,:,iMouseIter) = log(astrctTrackers(iMouseIter).m_a2fClassifer);
end
a3fLogProb(isinf(a3fLogProb)) = fLogZero;


a2fLikelihood = fnViterbiLikelihood1AA(a2iAllStates', a3fLogProb);


% % % 
% % % This is a bit awkward, but the likelihood was computed as the
% % % permutation from tracker to identity, while in the end, we want
% % % to use something like identity[i] = tracker [perm[i]]
% % % this means we need to flip the permutation
% % % 
% % % aiAssignment = zeros(1,iNumMice);
% % % aiNewOrder = zeros(1,iNumStates);
% % % for k=1:iNumStates
% % %     aiAssignment(a2iAllStates(k,:)) = 1:iNumMice;
% % %     aiNewOrder(k) = find( sum(abs(a2iAllStates - repmat(aiAssignment,iNumStates,1)),2) == 0);
% % % end;
% % % figure; imagesc(a2fLikelihood);
% % % a2fLikelihood = a2fLikelihood(aiNewOrder,:);

return;
