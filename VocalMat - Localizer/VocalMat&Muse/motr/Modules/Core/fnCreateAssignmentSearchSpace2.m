function a2bReasonable = fnCreateAssignmentSearchSpace2(astrctPredictedEllipses,...
    astrctObservedEllipses,abLostMice,a2iLForeground,afVelocity)

% Determine which blobs could reasonably be assigned to which trackers,
% based on the distance from each tracker to the blob boundary.
% This is returned in a2bReasonable, which is iNumMice x iNumBlobs.
% ALT, 2012-03-30
 
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

% SO 17 Sep 2011
% a2iAssignments is of size NumMice X NumBlobs
% It used to contain a binary mask telling whether it is reasonable to
% assign a blob to a given mouse.
% OA changed it to be non-binary and to contain the area of the blob (in
% pixels) instead

% Export globals we'll need.
global g_strctGlobalParam
fSearchSpaceHighVelocityThreshold = ...
  g_strctGlobalParam.m_strctTracking.m_fSearchSpaceHighVelocity;
fSearchSpaceInPixLowVelocity = ...
  g_strctGlobalParam.m_strctTracking.m_fSearchSpaceInPixLowVelocity;
fSearchSpaceInPixHighVelocity = ...
  g_strctGlobalParam.m_strctTracking.m_fSearchSpaceInPixHighVelocity;
clear g_strctGlobalParam

% Get dimensions.
iNumMiceTrackers = length(astrctPredictedEllipses);
iNumBlobs = length(astrctObservedEllipses);
iNumMice = iNumMiceTrackers;

% Update the user if a mouse was lost.
if any(abLostMice)
    fprintf('Warning: At least one mouse is lost\n');
end;

% Compute the distance from the center of each tracker to the nearest
% point on the boundary of each blob (a2fMuDistMatrix).
a2fMuDistMatrix = zeros(iNumMiceTrackers, iNumBlobs);
aiBlobAreas = zeros(1, iNumBlobs);
for iBlobIter=1:iNumBlobs
   a2bBlob = (a2iLForeground == iBlobIter);
   aiBlobAreas(iBlobIter) = sum(a2bBlob(:));
   acBoundaries = bwboundaries(a2bBlob,'noholes');
    a2iBlobBoundary = cat(1,acBoundaries{:});
    for iMouseIter=1:iNumMiceTrackers
        afDist = (astrctPredictedEllipses(iMouseIter).m_fX - a2iBlobBoundary(:,2)).^2+ ...
            (astrctPredictedEllipses(iMouseIter).m_fY - a2iBlobBoundary(:,1)).^2;
        a2fMuDistMatrix(iMouseIter, iBlobIter) = sqrt(min(afDist));
    end;
end

% Compute the maximum distance a "reasonable" blob can be from a tracker.
% I.e. If a blob is farther away than this, it is no longer reasonable to
% assign that blob to that mouse (a2fMaxDistThreshold).
a2fMaxDistThreshold = zeros(iNumMice,iNumBlobs);
a2fVelocities = repmat(afVelocity',1,iNumBlobs);
a2fMaxDistThreshold(a2fVelocities < fSearchSpaceHighVelocityThreshold) = ...
    fSearchSpaceInPixLowVelocity;
a2fMaxDistThreshold(a2fVelocities >= fSearchSpaceHighVelocityThreshold) = ...
    fSearchSpaceInPixHighVelocity;

% Compute whether each blob can be reasonably assigned to each mouse, based
% on comparing the blob-tracker distance with the blob-tracker threshold.
% Also, lost mice should not be assigned to any blob.
a2bReasonable = (a2fMuDistMatrix < a2fMaxDistThreshold);
a2bReasonable(abLostMice,:) = 0;

return;
