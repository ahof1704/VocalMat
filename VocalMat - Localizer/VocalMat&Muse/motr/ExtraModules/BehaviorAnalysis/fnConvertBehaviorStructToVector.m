function [abBehavior, aiOtherMouse] = fnConvertBehaviorStructToVector(astrctBehaviors, iMouse, strSelectedBehavior, iNumFrames)
iNumBehaviors = length(astrctBehaviors{iMouse});
abBehavior = false(1, iNumFrames) ;
aiOtherMouse = zeros(1, iNumFrames);
for k=1:iNumBehaviors
    if isBehaviorType(astrctBehaviors{iMouse}(k).m_strAction, strSelectedBehavior)
        if astrctBehaviors{iMouse}(k).m_iStart <= iNumFrames
            aiInterval = astrctBehaviors{iMouse}(k).m_iStart:min(astrctBehaviors{iMouse}(k).m_iEnd, iNumFrames);
            abBehavior(aiInterval) = true;
            aiOtherMouse(aiInterval) = astrctBehaviors{iMouse}(k).m_iOtherMouse;
        end
    end
end

return;