function astrctBehaviors = fnSetOtherBehaviors(astrctBehaviors1, astrctBehaviors2, sBehaviorType)
%
astrctBehaviors = cell(size(astrctBehaviors1));
iNumMice = length(astrctBehaviors1);
for iMouse=1:iNumMice
    iNumBehaviors = length(astrctBehaviors1{iMouse});
    for k=1:iNumBehaviors
        if isPosNegBehaviorType(astrctBehaviors1{iMouse}(k).m_strAction, sBehaviorType)
            astrctBehaviors{iMouse} = [astrctBehaviors{iMouse} astrctBehaviors1{iMouse}(k)];
        end
    end
    iNumBehaviors = length(astrctBehaviors2{iMouse});
    for k=1:iNumBehaviors
        if ~isPosNegBehaviorType(astrctBehaviors2{iMouse}(k).m_strAction, sBehaviorType)
            astrctBehaviors{iMouse} = [astrctBehaviors{iMouse} astrctBehaviors2{iMouse}(k)];
        end
    end
end
