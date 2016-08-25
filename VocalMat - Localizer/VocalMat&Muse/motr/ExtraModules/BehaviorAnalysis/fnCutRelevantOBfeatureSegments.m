function aFeatures=fnCutRelevantOBfeatureSegments(aFullFeatures, a2bBehaviorPos)
%
aFeatures = [];
iNumFeatures = size(aFullFeatures, 1);
iNumFrames = size(aFullFeatures, 2);
iNumOtherMice = size(aFullFeatures, 3);

for iPair=1:iNumOtherMice
    if nargin<2
        i = 1:iNumFrames;
    else
        y = a2bBehaviorPos(iPair, :);
        i = find(y~=0);
    end
    aFeatures = [aFeatures reshape(aFullFeatures(:,i,iPair), iNumFeatures, length(i))];
end
