function [abBehavior, aiOtherMouse] = fnConvertBehaviorStructToVector(astrctBehaviors, iMouse, strSelectedBehavior, iNumFrames)
iNumBehaviors = length(astrctBehaviors{iMouse});
abBehavior = zeros(1, iNumFrames) > 0;
aiOtherMouse = zeros(1, iNumFrames);
for k=1:iNumBehaviors
    if strcmpi(astrctBehaviors{iMouse}(k).m_strAction, strSelectedBehavior)
        aiInterval = astrctBehaviors{iMouse}(k).m_iStart:astrctBehaviors{iMouse}(k).m_iEnd;
        abBehavior(aiInterval) = true;
        aiOtherMouse(aiInterval) = astrctBehaviors{iMouse}(k).m_iOtherMouse;
    end
end
for iOtherMouse=1:4
    if iOtherMouse~=iMouse
        iNumBehaviors = length(astrctBehaviors{iOtherMouse});
        for k=1:iNumBehaviors
            if strcmpi(astrctBehaviors{iOtherMouse}(k).m_strAction, strSelectedBehavior) & aiOtherMouse(aiInterval)==iMouse                    
                aiInterval = astrctBehaviors{iOtherMouse}(k).m_iStart:astrctBehaviors{iOtherMouse}(k).m_iEnd;
                abBehavior(aiInterval) = true;
            end
        end
    end
end

return;