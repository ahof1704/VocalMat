function [astrctNewEllipses,astrctTrackersJob,abLostMice] = ...
  fnSolveAssignmentProblem(astrctTrackersHistory, ...
                           a2iLForeground, ...
                           iNumBlobs, ...
                           strctAdditionalInfo, ...
                           a2iFrame, ...
                           astrctTrackersJob, ...
                           abLostMice, ...
                           iOutputIndex)
  
% This is my understanding of this function.
% It may be somewhat wrong.  ALT, 2012-03-26
%
% This function takes a segmented frame as input, plus the trackers up to 
% and including the previous frame, and outputs direllipses for the current
% frame.
%
% Inputs:
%
%   astrctTrackersHistory: A 1 x iNumMice structure array with fields:
%     m_afX: 1 x iNumFramesSoFar
%     m_afY: 1 x iNumFramesSoFar
%     m_afA: 1 x iNumFramesSoFar
%     m_afB: 1 x iNumFramesSoFar
%     m_afTheta: 1 x iNumFramesSoFar
%   astrctTrackersHistory holds the direllipse for each mouse, at all 
%   frames processed prior to this one in the current interval.
%
%   a2iLForeground: A connected-components image.  Pels labelled zero are
%   background, any other natural number represents a particular connected 
%   component (i.e., a blob).
%    
%   iNumBlobs: The number of blobs in a2iLForeground.
%   max(a2iLForeground(:))==iNumBlobs.
%
%   strctAdditionalInfo: A scalar struct with these fields:
%                     strctBackground: [1x1 struct]
%                     strctAppearance: [1x1 struct]
%      m_a3fRepresentativeClassImages: [iH x iW x iNumMice double]
%           m_strctHeadTailClassifier: [1x1 struct]
%       m_strctMiceIdentityClassifier: [1x1 struct]
%   This holds a bunch of information, including the background image
%   the "appearance" HOG vectors, the representative image for each
%   mouse, the head-tail classifier, and the identity classifiers.
%
%   a2iFrame: The raw frame, as a uint8 image.
%
%   astrctTrackersJob: A 1 x iNumMice structure array with fields:
%     m_afX: 1 x (iNumFramesThisJob-1)
%     m_afY: 1 x (iNumFramesThisJob-1)
%     m_afA: 1 x (iNumFramesThisJob-1)
%     m_afB: 1 x (iNumFramesThisJob-1)
%     m_afTheta: 1 x (iNumFramesThisJob-1)
%     m_afHeadTail: 1 x (iNumFramesThisJob-1)
%     m_afHeadTailFlip: 1 x (iNumFramesThisJob-1)
%     m_a2fClassifer: (iNumFramesThisJob-1) x iNumMice  [sic]
%     m_a2fClassiferFlip: (iNumFramesThisJob-1) x iNumMice  [sic]
%   astrctTrackersJob seems to store the complete record of the 
%   trackers, but I'm not sure how it differs from astrctTrackersHistory,
%   aside from holdind a few additional things and being pre-allocated.
%
%   iOutputIndex: The index of the current frame within the current job
%   (one-based).
%
%
%
% Outputs:
%   
%   astrctNewEllipses: a 1xiNumMice direllipse struct, holding the
%   (first-draft?) direllipses for the current frame.
%
%   astrctTrackersJob: An updated version of the astrctTrackersJob provided
%   as an argument.  Seems to only differ from the input astrctTrackersJob
%   in certain narrow circumstances.

global g_strctGlobalParam
global g_bDebugMode

% Copyright (c) 2008 Shay Ohayon, California Institute of Technology. 
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

% Get the number of mice.
iNumMice = length(astrctTrackersHistory);

% Get a list of the pixels in each blob (the indexes are into the
% serialized image).  This will be used later.
astrctProps = regionprops(a2iLForeground,'PixelList');

% Make a prediction about where we expect the tracker directed ellipses 
% to be in this frame.  This based on an extrapolation from several
% previous frames, or just based on the last frame, depending on whether
% strctAdditionalInfo contains a field called 'bAvoidPrediction'.
% (Arguably, a better name for bAvoidPrediction would be
% bAvoidExtrapolation.)
if isfield(strctAdditionalInfo, 'bAvoidPrediction')
   % If bAvoidPrediction exists, just use the trackers from the last frame 
   % as the prediction.  Also, remove that field from strctAdditionalInfo.
   astrctPredictedEllipses=struct('m_fX',cell(1,iNumMice), ...
                                  'm_fY',cell(1,iNumMice), ...
                                  'm_fA',cell(1,iNumMice), ...
                                  'm_fB',cell(1,iNumMice), ...
                                  'm_fTheta',cell(1,iNumMice));
   for iMouse=1:iNumMice
      astrctPredictedEllipses(iMouse).m_fX = astrctTrackersHistory(iMouse).m_afX(end);
      astrctPredictedEllipses(iMouse).m_fY = astrctTrackersHistory(iMouse).m_afY(end);
      astrctPredictedEllipses(iMouse).m_fA = astrctTrackersHistory(iMouse).m_afA(end);
      astrctPredictedEllipses(iMouse).m_fB = astrctTrackersHistory(iMouse).m_afB(end);
      astrctPredictedEllipses(iMouse).m_fTheta = astrctTrackersHistory(iMouse).m_afTheta(end);
   end
   afVelocity = zeros(1,iNumMice);
   strctAdditionalInfo = rmfield(strctAdditionalInfo, 'bAvoidPrediction');
