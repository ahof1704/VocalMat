function strctClassifier = fnOferEntryPointLearning(astrctTrackers0, astrctBehaviors0, triggerHappyFactor)

%%
global globalBCparams;
if isempty(globalBCparams)
    strctClassifier = [];
    return;
end

% bSingle = ~(globalBCparams.Features.bCoordinates || globalBCparams.Features.bDistances || globalBCparams.Features.bMousePair);
sBehaviorType = globalBCparams.sBehaviorType;
bSingle = ~globalBCparams.Features.bMousePair;
iTimeScale = max(globalBCparams.Features.aTimeScales) + globalBCparams.Features.iSelfTimeScale + 1;
aiIntervals = globalBCparams.aiIntervals;

iNumFrames = length(astrctTrackers0(1).m_afX);
iNumMice = length(astrctTrackers0);

[iNumPairs, a2iPairs, a2iPairInd]=getSetIndices(bSingle, iNumMice);

[acOBs, aiOBfeatureNum, abOBelapted, abOBfreq, aiOBtimeScale]  = getRelevantOtherBehaviors(globalBCparams);
aiNumEventsTotal = [];
aiNumFramesTotal = [];
aFeaturesTotal = [];
abTagsTotal =[];

abAllowedTags = zeros(1, 1, iNumFrames);
for i=1:size(aiIntervals, 1)
    abAllowedTags(1,1,aiIntervals(i,1):aiIntervals(i,2)) = 1;
