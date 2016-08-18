 %chase detector
 
 
 strctTemp = load('D:\Data\Janelia Farm\Movies\white mice painted black\Results\Tracks\TestC.mat');
iNumFrames = length( strctTemp.astrctTrackers(1).m_afX);

[acRapidTurnsCCW,acRapidTurnsCW]=fnDetectTurns(strctTemp.astrctTrackers);

acIntervals = [acRapidTurnsCCW,acRapidTurnsCW];
iNumBehaviors = length(acIntervals);
aiBins = 0:500:iNumFrames;
iNumBins = length(aiBins);
a2fEthogram = zeros(iNumBehaviors, iNumBins);
for k=1:iNumBehaviors
    abVector =fnIntervalsToBinary(acIntervals{k}, iNumFrames);
    a2fEthogram(k,:) = histc(find(abVector),aiBins);
end

% Chase
% Approach
% Sniff (head/rear)
% Sleep
% Run
% Walk
% 

figure(11);
clf;
imagesc(a2fEthogram);

    ,{'A CW','B CW','A CCW','B CCW'}



fnPlotIntervals();
%fnIntervalsToBinary(astrctIntervalsRapidTurnsCCW, iNumFrames);
%%
strctMov = fnReadVideoInfo( 'D:\Data\Janelia Farm\Movies\white mice painted black\TestC.seq');
aiMice=1;
iEvent = 2;
strctEvent = acRapidTurnsCCW{1}(iEvent);
aiFrames = strctEvent.m_iStart:strctEvent.m_iEnd;
fnPlayScene2(strctMov, 1:2,aiFrames, strctTemp.astrctTrackers,1)

% Frame 1292
%%
% Represent mouse B in the coordinate system of mouse A.


iMouseA = 2;
iMouseB = 1;
strctTrackerBaligned = fnAlignTrajectory(strctTemp.astrctTrackers(iMouseA), strctTemp.astrctTrackers(iMouseB));


% B chases A
% 1. A is moving
% 2. B is moving
% 3. B is behind A 
% 4. B is oriented towards A
%
% Each condition requires some threshold
%
afVelA = sqrt( [diff(strctTemp.astrctTrackers(iMouseA).m_afX).^2,0] + [diff(strctTemp.astrctTrackers(iMouseA).m_afY).^2,0]);
afVelB = sqrt( [diff(strctTemp.astrctTrackers(iMouseB).m_afX).^2,0] + [diff(strctTemp.astrctTrackers(iMouseB).m_afY).^2,0]);

afDistAB = sqrt( (strctTemp.astrctTrackers(iMouseA).m_afX-strctTemp.astrctTrackers(iMouseB).m_afX).^2+...
                 (strctTemp.astrctTrackers(iMouseA).m_afY-strctTemp.astrctTrackers(iMouseB).m_afY).^2);

afPositionMouseB_fWedgeAngleDeg = atan2(strctTrackerBaligned.m_afY,strctTrackerBaligned.m_afX)/pi*180;

             
afDistB = sqrt(strctTrackerBaligned.m_afX.^2 + strctTrackerBaligned.m_afY.^2);
             

afPosDirX = strctTrackerBaligned.m_afX ./ afDistB;
afPosDirY = strctTrackerBaligned.m_afY ./ afDistB;

afHeadDirectionX = -cos(strctTrackerBaligned.m_afTheta);
afHeadDirectionY = sin(strctTrackerBaligned.m_afTheta);

afAngleOrientationPosition = acos(afPosDirX.*afHeadDirectionX+afPosDirY.*afHeadDirectionY)/pi*180 ;
             
fVelThreshold = 10; % Pix/frame
fDistanceThreshold = 200; % Pix
fSouthWedgeAngleThreshold = 70; % i.e. between -70 and 70
fOrientationAndPositionAngleThreshold = 30; % Deg

a2fValues(1,:) = afVelA;
a2fValues(2,:) = afVelB;
a2fValues(3,:) = afPositionMouseB_fWedgeAngleDeg ;
a2fValues(4,:) = afAngleOrientationPosition;
a2fValues(5,:) = afDistAB;

