function b = isNegativeBehaviorType(sAction, sBehaviorType)
%
sNegativeBehaviorType = ['-' sBehaviorType];
b = isBehaviorType(sAction, sNegativeBehaviorType);
