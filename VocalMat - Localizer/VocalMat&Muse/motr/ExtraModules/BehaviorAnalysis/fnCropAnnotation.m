function astrctBehaviors = fnCropAnnotation(astrctBehaviors0, sBehaviorType, aiIntervals)
%
iNumMice = length(astrctBehaviors0);
iNumFrames = max(aiIntervals(:,2));
abAllowedTags = false(1, iNumFrames);
for i=1:size(aiIntervals, 1)
    abAllowedTags(aiIntervals(i,1):aiIntervals(i,2)) = true;
end

for iMouse=1:iNumMice
    [abBehavior, aiOtherMouse] = fnConvertBehaviorStructToVector(astrctBehaviors0, iMouse, sBehaviorType, iNumFrames);
    abBehavior = abBehavior & abAllowedTags;
    astrctBehaviors{iMouse} = fnConvertVectorToBehaviorStruct(abBehavior, aiOtherMouse, sBehaviorType, iMouse, true);
%     [abBehavior, aiOtherMouse] = fnConvertBehaviorStructToVector(astrctBehaviors0, iMouse, ['-' sBehaviorType], iNumFrames);
%     abBehavior = abBehavior & abAllowedTags;
%     astrctBehaviors{iMouse} = [astrctBehaviors{iMouse} fnConvertVectorToBehaviorStruct(abBehavior, aiOtherMouse, ['-' sBehaviorType], iMouse, true)];
end
astrctBehaviors = fnSetOtherBehaviors(astrctBehaviors, astrctBehaviors0, sBehaviorType);

