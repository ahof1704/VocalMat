function astrctBehaviors = fnOferEntryPoint(astrctBehaviors, astrctTrackers, strctClassifier, BCparams, iMinLength, iStartFrame)

sBehaviorType = BCparams.sBehaviorType;
if nargin<4
    iMinLength = 3;
end
if nargin<5
    iStartFrame = 1;
end
display(['classifying behavior type: ' sBehaviorType])

%%
iNumFrames = length(astrctTrackers(1).m_afX);
iNumMice = length(astrctTrackers);
[iNumPairs, a2iPairs, a2iPairInd]=getSetIndices(~BCparams.Features.bMousePair, iNumMice);

[acOBs, aiOBfeatureNum, abOBelapted, abOBfreq, aiOBtimeScale]  = getRelevantOtherBehaviors(BCparams);
aOBfeatures = zeros(sum(aiOBfeatureNum), iNumFrames, iNumPairs);
abAllowedTags = zeros(1, iNumFrames);
for i=1:size(BCparams.aiIntervals, 1)
    abAllowedTags(BCparams.aiIntervals(i,1):BCparams.aiIntervals(i,2)) = 1;
end
[abAllTags, iNumEvents, iPosFramesNum] = fnBuildBehaviorTags(astrctBehaviors, iNumPairs, abAllowedTags, true);
astrctBehaviors = cell(iNumMice, 1);

%% calc features
aFeatures = [];
for iMouseInd=1:iNumMice
    aFullFeatures = fnCalcMouseFeatures(iMouseInd, astrctTrackers, BCparams);
    aFeatures1 = fnCutRelevantFeatureSegments(aFullFeatures, BCparams);
    if iNumEvents > 0 % other behaviors
        aPairInds = getPairInds(BCparams, iMouseInd, iNumMice);
        aOBfeatures = fnCalcOtherBehaviorFeatures(abAllTags(aPairInds,:,:), aiOBfeatureNum, abOBelapted, abOBfreq, aiOBtimeScale);
        aFeatures1 = [aFeatures1; fnCutRelevantOBfeatureSegments(aOBfeatures)];
    end
    aFeatures = [aFeatures aFeatures1];
end

%% Run algorithm to detect  behaviors...
abTagRes = reshape(strongGentleClassifier(aFeatures, strctClassifier)', iNumFrames, iNumPairs)';
if ~isBehaviorType(sBehaviorType, 'Following')
   abTagRes = sign(abTagRes);
end
iTimeScale = max(BCparams.Features.aTimeScales) + BCparams.Features.iSelfTimeScale + 1;
abTagRes(:,1:iTimeScale) = 0;
clear BCparams;

%% format output
abTagRes(:,[1 iNumFrames]) = 0;
for iPair=1:iNumPairs
    abBehavior = abTagRes(iPair,:);
    m = a2iPairs(iPair,:);
    astrctBehaviorsPair= fnConvertVectorToBehaviorStruct(abBehavior, m(2), sBehaviorType, m(1), false, 3+isBehaviorType(sBehaviorType, 'Mating')*27, iStartFrame);
    if ~isempty(astrctBehaviors{m(1)}) && ~isfield(astrctBehaviors{m(1)}(1), 'm_fScore')
        astrctBehaviors = fnAddFieldToStructArray(astrctBehaviors, 'm_fScore', 0)
    end
    astrctBehaviors{m(1)} = [astrctBehaviors{m(1)} astrctBehaviorsPair];
end

