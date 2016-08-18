function iBind = getBehaviorInd(sAction, sBehaviorType, acOBs, bOnlyOther)
iOBind = getOtherBehaviorInd(sAction, acOBs);
if iOBind > 0
    iBind = iOBind + 1-bOnlyOther;
    return;
end
if ~bOnlyOther
    iBind = isBehaviorType(sAction, sBehaviorType);
    if iBind == 0
        iBind = -isNegativeBehaviorType(sAction, sBehaviorType);
    end
else
    iBind = 1;
end
