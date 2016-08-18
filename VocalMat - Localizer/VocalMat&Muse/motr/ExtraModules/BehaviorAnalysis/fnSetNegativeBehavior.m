function astrctBehaviors = fnSetNegativeBehavior(astrctBehaviors, astrctBehaviors1, sBehaviorType)
%
sNegativeBehaviorType = ['-' sBehaviorType];
iNumMice = length(astrctBehaviors1);
for iMouse=1:iNumMice
    iNumBehaviors = length(astrctBehaviors1{iMouse});
    for k=1:iNumBehaviors
        if isBehaviorType(astrctBehaviors1{iMouse}(k).m_strAction, sBehaviorType)
            strctBehavior = astrctBehaviors1{iMouse}(k);
            strctBehavior.m_strAction = sNegativeBehaviorType;
            astrctBehaviors{iMouse} = [astrctBehaviors{iMouse} strctBehavior];
        end
    end
end
