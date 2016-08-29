function astrctChaseIntervals = fnDetectFollowing(astrctTrackers, iMouseA, iMouseB)
% Detect chase/following behavior for two mice
%
% B Following is A occures when:
% 1. A is moving fast enough (> fVelThreshold)
% 2. B is moving fast enough (> fVelThreshold)
% 3. B is behind A (fSouthWedgeAngleThreshold, determines the angular
% position relative to mouse A. 70 means mouse B is between south east and
% south west
% 4. B is oriented towards A (angular difference is less than
% fOrientationAndPositionAngleThreshold)

% Parameters:
fVelThreshold = 10; % Pix/frame
fSouthWedgeAngleThreshold = 70; % i.e. between -70 and 70

fDistanceThresholdLow = 150; % Pix
fDistanceThresholdHigh = 300; % Pix
fOrientationAndPositionAngleThreshold = 30; % Deg
iMergeIntervalDistance = 20;
iSmallIntervalDiscard = 10;

% 3. B is behind A 
% 4. B is oriented towards A
%
% Each condition requires some threshold
%

strctTrackerBaligned = fnAlignTrajectory(astrctTrackers(iMouseA), astrctTrackers(iMouseB));

afVelA = sqrt( [diff(astrctTrackers(iMouseA).m_afX).^2,0] + [diff(astrctTrackers(iMouseA).m_afY).^2,0]);
afVelB = sqrt( [diff(astrctTrackers(iMouseB).m_afX).^2,0] + [diff(astrctTrackers(iMouseB).m_afY).^2,0]);

afDistAB = sqrt( (astrctTrackers(iMouseA).m_afX-astrctTrackers(iMouseB).m_afX).^2+...
                 (astrctTrackers(iMouseA).m_afY-astrctTrackers(iMouseB).m_afY).^2);

afPositionMouseB_fWedgeAngleDeg = atan2(strctTrackerBaligned.m_afY,strctTrackerBaligned.m_afX)/pi*180;

             
afDistB = sqrt(strctTrackerBaligned.m_afX.^2 + strctTrackerBaligned.m_afY.^2);
             

afPosDirX = strctTrackerBaligned.m_afX ./ afDistB;
afPosDirY = strctTrackerBaligned.m_afY ./ afDistB;

afHeadDirectionX = -cos(strctTrackerBaligned.m_afTheta);
afHeadDirectionY = sin(strctTrackerBaligned.m_afTheta);

afAngleOrientationPosition = acos(afPosDirX.*afHeadDirectionX+afPosDirY.*afHeadDirectionY)/pi*180 ;
             
[Dummy, abSmallDistance] = fnHysteresisThreshold(-afDistAB, -fDistanceThresholdHigh, -fDistanceThresholdLow, 10);

% a2fValues(1,:) = afVelA;
% a2fValues(2,:) = afVelB;
% a2fValues(3,:) = afPositionMouseB_fWedgeAngleDeg ;
% a2fValues(4,:) = afAngleOrientationPosition;
% a2fValues(5,:) = afDistAB;
% 
% a2bConditions(1,:) = afVelA > fVelThreshold ;
% a2bConditions(2,:) = afVelB > fVelThreshold ;
% a2bConditions(3,:) = afPositionMouseB_fWedgeAngleDeg > -(90+fSouthWedgeAngleThreshold) & afPositionMouseB_fWedgeAngleDeg < -(90-fSouthWedgeAngleThreshold);
% a2bConditions(4,:) = afAngleOrientationPosition < fOrientationAndPositionAngleThreshold;
% a2bConditions(5,:) = abSmallDistance; %afDistAB < fDistanceThreshold;

% abChaseEvent = all(a2bConditions,1);
abChaseEvent = afVelA > fVelThreshold & afVelB > fVelThreshold & ...
               afPositionMouseB_fWedgeAngleDeg > -(90+fSouthWedgeAngleThreshold) & afPositionMouseB_fWedgeAngleDeg < -(90-fSouthWedgeAngleThreshold) & ...
               afAngleOrientationPosition < fOrientationAndPositionAngleThreshold & ...
               abSmallDistance;

astrctRAWDetection = fnGetIntervals(abChaseEvent);
% Merge events that are within 20, but then discard small ones that are
% less than 10
astrctChaseIntervals = fnDiscardSmallIntervals(fnMergeIntervals(astrctRAWDetection,iMergeIntervalDistance),iSmallIntervalDiscard);

return;
