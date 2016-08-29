function astrctBehaviors = fnCombineAnnotation(astrctBehaviors1, astrctBehaviors2, sBehaviorType, operator, iMinLength)
%
if nargin < 5
    iMinLength = 0;
end
iNumMice = length(astrctBehaviors1);
astrctBehaviors = cell(iNumMice, 1);
for iMouse=1:iNumMice
    iNumFrames = 0;
    if ~isempty(astrctBehaviors1{iMouse})
        iNumFrames = max([astrctBehaviors1{iMouse}.m_iEnd]) + 1;
    end
    if ~isempty(astrctBehaviors2{iMouse})
        iNumFrames = max([iNumFrames [astrctBehaviors2{iMouse}.m_iEnd]]) + 1;
    end
    if iNumFrames > 0
        [abBehavior1, aiOtherMouse1] = fnConvertBehaviorStructToVector(astrctBehaviors1, iMouse, sBehaviorType, iNumFrames);
        [abBehavior2, aiOtherMouse2] = fnConvertBehaviorStructToVector(astrctBehaviors2, iMouse, sBehaviorType, iNumFrames);
        eval(['abBehavior = abBehavior1 ' operator ' abBehavior2;']);
%         abBehavior(10001:end) = false;
        aiOtherMouse = max(aiOtherMouse1, aiOtherMouse2);
        astrctBehaviors{iMouse} = fnConvertVectorToBehaviorStruct(abBehavior, aiOtherMouse, sBehaviorType, iMouse, false, iMinLength);
        
        [abBehavior1, aiOtherMouse1] = fnConvertBehaviorStructToVector(astrctBehaviors1, iMouse, ['-' sBehaviorType], iNumFrames);
        [abBehavior2, aiOtherMouse2] = fnConvertBehaviorStructToVector(astrctBehaviors2, iMouse, ['-' sBehaviorType], iNumFrames);
        eval(['abBehavior = abBehavior1 ' operator ' abBehavior2;']);
%         abBehavior(10001:end) = false;
        aiOtherMouse = max(aiOtherMouse1, aiOtherMouse2);
        astrctBehaviors{iMouse} = [astrctBehaviors{iMouse} fnConvertVectorToBehaviorStruct(abBehavior, aiOtherMouse, ['-' sBehaviorType], iMouse, false, iMinLength)];
    end
end
astrctBehaviors = fnSetOtherBehaviors(astrctBehaviors, astrctBehaviors1, sBehaviorType);
