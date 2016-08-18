function [iGroupType] = fnGetGroups(a2fDist, fThreshold)
% Determine mice configuration
% iGroupType
% 1: 4 - all huddling (1 group)
% 2: 3 - 1 (three huddling, 1 roaming, two groups)
% 3: 2 - 2 (two groups of huddling, two groups)
% 4: 2 - 1 - 1 (two huddling, two roaming, three groups)
% 5: 1 - all roaming, four groups)

% Group type detailed:
% One Group
% 1: [1,2,3,4] 
% Two Groups (2-2)
% 2: [1,2], [3,4]
% 3: [1,3], [2,4]
% 4: [1,4], [2,3]

% Two groups (3-1)
% 5: [1,2,3] % four is out 
% 6: [1,2,4] % three is out
% 7: [1,3,4] % two is out
% 8: [2,3,4] % one is out

% Three Groups (2-1-1)
% 9: [1-2]
% 10: [1-3]
% 11: [1-4]
% 12: [2-3]
% 13: [2-4]
% 14: [3-4]

% Four groups
% 15: [1],[2],[3],[4]

a2bProximity = a2fDist < fThreshold;
a2bProximity(isnan(a2fDist)) = 0;
a2bProximityTransitiveClosure = fnGraphTransitiveClosure(a2bProximity);

% Iteratively parse the graph into largest connected sub components by
% removing a vertex and all the neighbhors (far or near)....
acGroups = {};
iNumMice = size(a2fDist,1);

aiRemoved = [];
iGroupCounter = 1;
for iIter=1:iNumMice
    if sum(iIter == aiRemoved) > 0
        % This was already counted in a previous group...
        continue;
    end;
    aiAllNeighors = find(a2bProximityTransitiveClosure(iIter,:));
    acGroups{iGroupCounter} = aiAllNeighors;
    iGroupCounter=iGroupCounter+1;
    aiRemoved = unique([aiRemoved,aiAllNeighors]);
end




%%
acAllPossibleGroupTypes = {
{{[1,2,3,4]}}       %1
{{[1,2],[3,4]}}     %2
{{[1,3],[2,4]}}     %3
{{[1,4],[2,3]}}     %4
{{[1,2,3],[4]}}     %5
{{[1,2,4],[3]}}     %6
{{[1,3,4],[2]}}     %7
{{[2,3,4],[1]}}     %8
{{[1,2],[3],[4]}}   %9
{{[1,3],[2],[4]}}   %10
{{[1,4],[2],[3]}}   %11
{{[2,3],[1],[4]}}   %12
{{[2,4],[1],[3]}}   %13
{{[3,4],[1],[2]}}   %14
{{[1],[2],[3],[4]}} %15
}; 

iNumGroups = length(acGroups);
iGroupType = [];
for iGroupTypeIter=1:length(acAllPossibleGroupTypes)
   if length(acAllPossibleGroupTypes{iGroupTypeIter}{1}) == iNumGroups
        % Major type detected. Now - fine type
        bCorrectTrialType = true;
        for i=1:iNumGroups
            bMatchFound = false;
            for j=1:iNumGroups
                if length(acGroups{i}) == length(acAllPossibleGroupTypes{iGroupTypeIter}{1}{j}) && ...
                    all(sort(acGroups{i}) == sort(acAllPossibleGroupTypes{iGroupTypeIter}{1}{j}))
                    bMatchFound = true;
                end
            end
            if ~bMatchFound
                bCorrectTrialType = false;
            end;
        end
        if bCorrectTrialType
            iGroupType = iGroupTypeIter;
            break;
        end
   end
end

return;



function a2bTransitiveClosureAdjacencyMatrix = fnGraphTransitiveClosure(a2bAdjacencyMatrix)

a2bTransitiveClosureAdjacencyMatrix = a2bAdjacencyMatrix;


while 1
    a2bNewAdjacencyMatrix = a2bTransitiveClosureAdjacencyMatrix |...
        ((double(a2bTransitiveClosureAdjacencyMatrix)*double(a2bTransitiveClosureAdjacencyMatrix))>0);
    if ~any(a2bNewAdjacencyMatrix - a2bTransitiveClosureAdjacencyMatrix)
        break;
    end
    a2bTransitiveClosureAdjacencyMatrix = double(a2bNewAdjacencyMatrix);
end

return;
