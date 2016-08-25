function astrctBehavior = fnCutBehaviorStruct(astrctBehaviorFull, iStartFrame, iEndFrame, bRestart)
%
if nargin < 4
   bRestart = false;
end
iNumMice = length(astrctBehaviorFull);
astrctBehavior = cell(iNumMice,1);
for iMouseIter = 1:iNumMice
    iNumBehaviors = length(astrctBehaviorFull{iMouseIter});
    for iBehaviorIter = 1:iNumBehaviors
        strctBehavior = astrctBehaviorFull{iMouseIter}(iBehaviorIter);
        iStart = max(iStartFrame, strctBehavior.m_iStart);
        iEnd = min(iEndFrame, strctBehavior.m_iEnd);
        if iEnd > iStart
            strctBehavior.m_iStart = iStart - bRestart*(iStartFrame-1);
            strctBehavior.m_iEnd = iEnd - bRestart*(iStartFrame-1);
            astrctBehavior{iMouseIter} = [astrctBehavior{iMouseIter} strctBehavior];
        end
    end
end
