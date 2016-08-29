function abBehaviors = fnConvertBehaviorStructToMatrix(astrctBehaviors, strSelectedBehavior, iNumFrames, a2iPairInd, iStartFrame)
%
if nargin < 5
    iStartFrame = 1;
end
iNumPairs = max(a2iPairInd(:));
abBehaviors = false(iNumPairs, iNumFrames);
for iMouse=1:length(astrctBehaviors)
    iNumBehaviors = length(astrctBehaviors{iMouse});
    for k=1:iNumBehaviors
        if isBehaviorType(astrctBehaviors{iMouse}(k).m_strAction, strSelectedBehavior)
            aiInterval = (astrctBehaviors{iMouse}(k).m_iStart:astrctBehaviors{iMouse}(k).m_iEnd) - iStartFrame + 1;
            iMouseB = astrctBehaviors{iMouse}(k).m_iOtherMouse;
            abBehaviors(a2iPairInd(iMouse, iMouseB), aiInterval) = true;
        end
    end
end

