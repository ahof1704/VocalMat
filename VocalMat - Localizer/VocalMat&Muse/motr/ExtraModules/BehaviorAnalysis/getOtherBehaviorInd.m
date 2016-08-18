function iOBind = getOtherBehaviorInd(sAction, acOBs)
%
if isempty(acOBs)
    iOBind = 0;
    return;
end
acAction = cell(size(acOBs));
 [acAction{:}] = deal(sAction);
iOBind = find(cellfun(@strcmp, acAction, acOBs));
assert(length(iOBind) <= 1, 'Seems like duplicate behavior types');
if isempty(iOBind)
    iOBind = 0;
end