a2bConditions(1,:) = afVelA > fVelThreshold ;
a2bConditions(2,:) = afVelB > fVelThreshold ;
a2bConditions(3,:) = afPositionMouseB_fWedgeAngleDeg > -(90+fSouthWedgeAngleThreshold) & afPositionMouseB_fWedgeAngleDeg < -(90-fSouthWedgeAngleThreshold);
a2bConditions(4,:) = afAngleOrientationPosition < fOrientationAndPositionAngleThreshold;
a2bConditions(5,:) = abBinary; %afDistAB < fDistanceThreshold;

[Dummy, abBinary] = fnHysteresisThreshold(-afDistAB, -300, -150, 10);
abChaseEvent = all(a2bConditions,1);

astrctRAWDetection = fnGetIntervals(abChaseEvent);
astrctChaseIntervals = fnDiscardSmallIntervals(fnMergeIntervals(astrctRAWDetection,20),10);

[fDummy, aiSortInd] = sort(cat(1,astrctChaseIntervals.m_iLength),'descend');
%%
iEvent = aiSortInd(end-5);
aiFrames = astrctChaseIntervals(iEvent).m_iStart:astrctChaseIntervals(iEvent).m_iEnd;
fnPlayScene2(strctMov, 1:2, aiFrames, strctTemp.astrctTrackers,0.1,20)

%%



%%
iEvent = aiSortInd(200);
aiFrames = astrctChaseIntervals(iEvent).m_iStart:astrctChaseIntervals(iEvent).m_iEnd;
fnPlayScene2Matrix([], [iMouseA, iMouseB],aiFrames, X,Y,A,B,Theta,0);

%%
figure(2);
clf;hold on;


   
iMouseA = 2;
iMouseB = 1;
strctTrackerBaligned = fnAlignTrajectory(strctTemp.astrctTrackers(iMouseA), strctTemp.astrctTrackers(iMouseB));

iFrame = 3915;
clf;    hold on;

fnDrawTrackers8( 0,0,...
              strctTemp.astrctTrackers(iMouseA).m_afA(iFrame),...
              strctTemp.astrctTrackers(iMouseA).m_afB(iFrame),...
              -pi/2, 'g');

fnDrawTrackers8( strctTrackerBaligned.m_afX(iFrame),strctTrackerBaligned.m_afY(iFrame),...
              strctTrackerBaligned.m_afA(iFrame),...
              strctTrackerBaligned.m_afB(iFrame),...
              strctTrackerBaligned.m_afTheta(iFrame), 'r');
axis equal          
%%          
fCenterX = (strctTemp.astrctTrackers(iMouseB).m_afX(iFrame)-strctTemp.astrctTrackers(iMouseA).m_afX(iFrame));
fCenterY = (strctTemp.astrctTrackers(iMouseB).m_afY(iFrame)-strctTemp.astrctTrackers(iMouseA).m_afY(iFrame));
fTheta = (strctTemp.astrctTrackers(iMouseB).m_afTheta(iFrame)-strctTemp.astrctTrackers(iMouseA).m_afTheta(iFrame));

% Rotate Center of B by negative rotation of A.
a2fRotationA = [cos(strctTemp.astrctTrackers(iMouseA).m_afTheta(iFrame)-pi/2) sin(strctTemp.astrctTrackers(iMouseA).m_afTheta(iFrame)-pi/2);
                -sin(strctTemp.astrctTrackers(iMouseA).m_afTheta(iFrame)-pi/2) cos(strctTemp.astrctTrackers(iMouseA).m_afTheta(iFrame)-pi/2)];
pt2fPosB = a2fRotationA' * [fCenterX;fCenterY];

fnDrawTrackers8(pt2fPosB(1), -pt2fPosB(2),...
               strctTemp.astrctTrackers(iMouseB).m_afA(iFrame),...
               strctTemp.astrctTrackers(iMouseB).m_afB(iFrame),...
               -pi/2 + -fTheta, 'r');
          
axis equal          

           
[fMin,iIndex]=min( acos(afPosDirX.*afHeadDirectionX+afPosDirY.*afHeadDirectionY)/pi*180 );
