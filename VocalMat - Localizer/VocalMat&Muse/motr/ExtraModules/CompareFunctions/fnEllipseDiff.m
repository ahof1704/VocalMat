function [bDiff, afMaxDist] = fnEllipseDiff(astrctTrackers0, astrctTrackers1, bLargeDiff)
%
[a3fMu0, a4fCov0] = fnTrackerArrayToCov(astrctTrackers0);
[a3fMu1, a4fCov1] = fnTrackerArrayToCov(astrctTrackers1);

d = 8^2;
D = 30^2;
if bLargeDiff
   d = 30^2;
   D = 2000^2;
end

dist = squeeze(sum((a3fMu0 - a3fMu1).^2, 1));
afMaxDist =  max(dist, [], 1);
bDiff = afMaxDist > d & afMaxDist < D;
% for i=1:size(a3fMu0,3)
%    if ~bDiff(i)
%       for j=1:size(a3fMu0,2)
%           if ~bDiff(i)
%               distCov = norm(a4fCov0(:,:,j,i) - a4fCov1(:,:,j,i), 'fro');
%               bDiff(i) = distCov > 4*d & distCov < 4*D;
%           end;
%       end;
%    end;
% end;
return;
