function astrctChaseIntervals = fnDetectFollowingMatrix(X,Y,A,B,Theta, iMouseA, iMouseB)
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


[Xb, Yb, Ab, Bb, Tb] = fnAlignTrajectoryMatrix(X,Y,A,B,Theta, iMouseA, iMouseB);

afVelA = sqrt( [diff(X(:,iMouseA)).^2;0] + [diff(Y(:,iMouseA)).^2;0]);
afVelB = sqrt( [diff(X(:,iMouseB)).^2;0] + [diff(Y(:,iMouseB)).^2;0]);

afDistAB = sqrt( (X(:,iMouseA)-X(:,iMouseB)).^2+...
                 (Y(:,iMouseA)-Y(:,iMouseB)).^2);

afPositionMouseB_fWedgeAngleDeg = atan2(Yb,Xb)/pi*180;
afDistB = sqrt(Xb.^2 + Yb.^2);
afPosDirX = Xb ./ afDistB;
afPosDirY = Yb ./ afDistB;

afHeadDirectionX = -cos(Tb);
afHeadDirectionY = sin(Tb);

afAngleOrientationPosition = acos(afPosDirX.*afHeadDirectionX+afPosDirY.*afHeadDirectionY)/pi*180 ;
             
[Dummy, abSmallDistance] = fnHysteresisThreshold(-afDistAB, -fDistanceThresholdHigh, -fDistanceThresholdLow, 10);

abChaseEvent = afVelA > fVelThreshold & afVelB > fVelThreshold & ...
               afPositionMouseB_fWedgeAngleDeg > -(90+fSouthWedgeAngleThreshold) & afPositionMouseB_fWedgeAngleDeg < -(90-fSouthWedgeAngleThreshold) & ...
               afAngleOrientationPosition < fOrientationAndPositionAngleThreshold & ...
               abSmallDistance;

astrctRAWDetection = fnDiscardSmallIntervals(fnGetIntervals(abChaseEvent),1); % Remove spurious events
% Merge events that are within 20, but then discard small ones that are
% less than 10
astrctChaseIntervals = fnDiscardSmallIntervals(fnMergeIntervals(astrctRAWDetection,iMergeIntervalDistance),iSmallIntervalDiscard);

return;
