function [astrctPredictedEllipses,abLostMice, afVelocity] = ...
    fnComputePredTrackerValues(astrctTrackersHistory)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

% Predicts the mouse ellipses in the next frame, given the ellipses in
% astrctTrackersHistory.  astrctTrackersHistory is 1 x iNumMice, with the
% usual tracker structure.  Barring mouse intersections, etc, just uses a
% simple linear extrapolation of position, and some fancier stuff for
% extrapolating the shape of the ellipse.  Note that at this point ellipses
% are just ellipses, not direllipses.  On return, astrctPredictedEllipses
% contains the ellipse predictions for the next frame, for each mouse.
% abLostMice is 1 x iNumMice and is true if a mouse has been "lost".
% afVelocity is 1 x iNumMice and contains the velocity of the center of
% each mouse ellipse, in pels/frame.

% Import globals we'll need.
global g_strctGlobalParam
iNumFramesLost= ...
  g_strctGlobalParam.m_strctTracking.m_fNumMissingFramesToDeclareLostMouse;
fPositionalPredictionGainDamping= ...
  g_strctGlobalParam.m_strctTracking.m_fPositionalPredictionGainDamping;
fMaxPredictMajorAxis= ...
  g_strctGlobalParam.m_strctTracking.m_fMaxPredictMajorAxis;
fMinPredictMajorAxis= ...
  g_strctGlobalParam.m_strctTracking.m_fMinPredictMajorAxis;
fMinPredictMinorAxis= ...
  g_strctGlobalParam.m_strctTracking.m_fMinPredictMinorAxis;
clear g_strctGlobalParam

% Get dimensions.
iNumFramesTracked = length(astrctTrackersHistory(1).m_afX);
iNumMice = length(astrctTrackersHistory);

% Initialize some variables.
abLostMice = false(1,iNumMice);
afVelocity = zeros(1,iNumMice);  % pels/frame

% If a mouse has an all-nan ellipse for the last iNumFramesLost
% frames, declare it lost.  This is stored in abLostMice, 1 x iNumMice.
if iNumFramesTracked > iNumFramesLost
    aiNumNaNs = zeros(1,iNumMice);
    for k=iNumFramesTracked-iNumFramesLost+1:iNumFramesTracked
        for iMouseIter=1:iNumMice
            aiNumNaNs(iMouseIter) = aiNumNaNs(iMouseIter) + ...
                isnan(astrctTrackersHistory(iMouseIter).m_afX(k));
        end;
    end;
    abLostMice = aiNumNaNs == iNumFramesLost;
end;

% Determine which ellipses intersect with some other ellipse in the latest
% frame (abIntersecting, iNumMice x 1).
a2bIntersect = fnEllipseIntersectionMatrix(astrctTrackersHistory, iNumFramesTracked);
abIntersecting = any(a2bIntersect,2);

% Iterate over the mice, making a prediction for each.
astrctPredictedEllipses = ...
    struct('m_fX',cell(1,iNumMice), ...
           'm_fY',cell(1,iNumMice), ...
           'm_fA',cell(1,iNumMice), ...
           'm_fB',cell(1,iNumMice), ...
           'm_fTheta',cell(1,iNumMice));
