function astrctBehaviors = fnAddAnnotatedFalses(astrctBehaviors1, astrctBehaviors2, sBehaviorType)
%
astrctBehaviors = astrctBehaviors1;
iNumMice = length(astrctBehaviors2);
sAction = ['-' sBehaviorType];
for iMouse=1:iNumMice
    for j=1:length(astrctBehaviors2{iMouse})
        if isBehaviorType(astrctBehaviors2{iMouse}(j).m_strAction, sBehaviorType)
            strctBehavior = astrctBehaviors2{iMouse}(j);
            strctBehavior.m_strAction = sAction;
            astrctBehaviors{iMouse} = [astrctBehaviors{iMouse} strctBehavior];
        end
    end
end

