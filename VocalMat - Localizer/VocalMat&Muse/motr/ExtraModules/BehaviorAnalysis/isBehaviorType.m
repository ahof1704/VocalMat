function b = isBehaviorType(sAction, sBehaviorType)
%
if iscell(sBehaviorType)
    sBehaviorType = sBehaviorType{1};
end
b = strcmp(sAction, sBehaviorType);
if b
    return;
end
sBehaviorType(sBehaviorType=='_') = ' ';
b = strcmp(sAction, sBehaviorType);
if b
    return;
end
sAction(sAction=='_') = ' ';
b = strcmp(sAction, sBehaviorType);
