function strctTrackerBaligned = fnAlignTrajectory(strctTrackerA, strctTrackerB)
% Represent trajectoroy of mouse B in the coordinate system of mouse A.
% Further rotate the frame such that A always faces "noth" (tail to the
% south. 
% Use output to detect events relative to mouse A.

afCenterX = strctTrackerB.m_afX-strctTrackerA.m_afX;
afCenterY = strctTrackerB.m_afY-strctTrackerA.m_afY;

afCos = cos(strctTrackerA.m_afTheta-pi/2);
afSin = sin(strctTrackerA.m_afTheta-pi/2);

strctTrackerBaligned.m_afX = afCos .* afCenterX - afSin .* afCenterY;
strctTrackerBaligned.m_afY = -(afSin .* afCenterX + afCos .* afCenterY); % ij view

strctTrackerBaligned.m_afTheta = -pi/2 - (strctTrackerB.m_afTheta-strctTrackerA.m_afTheta);

strctTrackerBaligned.m_afA = strctTrackerB.m_afA;
strctTrackerBaligned.m_afB = strctTrackerB.m_afB;
return;