end
[abAllTags, aiNumEventsTotal, aiNumFramesTotal] = fnBuildBehaviorTags(astrctBehaviors0, iNumPairs, squeeze(abAllowedTags)', false, 1, false);
if aiNumEventsTotal(1, 1)==0
    display(['Nothing to learn for behavior type: ' sBehaviorType]);
    strctClassifier = [];
    return;
end
display(['Learning  behavior '  sBehaviorType ' based on annotated ' num2str(aiNumEventsTotal(1,1)) ' positive events and '  num2str(aiNumEventsTotal(1,2)) ' negative events, on ' num2str(aiNumFramesTotal(1,1)) ' and '  num2str(aiNumFramesTotal(1,2)) ' frames'])
for i=1:length(acOBs)
    display(['   Using other behavior - ' acOBs{i} ' with ' num2str(iNumEventsTotal(i+1,1)) ' events on ' num2str(aiNumFramesTotal(i+1,1)) ' frames'])
end

for iBatch=1:size(aiIntervals, 1)
    iStartFrame = max(1, aiIntervals(iBatch,1) - iTimeScale);
    iEndFrame = aiIntervals(iBatch,2);
    astrctBehaviors = fnCutBehaviorStruct(astrctBehaviors0, iStartFrame, iEndFrame);
    astrctTrackers = fnCutTrackerStruct(astrctTrackers0, iStartFrame, iEndFrame);
    
    iNumFrames = length(astrctTrackers(1).m_afX);
    aOBfeatures = zeros(sum(aiOBfeatureNum), iNumFrames, iNumPairs);
    
    abAllowedTags = zeros(1, 1, iNumFrames);
    abAllowedTags(1,1,end-(iEndFrame-iStartFrame):end) = 1;
    [abAllTags, aiNumEvents, aiNumFrames] = fnBuildBehaviorTags(astrctBehaviors, iNumPairs, squeeze(abAllowedTags)', false, iStartFrame, true, aiNumEventsTotal, aiNumFramesTotal);
    if aiNumEvents(1, 1)==0
        display(['Nothing to learn for behavior type: ' sBehaviorType ' in interval ' num2str(iBatch)]);
        continue;
    end
    display(['Batch ' num2str(iBatch) ' includes behavior '  sBehaviorType ': annotated ' num2str(aiNumEvents(1,1)) ' positive events and '  num2str(aiNumEvents(1,2)) ' negative events, on ' num2str(aiNumFrames(1,1)) ' and '  num2str(aiNumFrames(1,2)) ' frames'])
    for i=1:length(acOBs)
        display(['   Using other behavior - ' acOBs{i} ' with ' num2str(iNumEvents(i+1,1)) ' events on ' num2str(aiNumFrames(i+1,1)) ' frames'])
    end
    
    iNegFramesNum = round(aiNumFrames(1) * globalBCparams.Boosting.fNegPosRatio);
    iNegativeLength = round(iNegFramesNum/aiNumEvents(1)/(2*(1+globalBCparams.Boosting.bRandomNegative)));
    iGapLength = globalBCparams.Boosting.iGapLength;
    iMaxMouseB = bSingle + iNumMice*(1-bSingle);
    
    for iMouseIter = 1:iNumMice
        iNumBehaviors = length(astrctBehaviors{iMouseIter});
        if globalBCparams.Boosting.bRandomNegative && aiNumEvents(1,1)>0
            for iOtherMouseIter = 1:(bSingle + (1-bSingle)*iNumMice)
                if bSingle || iMouseIter~=iOtherMouseIter
                    iPairIndex = a2iPairInd(iMouseIter, iOtherMouseIter);
                    aiInterval = round( (iNumFrames-iTimeScale-1)*rand(1, round(iNumFrames/sum(abAllowedTags)*iNegFramesNum/iNumPairs/(1+globalBCparams.Boosting.bNegativeSandwich))) )+iTimeScale;
                    aiInterval = aiInterval(abAllTags(iPairIndex, 1, aiInterval) < 1);
                    abAllTags(iPairIndex, 1, aiInterval) = min(-1, abAllTags(iPairIndex, 1, aiInterval));
                end
            end
        end
        if globalBCparams.Boosting.bNegativeSandwich
            for iBehaviorIter = 1:iNumBehaviors
                if isBehaviorType(  astrctBehaviors{iMouseIter}(iBehaviorIter ).m_strAction, sBehaviorType )
                    if astrctBehaviors{iMouseIter}(iBehaviorIter ).m_iStart < iNumFrames
                        iMouseA = astrctBehaviors{iMouseIter}(iBehaviorIter ).m_iMouse;
                        iMouseB = min(max(1, astrctBehaviors{iMouseIter}(iBehaviorIter ).m_iOtherMouse), iMaxMouseB);
                        iPairIndex = a2iPairInd(iMouseA, iMouseB);
                        aiInterval = max( iTimeScale, astrctBehaviors{iMouseIter}(iBehaviorIter ).m_iStart-iGapLength-iNegativeLength): ...
                            max( iTimeScale, astrctBehaviors{iMouseIter}(iBehaviorIter ).m_iStart-iGapLength-1);
                        if ~bSingle
                            iPairIndex = a2iPairInd(iMouseB, iMouseA);
                            aiInterval = min( iNumFrames, astrctBehaviors{iMouseIter}(iBehaviorIter ).m_iEnd+iGapLength+1): ...
                                min( iNumFrames, astrctBehaviors{iMouseIter}(iBehaviorIter ).m_iEnd+iGapLength+iNegativeLength);
                        end
                        aiInterval = aiInterval(abAllTags(iPairIndex, 1, aiInterval) < 1);
                        abAllTags(iPairIndex, 1, aiInterval) = min(-1, abAllTags(iPairIndex, 1, aiInterval));
                    end
                end
            end
        end
    end
    abAllTags = bsxfun(@times, abAllTags, abAllowedTags);
    
    %% calc features
    display(['Learning classifier for behavior type: ' sBehaviorType])
    aFeatures = [];
    abTags =[];
    for iMouseInd=1:iNumMice
        aFullFeatures = fnCalcMouseFeatures(iMouseInd, astrctTrackers, globalBCparams);
        aPairInds = getPairInds(globalBCparams, iMouseInd, iNumMice);
        aOBfeatures = fnCalcOtherBehaviorFeatures(abAllTags(aPairInds,2:end,:), aiOBfeatureNum, abOBelapted, abOBfreq, aiOBtimeScale);
        [aFeatures1, abTags1] = fnCutRelevantFeatureSegments(aFullFeatures, globalBCparams, abAllTags(aPairInds, 1, 1:iNumFrames));
        aFeatures1 = [aFeatures1; fnCutRelevantOBfeatureSegments(aOBfeatures, abAllTags(aPairInds, 1, 1:iNumFrames))];
        aFeatures = [aFeatures aFeatures1];
        abTags = [abTags abTags1];
    end
    aFeaturesTotal = [aFeaturesTotal aFeatures];
    abTagsTotal = [abTagsTotal abTags];
end

% aFeatures(end,:) = rand(size(aFeatures(end,:))); % enable ignoring OB feature.

%% create classifer
if nargin < 3
    if isempty(globalBCparams.Boosting.fMaxMissRate)  || isempty(globalBCparams.Boosting.iMaxIterations) || globalBCparams.Boosting.iMaxIterations <= 1
        strctClassifier = gentleBoost(aFeaturesTotal, abTagsTotal, globalBCparams.Boosting.iMaxNrounds, globalBCparams.Boosting.fLookNoFurtherError);
    else
        if isempty(globalBCparams.Boosting.iMaxIterations)
            iMaxIterations = 1;
        else
            iMaxIterations = globalBCparams.Boosting.iMaxIterations;
        end
        AnnottedWeight = ones(2,1);
        for iter=1:iMaxIterations
            [strctClassifier, missRate, annotatedFalseRate] = gentleBoost(aFeaturesTotal, abTagsTotal, globalBCparams.Boosting.iMaxNrounds, globalBCparams.Boosting.fLookNoFurtherError, [], AnnottedWeight);
            if max(missRate, annotatedFalseRate) < globalBCparams.Boosting.fMaxMissRate
                break;
            end
            AnnottedWeight(1) = AnnottedWeight(1) * min(1, missRate/globalBCparams.Boosting.fMaxMissRate);
            AnnottedWeight(2) = AnnottedWeight(2) * min(1, annotatedFalseRate/globalBCparams.Boosting.fMaxMissRate);
        end
    end
else
    strctClassifier = gentleBoost(aFeaturesTotal, abTagsTotal, globalBCparams.Boosting.iMaxNrounds, globalBCparams.Boosting.fLookNoFurtherError, triggerHappyFactor);
end

clear globalBCparams;





% function strctClassifier = fnOferEntryPointLearningggg(astrctTrackers, astrctBehaviors, triggerHappyFactor)
% 
% %%
% global globalBCparams;
% % bSingle = ~(globalBCparams.Features.bCoordinates || globalBCparams.Features.bDistances || globalBCparams.Features.bMousePair);
% bSingle = ~globalBCparams.Features.bMousePair;
% iTimeScale = max(globalBCparams.Features.aTimeScales);
% sBehaviorType = globalBCparams.sBehaviorType;
% 
% iNumFrames = length(astrctTrackers(1).m_afX);
% iNumMice = length(astrctTrackers);
% 
%  [iNumPairs, a2iPairs, a2iPairInd]=getSetIndices(bSingle, iNumMice);
% 
%  switch sBehaviorType
%     case 'Head Sniffing'
%         iNumFrames = 10000;
%     case 'Following'
%         iNumFrames = 25000;
%     otherwise
%         iNumFrames = iNumFrames;
%  end
%  
% [acOBs, aiOBfeatureNum, abOBelapted, abOBfreq, aiOBtimeScale]  = getRelevantOtherBehaviors(globalBCparams);
% aOBfeatures = zeros(sum(aiOBfeatureNum), iNumFrames, iNumPairs);
% aOBtags = zeros(iNumPairs, length(acOBs), iNumFrames);
% 
% a2bBehaviorPos = zeros(iNumPairs, iNumFrames);
% [abAllTags, iNumEvents, iPosFramesNum] = fnBuildBehaviorTags(astrctBehaviors, iNumPairs, iNumFrames, false);
% a2bBehaviorPos = squeeze(abAllTags(:,1,:));
% 
% % iPosFramesNum = 0;
% % iNumEvents = 0;
% % for iMouseIter = 1:iNumMice
% %     iNumBehaviors = length(astrctBehaviors{iMouseIter});
% %     for iBehaviorIter = 1:iNumBehaviors
% %         sAction = astrctBehaviors{iMouseIter}(iBehaviorIter ).m_strAction;
% %         aiInterval = astrctBehaviors{iMouseIter}(iBehaviorIter ).m_iStart:astrctBehaviors{iMouseIter}(iBehaviorIter ).m_iEnd;
% %         iOBind = getOtherBehaviorInd(sAction, acOBs);
% %         if (isBehaviorType(sAction, sBehaviorType) || iOBind) && astrctBehaviors{iMouseIter}(iBehaviorIter).m_iStart < iNumFrames
% %             iMouseA = astrctBehaviors{iMouseIter}(iBehaviorIter ).m_iMouse;
% %             assert(iMouseA==iMouseIter, 'iMouse~=iMouseIter');
% %             iMouseB = max(1, astrctBehaviors{iMouseIter}(iBehaviorIter ).m_iOtherMouse);
% %             if iOBind
% %                 aOBtags(a2iPairInd(iMouseA, iMouseB), iOBind, aiInterval) = 1;
% %             else
% %                 a2bBehaviorPos(a2iPairInd(iMouseA, iMouseB), aiInterval) = 1;
% %                 iPosFramesNum = iPosFramesNum + length(aiInterval);
% %                 iNumEvents = iNumEvents + 1;
% %             end
% %         end      
% %     end
% % end
% display(['Number of training events: ' num2str(iNumEvents)])
% 
% if iNumEvents==0
%     display(['Nothing to learn for behavior type: ' sBehaviorType])
%     strctClassifier = [];
%     return;
% end
% 
% iNegFramesNum = round(iPosFramesNum * globalBCparams.Boosting.fNegPosRatio);
% iNegativeLength = round(iNegFramesNum/iNumEvents/2);
% iGapLength = globalBCparams.Boosting.iGapLength;
% 
% for iMouseIter = 1:iNumMice
%     iNumBehaviors = length(astrctBehaviors{iMouseIter});
%     if globalBCparams.Boosting.bRandomNegative && iNumEvents>0
%         for iOtherMouseIter = 1:(bSingle + (1-bSingle)*iNumMice)
%             if bSingle || iMouseIter~=iOtherMouseIter
%                 iPairIndex = a2iPairInd(iMouseIter, iOtherMouseIter);
% %                 aiInterval = iTimeScale+1:iNumFrames;
% %                 aiInterval = aiInterval(a2bBehaviorPos(iPairIndex, aiInterval) < 1); % take only frames not known as positive
% %                 aiInterval = permute(aiInterval, randperm(length(aiInterval)));
% %                 aiInterval = aiInterval(1:min(iNegFramesNum/iNumPairs, length(aiInterval)));
%                 aiInterval = round( (iNumFrames-iTimeScale-2)*rand(1, iNegFramesNum/iNumPairs) )+iTimeScale+1;
%                 aiInterval = aiInterval(a2bBehaviorPos(iPairIndex, aiInterval) < 1); 
%                 a2bBehaviorPos(iPairIndex, aiInterval) = -1;
%             end
%         end
%     end
%     if globalBCparams.Boosting.bNegativeSandwich
%         for iBehaviorIter = 1:iNumBehaviors
%             if isBehaviorType(  astrctBehaviors{iMouseIter}(iBehaviorIter ).m_strAction, sBehaviorType )
%                 if astrctBehaviors{iMouseIter}(iBehaviorIter ).m_iStart < iNumFrames
%                     iMouseA = astrctBehaviors{iMouseIter}(iBehaviorIter ).m_iMouse;
%                     iMouseB = max(1, astrctBehaviors{iMouseIter}(iBehaviorIter ).m_iOtherMouse);
%                     iPairIndex = a2iPairInd(iMouseA, iMouseB);
%                     aiInterval = max( iTimeScale+1, astrctBehaviors{iMouseIter}(iBehaviorIter ).m_iStart-iGapLength-iNegativeLength): ...
%                         max( iTimeScale+1, astrctBehaviors{iMouseIter}(iBehaviorIter ).m_iStart-iGapLength-1);
%                     aiInterval = aiInterval(a2bBehaviorPos(iPairIndex, aiInterval) < 1);
%                     a2bBehaviorPos(iPairIndex, aiInterval) = -1;
%                     if ~bSingle
%                         iPairIndex = a2iPairInd(iMouseB, iMouseA);                    
%                         aiInterval = min( iNumFrames, astrctBehaviors{iMouseIter}(iBehaviorIter ).m_iEnd+iGapLength+1): ...
%                             min( iNumFrames, astrctBehaviors{iMouseIter}(iBehaviorIter ).m_iEnd+iGapLength+iNegativeLength);
%                         aiInterval = aiInterval(a2bBehaviorPos(iPairIndex, aiInterval) < 1);
%                         a2bBehaviorPos(iPairIndex, aiInterval) = -1;
%                     end
%                 end
%             end
%         end
%     end
% end
% save a2bBehaviorPos a2bBehaviorPos;
% 
% %% calc features
% display(['Learning classifier for behavior type: ' sBehaviorType])
% aFeatures = [];
% aTags =[];
% for iMouseInd=1:iNumMice
%     aFullFeatures = fnCalcMouseFeatures(iMouseInd, astrctTrackers, globalBCparams);
%     aPairInds = getPairInds(globalBCparams, iMouseInd, iNumMice);
%     aOBfeatures = fnCalcOtherBehaviorFeatures(aOBtags(aPairInds,:,:), aiOBfeatureNum, abOBelapted, abOBfreq, aiOBtimeScale);
%     [aFeatures1, aTags1] = fnCutRelevantFeatureSegments(aFullFeatures, a2bBehaviorPos(aPairInds, 1:iNumFrames));
%     aFeatures1 = [aFeatures1; fnCutRelevantOBfeatureSegments(aOBfeatures, a2bBehaviorPos(aPairInds, 1:iNumFrames))];
%     aFeatures = [aFeatures aFeatures1];
%     aTags = [aTags aTags1];
% end
% 
% %% create classifer
% if nargin < 4
%     if isempty(globalBCparams.Boosting.fMaxMissRate)
%         strctClassifier = gentleBoost(aFeatures, aTags, globalBCparams.Boosting.iMaxNrounds, globalBCparams.Boosting.fLookNoFurtherError);
%     else
%         if isempty(globalBCparams.Boosting.iMaxIterations)
%             iMaxIterations = 10;
%         else
%             iMaxIterations = globalBCparams.Boosting.iMaxIterations;
%         end
%         negWeight = 1;
%         for iter=1:iMaxIterations
%             [strctClassifier, missRate] = gentleBoost(aFeatures, aTags, globalBCparams.Boosting.iMaxNrounds, globalBCparams.Boosting.fLookNoFurtherError, [], negWeight);
%  save a2bBehaviorPos a2bBehaviorPos aTags strctClassifier missRate aFeatures
%             if missRate < globalBCparams.Boosting.fMaxMissRate
%                 break;
%             end
%             negWeight = negWeight * globalBCparams.Boosting.fMaxMissRate/missRate;
%         end
%     end
% else
%     strctClassifier = gentleBoost(aFeatures, aTags, globalBCparams.Boosting.iMaxNrounds, globalBCparams.Boosting.fLookNoFurtherError, triggerHappyFactor);
% end
% 
% clear globalBCparams;

function aPairInds=getPairInds(BCparams, iMouseInd, iNumMice)
% if ~(BCparams.Features.bCoordinates || BCparams.Features.bDistances || BCparams.Features.bMousePair);
if ~BCparams.Features.bMousePair;
    aPairInds = iMouseInd;
else
    aPairInds = (iNumMice-1)*(iMouseInd-1)+1:(iNumMice-1)*iMouseInd;
end


