load('D:\Data\Janelia Farm\ResultsFromNewTrunk\cage18_matrix.mat');

W = 10;
iMouseA = 4;
iMouseB = 3;
afRunningPos = fnRunningMAX(X(:,iMouseA),Y(:,iMouseA),W);
afRunningAngle = fnRunningAngle(Theta(:,iMouseA),W);
abAStationary = afRunningAngle/pi*180 < 8 & afRunningPos < 8;
[Xb, Yb, Ab, Bb, Tb] = fnAlignTrajectoryMatrix(X,Y,A,B,Theta, iMouseA, iMouseB);
afBDistanceToA = sqrt(Xb.^2 + Yb.^2); %figure(10);hist(afBDistanceToA,5000)
afDiffBDistToA = medfilt1([0;diff(afBDistanceToA)],3);

% Detect approach B->A followed by staying close to each other
astrctIntervalsCloseToA = fnHysteresisThresholdLow(afBDistanceToA, 30, 50, 30);
iNumInter = length(astrctIntervalsCloseToA);
afAvgDistanceChangeBefore = zeros(1,iNumInter);
afAvgATrans = zeros(1,iNumInter);
afAvgARot = zeros(1,iNumInter);

for k=1:length(astrctIntervalsCloseToA)
    aiInd = max(1,astrctIntervalsCloseToA(k).m_iStart-50:astrctIntervalsCloseToA(k).m_iStart);
    afAvgDistanceChangeBefore(k)=sum(afDiffBDistToA(aiInd));
    afAvgATrans(k) = mean(afRunningPos(aiInd));% + );
    afAvgARot(k) = mean(afRunningAngle(aiInd)/pi*180);
end;
astrctBApproachA = astrctIntervalsCloseToA(afAvgDistanceChangeBefore<-100 & afAvgATrans < 10 & afAvgARot < 20);
astrctIntervals = astrctBApproachA;
[afSorted,aiInd] = sort(cat(1,astrctIntervals.m_iLength),'descend');

for iSelected = 1:length(astrctBApproachA)
    fprintf('%d \n',aiInd(iSelected ));
aiFrames= astrctIntervals(aiInd(iSelected)).m_iStart-50:astrctIntervals(aiInd(iSelected)).m_iStart;
fnPlayScene2Matrix([], [ iMouseA iMouseB],aiFrames, X,Y,A,B,Theta,0,0,[]);
end

% Now, find to 


figure(3);
clf;
plot(afRunningAngle(1:300)/pi*180);


% 

aiEvents = find(afRad(1:300)<=8);
aiFrames = 1:300;
fnPlayScene2Matrix([], [iMouseA, iMouseB],aiFrames, X,Y,A,B,Theta,0.2,0,aiEvents);

figure;
plot(afRad(1:10000));

X(:,iMousb

for iMouseA=1:4
    
    
    for iMouseB=1:4
        if iMouseA==iMouseB
            continue;
        end;
        [Xb, Yb, Ab, Bb, Tb] = fnAlignTrajectoryMatrix(X,Y,A,B,Theta, iMouseA, iMouseB);
         % Represent trajectoroy of mouse B in the coordinate system of mouse A.

    end
end

