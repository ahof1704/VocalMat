function [aFeatures,aTags]=fnCutRelevantFeatureSegments(aFullFeatures, BCparams, a2bBehaviorPos)
%
aTags = [];
aFeatures = [];
iNumStaticFeatures = size(aFullFeatures, 1);
iNumTimeScales = size(aFullFeatures, 4); % including scale 0
iNumFeatures = iNumStaticFeatures * iNumTimeScales;
iNumFrames = size(aFullFeatures, 2);
iNumOtherMice = size(aFullFeatures, 3);
if nargin == 3
    assert(iNumOtherMice==size(a2bBehaviorPos, 1), 'NumOtherMice conflict');
end
Np1 = sum([BCparams.MousePOIs{1}.aPointsNum]);
Np2 = sum([BCparams.MousePOIs{2}.aPointsNum]);
Npc = Np1 * Np2;
bThresholdLike = false;
if nargin > 1
    if isfield(BCparams.Features, 'bThresholdLike')
        bThresholdLike = BCparams.Features.bThresholdLike;
    end
end

for iPair=1:iNumOtherMice
    if nargin<3
        i = true(1, iNumFrames);
    else
        y = a2bBehaviorPos(iPair, :);
        i = y~=0;
        aTags = [aTags y(i)];
    end
    Ftl = [];
    if bThresholdLike
        Dmin = min(aFullFeatures(iNumStaticFeatures-Npc+1:iNumStaticFeatures,i,iPair,1), [], 1);
        Dmax = max(aFullFeatures(iNumStaticFeatures-Npc+1:iNumStaticFeatures,i,iPair,1), [], 1);
        Smin = min(aFullFeatures(iNumStaticFeatures-Npc+1:iNumStaticFeatures,i,iPair,2), [], 1);
        Smax = max(aFullFeatures(iNumStaticFeatures-Npc+1:iNumStaticFeatures,i,iPair,2), [], 1);
        Ftl = [Dmin; Dmax; Dmax-Dmin; Smin; Smax; Smax-Smin];
    end
    aFeatures = [aFeatures [reshape(permute(aFullFeatures(:,i,iPair,:), [1,4,2,3]), iNumFeatures, sum(i)); Ftl]];
end
