function astrctBehaviors = fnNegateAnnotation(astrctBehaviors, sBehaviorType)
%
iNumMice = length(astrctBehaviors);
for iMouse=1:iNumMice
    for j=1:length(astrctBehaviors{iMouse})
        sAction = astrctBehaviors{iMouse}(j).m_strAction;
        if isPosNegBehaviorType(sAction, sBehaviorType)
            if sAction(1) == '-'
                sAction = sAction(2:end);
            else
                sAction = ['-' sAction];
            end
            astrctBehaviors{iMouse}(j).m_strAction = sAction;
        end
    end
end

