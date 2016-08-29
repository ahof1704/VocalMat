function [abTags, aiNumEvents, aiNumFrames] = fnBuildBehaviorTags(astrctBehaviors, iNumPairs, abAllowedTags, bOnlyOther, iStartFrame, bAssignWeight, aiNumEventsIn, aiNumFramesIn)
%
if nargin<5
    iStartFrame = 1; 
    bAssignWeight = false; 
end

global globalBCparams;

acOBs = getRelevantOtherBehaviors(globalBCparams);
iNumBehaviorTypes = length(acOBs) + 1-bOnlyOther;
if iNumBehaviorTypes <  1
    abTags = [];
    if ~bAssignWeight
        aiNumEvents = 0;
        aiNumFrames = 0;
    end
    return;
end
sBehaviorType = globalBCparams.sBehaviorType;

iNumFrames = length(abAllowedTags);
abTags = zeros(iNumPairs, iNumBehaviorTypes, iNumFrames);
iNumMice = length(astrctBehaviors);
bSingle = ~globalBCparams.Features.bMousePair;
[iNumPairs, a2iPairs, a2iPairInd]=getSetIndices(bSingle, iNumMice);
iMaxMouseB = bSingle + iNumMice*(1-bSingle);

if bAssignWeight
    Wpn = [globalBCparams.Boosting.fPosNegWeight; 1-globalBCparams.Boosting.fPosNegWeight];
    Nfr = aiNumFramesIn(1,:)*Wpn;
    Nev = aiNumEventsIn(1,:)*Wpn;
    Wef = [1-globalBCparams.Boosting.fWeightScheme; globalBCparams.Boosting.fWeightScheme];
    Cf = Wef(2);
    Ce = Nfr * Wef(1)/Nev;
end
aiNumFrames = zeros(iNumBehaviorTypes, 2);
aiNumEvents = zeros(iNumBehaviorTypes, 2);
for iMouseIter = 1:iNumMice
    iNumBehaviors = length(astrctBehaviors{iMouseIter});
    for iBehaviorIter = 1:iNumBehaviors
        sAction = astrctBehaviors{iMouseIter}(iBehaviorIter ).m_strAction;
        iBind = getBehaviorInd(sAction, sBehaviorType, acOBs, bOnlyOther); % isBehaviorType(sAction, sBehaviorType);
        if abs(iBind) == 1 || (~bAssignWeight && iBind~=0)
            aiInterval = astrctBehaviors{iMouseIter}(iBehaviorIter ).m_iStart:astrctBehaviors{iMouseIter}(iBehaviorIter ).m_iEnd;
            aiInterval = aiInterval - iStartFrame + 1;
            if any(abAllowedTags(aiInterval))
                if bAssignWeight
                    L = length(aiInterval);
                    w = (Ce/L + Cf) * sign(double(iBind));
                    if abs(w+1) < 0.0001
                        w = 0.9999;
                    end
                else
                    w = sign(double(iBind)) - (iBind==-1);
                end
                iMouseA = astrctBehaviors{iMouseIter}(iBehaviorIter ).m_iMouse;
                assert(iMouseA==iMouseIter, 'iMouse~=iMouseIter');
                iMouseB = min(max(1, astrctBehaviors{iMouseIter}(iBehaviorIter ).m_iOtherMouse), iMaxMouseB);
                abTags(a2iPairInd(iMouseA, iMouseB), abs(iBind), aiInterval) = w;
                iBsign = (1-sign(double(iBind)))/2 + 1;
                aiNumFrames(abs(iBind), iBsign) = aiNumFrames(abs(iBind), iBsign) + length(aiInterval);
                aiNumEvents(abs(iBind), iBsign) = aiNumEvents(abs(iBind), iBsign) + 1;
            end
        end
    end
end
clear globalBCparams;

    