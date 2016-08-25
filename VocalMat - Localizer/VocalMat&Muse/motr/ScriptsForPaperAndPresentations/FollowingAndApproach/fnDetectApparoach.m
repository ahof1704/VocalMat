function astrctBApproachA = fnDetectApparoach(X,Y,A,B,Theta,iMouseA, iMouseB)
% Detects the events of B approaching A, where A is stationary.
%

W = 10; % Window for local max operation

% i.e., the distance needs to decrease for 100 pixels during 50 frames
% before A is stationary
fDistanceThreshold = -100; 
iTimeThreshold = 50; 
fPositionalStationarityThreshold = 10;
fRotationalStationarityThreshold = 20;
% thresholds to detect closeness
fCloseLow = 30; % pixels
fCloseHigh = 50; % pixels
fCloseLength = 30; % frames

afRunningPos = fnRunningMAX(X(:,iMouseA),Y(:,iMouseA),W);
afRunningAngle = fnRunningAngle(Theta(:,iMouseA),W);
%abAStationary = afRunningAngle/pi*180 < 8 & afRunningPos < 8;
[Xb, Yb, Ab, Bb, Tb] = fnAlignTrajectoryMatrix(X,Y,A,B,Theta, iMouseA, iMouseB);
afBDistanceToA = sqrt(Xb.^2 + Yb.^2); %figure(10);hist(afBDistanceToA,5000)
afDiffBDistToA = medfilt1([0;diff(afBDistanceToA)],3); % Remove outliers

% Detect approach B->A followed by staying close to each other
astrctIntervalsCloseToA = fnHysteresisThresholdLow(afBDistanceToA, fCloseLow, fCloseHigh, fCloseLength);
iNumInter = length(astrctIntervalsCloseToA);
afAvgDistanceChangeBefore = zeros(1,iNumInter);
afAvgATrans = zeros(1,iNumInter);
afAvgARot = zeros(1,iNumInter);

for k=1:length(astrctIntervalsCloseToA)
    aiInd = max(1,astrctIntervalsCloseToA(k).m_iStart-iTimeThreshold:astrctIntervalsCloseToA(k).m_iStart);
    afAvgDistanceChangeBefore(k)=sum(afDiffBDistToA(aiInd));
    afAvgATrans(k) = mean(afRunningPos(aiInd));% + );
    afAvgARot(k) = mean(afRunningAngle(aiInd)/pi*180);
end;
astrctBApproachA = astrctIntervalsCloseToA(afAvgDistanceChangeBefore<fDistanceThreshold & afAvgATrans < fPositionalStationarityThreshold & afAvgARot < fRotationalStationarityThreshold);

return;