else
   % If bAvoidPrediciton doesn't exist, use several previous frames to
   % predict the current trackers.
   [astrctPredictedEllipses,abLostMiceJustNow, afVelocity] = ...
      fnComputePredTrackerValues(astrctTrackersHistory);
   abLostMice = abLostMice | abLostMiceJustNow; % if we haven't seen a value for more than 15 frames...
end

% Write to the log if we've lost track of any mice.
if any(abLostMiceJustNow)
   fnLog(['A mouse was just lost. abLostMiceJustNow = ' num2str(abLostMiceJustNow)]);
end

% Fit ellipses to each of the _blobs_.
astrctObservedEllipses = fnComputeObservedEllipses(a2iLForeground, iNumBlobs);

% Produce some debug output, if called for.
if g_bDebugMode 
    fnDrawScene(a2iLForeground, astrctPredictedEllipses,astrctObservedEllipses);
    hold on;
    fnDrawTrackers(astrctPredictedEllipses);
end;

% Determine which blobs are close enough to which trackers to be reasonably
% assigned to them.
a2bReasonable = fnCreateAssignmentSearchSpace2(astrctPredictedEllipses,astrctObservedEllipses,abLostMice,a2iLForeground,afVelocity);
% a2bReasonable is Mice X Blobs

%% hack to handle disappearing mice (see pera test sequence at frame 17700)
% The scenario will be that two trackers will be locked onto the same blob,
% while a large blob suddenly appear and will be unassigned since it will
% be too away from all other mice.
%aiUseableTrackers = find(sum(a2iAssignments,2) > 0);
abUseableTrackers=any(a2bReasonable,2);
aiUseableTrackers = find(abUseableTrackers);
% aiUseableTrackers indicates which trackers have blobs close to them.

% Figure out which blobs are assignable to some tracker (i.e. useable), and
% which not.
abUseableBlobs = any(a2bReasonable,1);
aiUseableBlobs = find(abUseableBlobs);
aiUnusableBlobs = find(~abUseableBlobs);

% If there are blobs that cannot reasonably be assigned to a (non-lost)
% tracker, try to deal with them.  (I think.  ALT, 2012-03-30)
bRecoveredFromBadTracking = false;
if ~isempty(aiUnusableBlobs)
   aiHist = fnLabelsHist(a2iLForeground);
   aiSizeOfUnusableBlobs = aiHist(aiUnusableBlobs+1);

   aiIndices = find(aiSizeOfUnusableBlobs > g_strctGlobalParam.m_strctTracking.m_fRecoverLostMouseReliableComponentSizePixels);
   aiLostTrackers = setdiff(1:iNumMice,aiUseableTrackers);
   if ~isempty(aiIndices) && ~isempty(aiLostTrackers)
      iNewBlob = aiUnusableBlobs(aiIndices(1)); % Take first one ? it's all heuristic anyway....
      % Find which trackers might have merged ? look in history and take
      % the pair that intersects the most ?

      [aiY,aiX]=find(a2iLForeground==iNewBlob);
      fCenterX = mean(aiX);
      fCenterY = mean(aiY);
      % Find which of the lost trackers is closest to the detected blob
      afDist = zeros(1, length(aiLostTrackers));
      for k=1:length(aiLostTrackers)
         iLastKnownPositionIndex = find(~isnan(astrctTrackersHistory(aiLostTrackers(k)).m_afX),1,'last');
         afDist(k) = sqrt(  (astrctTrackersHistory(aiLostTrackers(k)).m_afX(iLastKnownPositionIndex) - fCenterX).^2+...
            (astrctTrackersHistory(aiLostTrackers(k)).m_afY(iLastKnownPositionIndex) - fCenterY).^2);
      end;
      [fDummy,iIndex] = min(afDist);  %#ok
      iSelectedMouse = aiLostTrackers(iIndex);
      aiUseableBlobs = [aiUseableBlobs, iNewBlob];
      [afMu, a2fCov] = fnFitGaussian([aiX,aiY]);
      strctNewEllipse = fnCov2EllipseArrayStrct(afMu,a2fCov);
      astrctPredictedEllipses(iSelectedMouse) = strctNewEllipse;
      abLostMice(iSelectedMouse) = 0;
      fprintf('* I think I found the lost tracker %d \n',iSelectedMouse);
      fnLog(['fnSolveAssignmentProblem: Lost tracker ' num2str(iSelectedMouse) ' maybe found']);
      aiUseableTrackers = [aiUseableTrackers; iSelectedMouse];
      bRecoveredFromBadTracking = true;
   elseif ~isempty(aiIndices) && isempty(aiLostTrackers)
      % This might be the case where two ellipses were incorrectly placed on a
      % single mouse...
      % Test if there has been a consistent intersection in the
      % past.....and attempt to recover....

      iHistoryLength = length(astrctTrackersHistory(1).m_afX);
      iCroppedHistory = min(20,iHistoryLength);
      a3bIntersect = zeros(iNumMice,iNumMice,iCroppedHistory)>0;
      for iIter=1:iCroppedHistory
         [a3bIntersect(:,:,iIter)] = fnEllipseIntersectionMatrix(astrctTrackersHistory, iHistoryLength-iIter+1) ;
      end
      [aiI,aiJ]=find(triu(mean(double(a3bIntersect),3)) > 0.9);
      if length(aiI) == 1 && length(aiJ) == 1
         %
         fprintf('* Two ellipses were wrongly assigned to the same blog. Attempting to recover OR!!! massive bedding shift \n');
         fnLog('Two ellipses were wrongly assigned to the same blob. Attempting to recover');
         % There was something fishy....
         % First thing first, try to recover (!)
         % randomly assign one of the intersecting ellipses to the new
         % blob....
         %

         iNewBlob = aiUnusableBlobs(aiIndices(1)); % Take first one ? it's all heuristic anyway....
         % Find which trackers might have merged ? look in history and take
         % the pair that intersects the most ?

         [aiY,aiX]=find(a2iLForeground==iNewBlob);
         [afMu, a2fCov] = fnFitGaussian([aiX,aiY]);
         astrctPredictedEllipses(aiI) = fnCov2EllipseArrayStrct(afMu,a2fCov);
         bRecoveredFromBadTracking = true;
         aiUseableBlobs = [aiUseableBlobs,iNewBlob];
         %
         % Fix things in the past. At least one frame, because otherwise
         % the prediction will be completely screwed up in the next
         % frame

         astrctTrackersJob(aiI).m_afX(iOutputIndex-1) = astrctPredictedEllipses(aiI).m_fX;
         astrctTrackersJob(aiI).m_afY(iOutputIndex-1) = astrctPredictedEllipses(aiI).m_fY;
         astrctTrackersJob(aiI).m_afA(iOutputIndex-1) = astrctPredictedEllipses(aiI).m_fA;
         astrctTrackersJob(aiI).m_afB(iOutputIndex-1) = astrctPredictedEllipses(aiI).m_fB;
         astrctTrackersJob(aiI).m_afTheta(iOutputIndex-1) = astrctPredictedEllipses(aiI).m_fTheta;

      end
   end;

