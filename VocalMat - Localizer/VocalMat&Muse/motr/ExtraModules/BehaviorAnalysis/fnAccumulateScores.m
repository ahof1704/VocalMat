function afScores = fnAccumulateScores(astrctBehaviors, strSelectedBehavior)
%
iNumMice = length(astrctBehaviors);
afScores =zeros(iNumMice);
for iMouse=1:iNumMice
    iNumBehaviors = length(astrctBehaviors{iMouse});
    for k=1:iNumBehaviors
        if isBehaviorType(astrctBehaviors{iMouse}(k).m_strAction, strSelectedBehavior)
            iMouseB = astrctBehaviors{iMouse}(k).m_iOtherMouse;
            afScores(iMouse, iMouseB) = afScores(iMouse, iMouseB) + astrctBehaviors{iMouse}(k).m_fScore;
        end
    end
end