for iMouseIter=1:iNumMice
    % Get the indices of the ultimate and penultimate frames (usually).
    iIndexPrev1 = max(1,iNumFramesTracked);
    iIndexPrev2 = max(1,iNumFramesTracked-1);
    
    % Check for invalid ellipses in the last two frames, use last known
    % reliable frames if we need to.
    isNaN1 = isnan(astrctTrackersHistory(iMouseIter).m_afX(iIndexPrev1));
    isNaN2 = isnan(astrctTrackersHistory(iMouseIter).m_afX(iIndexPrev2));
    if isNaN1 || isNaN2
        % Take last known reliable tracker
        iLastKnown = find(~isnan(astrctTrackersHistory(iMouseIter).m_afX),1,'last');
        iIndexPrev1 = iLastKnown;
        iIndexPrev2 = iLastKnown;
    end;
    
    % The gain used in the prediction depends on whether this mouse 
    % intersects with anyone else.
    if abIntersecting(iMouseIter)
        fGain = fPositionalPredictionGainDamping;
    else
        fGain = 1;
    end;
    
    % Get the ellipses at the predictor frames.
    strctTracker1=fnGetTrackerAtFrame(astrctTrackersHistory, ...
                                      iMouseIter, ...
                                      iIndexPrev1);
    strctTracker2=fnGetTrackerAtFrame(astrctTrackersHistory, ...
                                      iMouseIter, ...
                                      iIndexPrev2);
                                                              
    % Calculate the predicted x
    fX1=strctTracker1.m_fX;
    fX2=strctTracker2.m_fX;
    fDx=fX1-fX2;
    fX=fX1+fGain*(fX1-fX2);
    
    % Calculate the predicted y
    fY1=strctTracker1.m_fY;
    fY2=strctTracker2.m_fY;
    fDy=fY1-fY2;
    fY=fY1+fGain*(fY1-fY2);
    
    % Calculate the velocity, since we've got the info handy.      
    afVelocity(iMouseIter) = hypot(fDx,fDy);
    
    % Calculate the predicted a
    fA = ...
      min(fMaxPredictMajorAxis,...
          max(fMinPredictMajorAxis, ...
              (strctTracker1.m_fA+strctTracker2.m_fA)/2));

    % Calculate the predicted b        
    fB = ...
      max(fMinPredictMinorAxis, ...
          (strctTracker1.m_fB+strctTracker2.m_fB)/2);

    %    
    % Calculate theta, this is a bit more complicated....
    %
    fTheta1 = strctTracker1.m_fTheta;
    fTheta2 = strctTracker2.m_fTheta;
        
    % Bring thetas to 0..pi
    % Theta is an orientation, not an angle, b/c we're dealing with an
    % ellipse, not a directed ellipse.
    fTheta1=fnNormalizeOrientation0ToPi(fTheta1);
    fTheta2=fnNormalizeOrientation0ToPi(fTheta2);

    % assume A >=B , then fRatio >= 1
    fRatio = fA/fB;
    % If fRatio ~ 1, Gain should be minimal....
    fThetaGain = min(1,max(0,(fRatio-1) ));
    fDiff = fnNormalizeOrientationSymmetric(fTheta1 - fTheta2);
    fTheta = fTheta1 + fThetaGain*fDiff;
    fTheta=fnNormalizeAngle0To2Pi(fTheta);
    
    % Store the predicted ellipse
    astrctPredictedEllipses(iMouseIter) = ...
      struct('m_fX',fX, ...
             'm_fY',fY, ...
             'm_fA',fA, ...
             'm_fB',fB, ...
             'm_fTheta',fTheta);
end



%%
% 
% figure(10);
% clf;
% iMouseIter = 1;
% h1=fnPlotEllipse(...
%     astrctTrackersHistory(iMouseIter).m_afX(end),...
%     astrctTrackersHistory(iMouseIter).m_afY(end),...
%     astrctTrackersHistory(iMouseIter).m_afA(end),...
%     astrctTrackersHistory(iMouseIter).m_afB(end),...
%     astrctTrackersHistory(iMouseIter).m_afTheta(end),[1 0 0],2);
% h1=fnPlotEllipse(...
%     astrctTrackersHistory(iMouseIter).m_afX(end-1),...
%     astrctTrackersHistory(iMouseIter).m_afY(end-1),...
%     astrctTrackersHistory(iMouseIter).m_afA(end-1),...
%     astrctTrackersHistory(iMouseIter).m_afB(end-1),...
%     astrctTrackersHistory(iMouseIter).m_afTheta(end-1),[0.5 0 0],2);
% 
% hold on;
% h1=fnPlotEllipse(...
%     astrctPredictedEllipses(iMouseIter).m_fX(end),...
%     astrctPredictedEllipses(iMouseIter).m_fY(end),...
%     astrctPredictedEllipses(iMouseIter).m_fA(end),...
%     astrctPredictedEllipses(iMouseIter).m_fB(end),...
%     astrctPredictedEllipses(iMouseIter).m_fTheta(end),[0 1 0],2);
% 


% h2=fnPlotEllipse(...
%     astrctTrackersHistory(iMouseIter).m_afX(end-1),...
%     astrctTrackersHistory(iMouseIter).m_afY(end-1),...
%     astrctTrackersHistory(iMouseIter).m_afA(end-1),...
%     astrctTrackersHistory(iMouseIter).m_afB(end-1),...
%     astrctTrackersHistory(iMouseIter).m_afTheta(end-1),[0 1 0],2);
% 
% h3=fnPlotEllipse(...
%     astrctTrackersHistory(iMouseIter).m_afX(end-2),...
%     astrctTrackersHistory(iMouseIter).m_afY(end-2),...
%     astrctTrackersHistory(iMouseIter).m_afA(end-2),...
%     astrctTrackersHistory(iMouseIter).m_afB(end-2),...
%     astrctTrackersHistory(iMouseIter).m_afTheta(end-2),[0 0 1],2);
% for k=3:4
% fnPlotEllipse(...
%     astrctTrackersHistory(iMouseIter).m_afX(end-k),...
%     astrctTrackersHistory(iMouseIter).m_afY(end-k),...
%     astrctTrackersHistory(iMouseIter).m_afA(end-k),...
%     astrctTrackersHistory(iMouseIter).m_afB(end-k),...
%     astrctTrackersHistory(iMouseIter).m_afTheta(end-k),[0 0 0],2);
% end
% 
% legend([h1,h2,h3],{'i-1','i-2','i-3'});
%     
end
