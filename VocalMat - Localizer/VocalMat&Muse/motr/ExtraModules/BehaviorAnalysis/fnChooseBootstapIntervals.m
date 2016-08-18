function astrctBehaviors = fnChooseBootstapIntervals(astrctBehaviors, astrctTrackers, iMaxIntervalNum, bUseOnlyUnannotated)
%
%
triggerHappyFactor = 0.05;
strctClassifierTH = fnOferEntryPointLearning(astrctTrackers, astrctBehaviors, triggerHappyFactor);
strctClassifierTS = fnOferEntryPointLearning(astrctTrackers, astrctBehaviors, -triggerHappyFactor);
%%
iNumMice = length(astrctTrackers);
global globalBCparams;
[iNumPairs, a2iPairs, a2iPairInd]=getSetIndices(~globalBCparams.Features.bMousePair, iNumMice);
iTimeScale = max(globalBCparams.Features.aTimeScales) + globalBCparams.Features.iSelfTimeScale + 1;
sBehaviorType = globalBCparams.sBehaviorType;
aiIntervals = globalBCparams.aiIntervals;
aiIntervalLengths = aiIntervals(:,2) - aiIntervals(:,1) + 1;
astrctBehaviorsAll = cell(iNumMice,1);

for iBatch=1:size(aiIntervals, 1)
   
   iStartFrame = max(1, aiIntervals(iBatch,1) - iTimeScale);
   iEndFrame = aiIntervals(iBatch,2);
   iNumFrames = iEndFrame - iStartFrame + 1;
   astrctBehaviorsBatch = fnCutBehaviorStruct(astrctBehaviors, iStartFrame, iEndFrame, true);
   astrctTrackersBatch = fnCutTrackerStruct(astrctTrackers, iStartFrame, iEndFrame);
   
   %% calc features
   % TODO: allow bootstrap with "other-behavior" features
   aFeatures = [];
   for iMouseInd=1:iNumMice
      aFullFeatures = fnCalcMouseFeatures(iMouseInd, astrctTrackersBatch, globalBCparams);
      aFeatures = [aFeatures fnCutRelevantFeatureSegments(aFullFeatures, globalBCparams)];
   end
   
   %% Run algorithm to detect  behaviors...
   a2bBehaviorPosTH = max(0, reshape(strongGentleClassifier(aFeatures, strctClassifierTH)', iNumFrames, iNumPairs)');
   a2bBehaviorPosTS = max(0, reshape(strongGentleClassifier(aFeatures, strctClassifierTS)', iNumFrames, iNumPairs)');
   a2bBehaviorPos = a2bBehaviorPosTH & ~a2bBehaviorPosTS;
   a2bBehaviorPos(end-aiIntervalLengths(iBatch):end) = false;
   if bUseOnlyUnannotated
      abBehaviors = fnConvertBehaviorStructToMatrix(astrctBehaviorsBatch, sBehaviorType, iNumFrames, a2iPairInd);
      abBehaviorsBatch = fnConvertBehaviorStructToMatrix(astrctBehaviorsBatch, sBehaviorType, iNumFrames, a2iPairInd) | ...
                                    fnConvertBehaviorStructToMatrix(astrctBehaviorsBatch, ['-' sBehaviorType], iNumFrames, a2iPairInd);
      a2bBehaviorPos = a2bBehaviorPos & ~abBehaviors;
   end
   
   %% format output
   aIntervalLength = [];
   a2bBehaviorPos(:,[1 iNumFrames]) = 0;
   for iPair=1:iNumPairs
      abBehavior = a2bBehaviorPos(iPair,:);
      m = a2iPairs(iPair,:);
      astrctBehaviorsPair= fnConvertVectorToBehaviorStruct(abBehavior, m(2), sBehaviorType, m(1), false, 3, iStartFrame);
      astrctBehaviorsAll{m(1)} = [astrctBehaviorsAll{m(1)} astrctBehaviorsPair];
   end
   
end

clear globalBCparams;

%% prune output
aIntervalLength = [];
for iMouseInd=1:iNumMice
   for j=1:length(astrctBehaviorsAll{iMouseInd})
      aIntervalLength = [aIntervalLength; astrctBehaviorsAll{iMouseInd}(j).m_iEnd - astrctBehaviorsAll{iMouseInd}(j).m_iStart + 1];
   end
end
iIntervalNum = 0;
if length(aIntervalLength) > iMaxIntervalNum
   astrctBehaviors = cell(iNumMice,1);
   aIntervalLength = sort(aIntervalLength, 'descend');
   iIntervalLengthLowerBound = aIntervalLength(iMaxIntervalNum);
   for iMouseInd=1:iNumMice
      for j=1:length(astrctBehaviorsAll{iMouseInd})
         if astrctBehaviorsAll{iMouseInd}(j).m_iEnd - astrctBehaviorsAll{iMouseInd}(j).m_iStart + 1 >= iIntervalLengthLowerBound ...
               && iIntervalNum < iMaxIntervalNum
            astrctBehaviors{iMouseInd}(length(astrctBehaviors{iMouseInd})+1) = astrctBehaviorsAll{iMouseInd}(j);
            iIntervalNum = iIntervalNum + 1;
         end
      end
   end
else
    astrctBehaviors = astrctBehaviorsAll;
end

