a2fX = cat(1,astrctTrackers.m_afX);
a2fY = cat(1,astrctTrackers.m_afY);
a2fA = cat(1,astrctTrackers.m_afA);
a2fB = cat(1,astrctTrackers.m_afB);
a2fTheta = cat(1,astrctTrackers.m_afTheta);
load('Debug');

figure(1);
clf;
iMouseA = 2;
iMouseB = 3;
iFrame = 96;

fnPlotEllipse(a2fX(iMouseA,iFrame),a2fY(iMouseA,iFrame),...
              a2fA(iMouseA,iFrame),a2fB(iMouseA,iFrame),...
              a2fTheta(iMouseA,iFrame),'g',2);
hold on;
fnPlotEllipse(a2fX(iMouseB,iFrame),a2fY(iMouseB,iFrame),...
              a2fA(iMouseB,iFrame),a2fB(iMouseB,iFrame),...
              a2fTheta(iMouseB,iFrame),'b',2);
axis ij

fnAngleToVec = @(x)[cos(x),-sin(x)];

Va = fnAngleToVec(a2fTheta(iMouseA,iFrame));

pt2iMouseATail = [a2fX(iMouseA,iFrame),a2fY(iMouseA,iFrame)] +  Va * -a2fA(iMouseA,iFrame);
pt2iMouseAHead = [a2fX(iMouseA,iFrame),a2fY(iMouseA,iFrame)] +  Va * a2fA(iMouseA,iFrame);

Vb = fnAngleToVec(a2fTheta(iMouseB,iFrame));

pt2iMouseBTail = [a2fX(iMouseB,iFrame),a2fY(iMouseB,iFrame)] +  Vb * -a2fA(iMouseB,iFrame);
pt2iMouseBHead = [a2fX(iMouseB,iFrame),a2fY(iMouseB,iFrame)] +  Vb * a2fA(iMouseB,iFrame);

fHeadBToButtA_Dist = norm(pt2iMouseATail-pt2iMouseBHead);

bHeadCloseToButt = fHeadBToButtA_Dist < 20;

fDist = sqrt((a2fX(iMouseA,iFrame)-a2fX(iMouseB,iFrame))^2+(a2fY(iMouseA,iFrame)-a2fY(iMouseB,iFrame))^2);

iBMultiplier = 2;
bFarAway = fDist > iBMultiplier*a2fB(iMouseA,iFrame)+a2fB(iMouseB,iFrame);

hold on;
plot(pt2iMouseAHead(1),pt2iMouseAHead(2),'r*');
plot(pt2iMouseATail(1),pt2iMouseATail(2),'ro');

plot(pt2iMouseBHead(1),pt2iMouseBHead(2),'c*');
plot(pt2iMouseBTail(1),pt2iMouseBTail(2),'co');





% Thresholds
strctParams.m_fVelocityThresholdPix = 10;
strctParams.m_fSameOrientationAngleThresDeg = 90;
strctParams.m_fDistanceThresholdPix = 250;
strctParams.m_iMergeIntervalsFrames = 30;

iMouseA = 1;
iMouseB = 4;
abDetected = fndllDetectBehavior('Following',a2fX,a2fY,a2fA,a2fB,a2fTheta, iMouseB,iMouseA, strctParams);
astrctIntervals = fnMergeIntervals(fnGetIntervals(abDetected),strctParams.m_iMergeIntervalsFrames);


% Thresholds
strctParams.m_fVelocityThresholdPix = 10;
strctParams.m_fHeadToButtDistPix = 20;
strctParams.m_fBodiesAwayMult = 2;
strctParams.m_iMergeIntervalsFrames = 30;

iMouseA = 2;
iMouseB = 3;
abDetected = fndllDetectBehavior('SniffButt',a2fX,a2fY,a2fA,a2fB,a2fTheta, iMouseB,iMouseA, strctParams);
astrctIntervals = fnMergeIntervals(fnGetIntervals(abDetected),strctParams.m_iMergeIntervalsFrames);

iMouseA = 2;
iMouseB = 3;
abDetected = fndllDetectBehavior('Kiss',a2fX,a2fY,a2fA,a2fB,a2fTheta, iMouseB,iMouseA, strctParams);
astrctIntervals = fnMergeIntervals(fnGetIntervals(abDetected),strctParams.m_iMergeIntervalsFrames);


