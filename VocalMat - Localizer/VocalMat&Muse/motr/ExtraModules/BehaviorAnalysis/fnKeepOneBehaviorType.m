function astrctBehaviorsOut=fnKeepOneBehaviorType(astrctBehaviors, sBehaviorType)
%
iNumMice = length(astrctBehaviors);
astrctBehaviorsOut = cell(size(astrctBehaviors));
for iMouseIter = 1:iNumMice
    iNumBehaviors = length(astrctBehaviors{iMouseIter});
    iBehaviorIterOut = 1;
    for iBehaviorIter = 1:iNumBehaviors
        if strcmp(  astrctBehaviors{iMouseIter}(iBehaviorIter ).m_strAction, sBehaviorType )
            astrctBehaviorsOut{iMouseIter}(iBehaviorIterOut ) = astrctBehaviors{iMouseIter}(iBehaviorIter );
            iBehaviorIterOut = iBehaviorIterOut + 1;
        end
    end
end