end;   % if ~isempty(aiUnusableBlobs)

% At this point, each tracker should be assigned to a blob, unless it has
% been declared lost.  (I think.  ALT, 2012-03-30)

% Do the mixture-of-gaussians fitting of trackers to blobs, where one blob
% may be fit to several trackers.  (I think.  ALT, 2012-03-30)
a2fPixelList = cat(1,astrctProps(aiUseableBlobs).PixelList);
[astrctOptEllipses, dummy, aiUseableOptTrackers, ...
 dummy,dummy,dummy,dummy,dummy, ...
 afImageCorr] = ...
   fnSolveUsingConstrainedEM(astrctPredictedEllipses(aiUseableTrackers),...
                             a2fPixelList, ...
                             strctAdditionalInfo, ...
                             a2iFrame, ...
                             g_strctGlobalParam.m_strctTracking.m_fNumExpectationMaximizationInitializations, ...
                             false);  %#ok

% a2fOptEllipses may contain fewer than iNumMice ellipses, since fitting
% is not done on lost trackers.  Make an tracker array with exactly
% iNumMice trackers, and all-nan ellipses for lost trackers.                          
astrctNewEllipses = fnEllipsesNan(1,iNumMice); % OA - 121410
astrctNewEllipses(aiUseableTrackers(aiUseableOptTrackers)) = astrctOptEllipses(aiUseableOptTrackers);

% Match up the ellipses for this frame with the ones from the previous
% frames.
aiAssignment = fnMatchJobToPrevFrame(astrctPredictedEllipses, astrctNewEllipses);
astrctNewEllipses(aiAssignment(1,:)) = astrctNewEllipses(aiAssignment(2,:));

% Check for new intersections, which are occasionally problematic.
% Why does this use the predicted ellipses?  Why not the ellipses from the
% last frame?
[astrctNewEllipses,abLostMice]= ...
   fnFixNewIntersections(astrctNewEllipses, ...
                         abLostMice, ...
                         astrctPredictedEllipses, ...
                         bRecoveredFromBadTracking, ...
                         astrctTrackersHistory, ...
                         a2iFrame, ...
                         strctAdditionalInfo.strctAppearance);

% Produce figure(s) for debugging, if called for.
if g_bDebugMode 
    figure(6);
    clf;
    tightsubplot(1,3,1);
    imshow(a2iFrame,[]);hold on;
    fnDrawTrackers(astrctPredictedEllipses);
    title('predicted');
    tightsubplot(1,3,2);
    imshow(a2iFrame,[]);hold on;
    fnDrawTrackers(astrctOptEllipses);
    tightsubplot(1,3,3);
    imshow(a2iFrame,[]);hold on;
    fnDrawTrackers(astrctNewEllipses);
end;

return;
