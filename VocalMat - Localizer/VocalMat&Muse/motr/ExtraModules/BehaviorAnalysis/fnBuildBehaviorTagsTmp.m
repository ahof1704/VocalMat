function [abTags, aiNumEvents, aiNumFrames] = fnBuildBehaviorTagsTmp(astrctBehaviors, iNumPairs, abAllowedTags, bOnlyOther, iStartFrame)
%
global globalBCparams;

[acOBs, aiOBfeatureNum, abOBelapted, abOBfreq, aiOBtimeScale]  = getRelevantOtherBehaviors(globalBCparams);
iNumBehaviorTypes = length(acOBs) + 1-bOnlyOther;
if iNumBehaviorTypes <  1
    abTags = [];
    aiNumEvents = 0;
    aiNumFrames = 0;
    return;
end
sBehaviorType = globalBCparams.sBehaviorType;

iNumFrames = length(abAllowedTags);
abTags = zeros(iNumPairs, iNumBehaviorTypes, iNumFrames);
iNumMice = length(astrctBehaviors);
bSingle = ~globalBCparams.Features.bMousePair;
[iNumPairs, a2iPairs, a2iPairInd]=getSetIndices(bSingle, iNumMice);
iMaxMouseB = bSingle + iNumMice*(1-bSingle);

Wpn = [globalBCparams.Boosting.fPosNegWeight; 1-globalBCparams.Boosting.fPosNegWeight];
Nfr = aiNumFrames(1,:)*Wpn;
Nev = aiNumEvents(1,:)*Wpn;
Wef = [1-globalBCparams.Boosting.fWeightScheme; globalBCparams.Boosting.fWeightScheme];
Cf = Wef(2);
Ce = Nfr * Wef(1)/Nev;
for iMouseIter = 1:iNumMice
    iNumBehaviors = length(astrctBehaviors{iMouseIter});
    for iBehaviorIter = 1:iNumBehaviors
        sAction = astrctBehaviors{iMouseIter}(iBehaviorIter ).m_strAction;
        iBind = getBehaviorInd(sAction, sBehaviorType, acOBs, bOnlyOther); % isBehaviorType(sAction, sBehaviorType);
        if abs(iBind) == 1 
            aiInterval = astrctBehaviors{iMouseIter}(iBehaviorIter ).m_iStart:astrctBehaviors{iMouseIter}(iBehaviorIter ).m_iEnd;
            aiInterval = aiInterval - iStartFrame + 1;
            if any(abAllowedTags(aiInterval))
                L = length(aiInterval);
                w = (Ce/L + Cf) * sign(double(iBind));
                if abs(w+1) < 0.0001
                    w = 0.9999;
                end
                iMouseA = astrctBehaviors{iMouseIter}(iBehaviorIter ).m_iMouse;
                iMouseB = min(max(1, astrctBehaviors{iMouseIter}(iBehaviorIter ).m_iOtherMouse), iMaxMouseB);
                abTags(a2iPairInd(iMouseA, iMouseB), abs(iBind), aiInterval) = w;
            end
        end
    end
end
clear globalBCparams;

