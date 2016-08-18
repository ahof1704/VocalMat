load('D:\Data\Janelia Farm\Results\10.04.19.390\SequenceViterbi_26-Aug-2009.mat');
strMovie = 'M:\Data\Movies\Experiment1\10.04.19.390.seq';
strctMovInfo = fnReadVideoInfo(strMovie);


a2fX = cat(1,astrctTrackers.m_afX);
a2fY = cat(1,astrctTrackers.m_afY);
a2fA = cat(1,astrctTrackers.m_afA);
a2fB = cat(1,astrctTrackers.m_afB);
a2fTheta = cat(1,astrctTrackers.m_afTheta);

%% Detect approaching

% strctApproachParams.m_fVelocityStationaryThresholdPix = 5;
% strctApproachParams.m_iMaxLength = 50;
% strctApproachParams.m_iMergeIntervals = 10;
% 
% % B approach A
% iMouseA = 2;
% iMouseB = 3;
% abMouseAStationary = [0,sqrt((a2fX(iMouseA,2:end)-a2fX(iMouseA,1:end-1)).^2 + (a2fY(iMouseA,2:end)-a2fY(iMouseA,1:end-1)).^2) < strctApproachParams.m_fVelocityStationaryThresholdPix];
% abMouseBStationary = [0,sqrt((a2fX(iMouseB,2:end)-a2fX(iMouseB,1:end-1)).^2 + (a2fY(iMouseB,2:end)-a2fY(iMouseB,1:end-1)).^2) < strctApproachParams.m_fVelocityStationaryThresholdPix];
% aiStatSumA = cumsum(abMouseAStationary);
% aiStatSumB = cumsum(abMouseBStationary);
% afDistAB = sqrt((a2fX(iMouseA,:)-a2fX(iMouseB,:)).^2+(a2fY(iMouseA,:)-a2fY(iMouseB,:)).^2);
% 
% abFarAway = afDistAB > 200;
% abNearBy = afDistAB <= 20;
% astrctFarAway = fnGetIntervals(abFarAway);
% astrctNearby = fnGetIntervals(abNearBy);
% 
% for i=1:length(astrctFarAway)
%     for j=1:length(astrctNearby)
%         fEndToStart = astrctNearby(j).m_iStart - astrctFarAway(i).m_iEnd;
%         if fEndToStart > 0  && fEndToStart < strctApproachParams.m_iMaxLength
%             aiInterval = [astrctFarAway(i).m_iEnd:astrctNearby(j).m_iStart];
%             fPercMoving = (aiStatSumA(astrctNearby(j).m_iStart) - aiStatSumA(astrctFarAway(i).m_iEnd) ) / length(aiInterval) * 100;
%             if fPercMoving < 20
%                 [aiInterval(1),aiInterval(end)]
%             end
%         end;
%     end;
% end;
% 

%%

% Thresholds
strctParams.m_fVelocityThresholdPix = 10;
strctParams.m_fSameOrientationAngleThresDeg = 90;
strctParams.m_fDistanceThresholdPix = 250;
strctParams.m_iMergeIntervalsFrames = 30;


iMouseA = 1;
iMouseB = 2;
abDetected = fndllDetectBehavior('Following',a2fX,a2fY,a2fA,a2fB,a2fTheta, iMouseB,iMouseA, strctParams);
astrctIntervalsFollowing = fnMergeIntervals(fnGetIntervals(abDetected),strctParams.m_iMergeIntervalsFrames);
aiLength = cat(1,astrctIntervalsFollowing.m_iLength);
[aiSortedLength, aiSortIndex] = sort(aiLength,'descend');
astrctIntervalsFollowing=astrctIntervalsFollowing(aiSortIndex);



iMouseA = 3;
iMouseB = 1;
abDetected = fndllDetectBehavior('Following',a2fX,a2fY,a2fA,a2fB,a2fTheta, iMouseB,iMouseA, strctParams);
astrctIntervalsFollowing2 = fnMergeIntervals(fnGetIntervals(abDetected),strctParams.m_iMergeIntervalsFrames);
aiLength = cat(1,astrctIntervalsFollowing2.m_iLength);
[aiSortedLength, aiSortIndex] = sort(aiLength,'descend');
astrctIntervalsFollowing2=astrctIntervalsFollowing2(aiSortIndex);


iMouseA = 1;
iMouseB = 4;
strctSniffParam.m_fVelocityThresholdPix = 5;
strctSniffParam.m_fHeadToButtDistPix = 20;
strctSniffParam.m_fBodiesAwayMult = 2;   
strctSniffParam.m_iMergeIntervalsFrames = 30;

abDetected = fndllDetectBehavior('SniffButt',a2fX,a2fY,a2fA,a2fB,a2fTheta, iMouseB,iMouseA, strctSniffParam);
astrctIntervalsSniffButt1 = fnMergeIntervals(fnGetIntervals(abDetected),strctSniffParam.m_iMergeIntervalsFrames);
aiLength = cat(1,astrctIntervalsSniffButt1.m_iLength);
[aiSortedLength, aiSortIndex] = sort(aiLength,'descend');
astrctIntervalsSniffButt1=astrctIntervalsSniffButt1(aiSortIndex);


iMouseA = 1;
iMouseB = 4;
strctKissParam.m_fVelocityThresholdPix = 5;
strctKissParam.m_fHeadToHeadDistPix = 15;
strctKissParam.m_fBodiesAwayMult = 2;   
strctKissParam.m_iMergeIntervalsFrames = 30;


abDetected = fndllDetectBehavior('Kiss',a2fX,a2fY,a2fA,a2fB,a2fTheta, iMouseB,iMouseA, strctKissParam);
strctIntervalsKiss1 = fnMergeIntervals(fnGetIntervals(abDetected),strctKissParam.m_iMergeIntervalsFrames);
aiLength = cat(1,strctIntervalsKiss1.m_iLength);
[aiSortedLength, aiSortIndex] = sort(aiLength,'descend');
strctIntervalsKiss1=strctIntervalsKiss1(aiSortIndex);

Mov = avifile('Demo.avi','fps',30,'compression','xvid');


MovieOutputSize = 2*[384 512];

f=figure(10);
clf;
set(f,'Position',[  254   50   MovieOutputSize(2)   MovieOutputSize(1)],'color',[0 0 0]);

acText = {0.3, 0.5, 40, 'Smart-Mouse';
          0.27  0.37, 20, 'The first multiple mouse tracker,';
          0.22  0.27, 20, 'that can keep track of identities for days...';
           0.45  0.2, 10,'Dec 2009';          
          };
Mov = fnMovieText(acText, 3, 4,3,Mov,MovieOutputSize);
aiInterval = 102000:5:103000;
Mov = fnMovieFadeInOut(strctMovInfo, astrctTrackers, aiInterval,2, 2,Mov,MovieOutputSize);

clf;

acText = {0.15, 0.5, 40, 'Several Hours Later...';
          0.25 0.37 20, 'Identities are still correct'};
Mov = fnMovieText(acText, 3, 3,3,Mov,MovieOutputSize);

aiInterval = 1158777:5:1160000;
Mov = fnMovieFadeInOut(strctMovInfo, astrctTrackers, aiInterval,2, 2,Mov,MovieOutputSize);

clf;

acText = {0.1, 0.5, 25, 'Even during complex interactions'};
Mov = fnMovieText(acText, 3, 3,3,Mov,MovieOutputSize);

aiInterval = round(397747:0.3:397792);
Mov = fnMovieFadeInOut(strctMovInfo, astrctTrackers, aiInterval,0.2, 0.2,Mov,MovieOutputSize);

clf;
acText = {0.1, 0.5, 25, 'Behaviors Are Automatically Detected'};
Mov = fnMovieText(acText, 3, 3,3,Mov,MovieOutputSize);

clf;
acText = {0.12, 0.5, 15, 'Following behavior';
          0.19, 0.35, 10, 'Red follows green'};
Mov = fnMovieTextSubPlot(acText, 2,Mov,MovieOutputSize,1,0);
Mov = fnMovieFadeInOutSubplot(strctMovInfo, astrctTrackers, astrctIntervalsFollowing(1:3),0.3, 0.3,Mov,MovieOutputSize,[2:4],0,[]);
Mov = fnMovieTextSubPlot(acText, 1,Mov,MovieOutputSize,1,1);

clf;
acText = {0.12, 0.5, 15, 'Tail Sniffing behavior';
              0.19, 0.35, 10, 'Red sniffs Cyan'};
Mov = fnMovieTextSubPlot(acText, 2,Mov,MovieOutputSize,2,0);
Mov = fnMovieFadeInOutSubplot(strctMovInfo, astrctTrackers, astrctIntervalsSniffButt1(1:3),0.3, 0.3,Mov,MovieOutputSize,[1,3,4],30,[1 1 1]);
Mov = fnMovieTextSubPlot(acText, 1,Mov,MovieOutputSize,2,1);

clf;
acText = {0.12, 0.5, 15, 'Head Sniffing behavior';
                  0.19, 0.35, 10, 'Red sniffs Cyan'};
Mov = fnMovieTextSubPlot(acText, 2,Mov,MovieOutputSize,3,0);
Mov = fnMovieFadeInOutSubplot(strctMovInfo, astrctTrackers, strctIntervalsKiss1([1,2,5]),0.3, 0.3,Mov,MovieOutputSize,[1,2,4],30,[1 1 1]);
Mov = fnMovieTextSubPlot(acText, 1,Mov,MovieOutputSize,3,1);

clf;
acText = {0.1, 0.5, 25, 'Scalable to more than four mice'};
Mov = fnMovieText(acText, 3, 3,3,Mov,MovieOutputSize);

load('D:\Data\Janelia Farm\Results\six_mice_15.41.17.171\SequenceViterbi.mat');
strMovie = 'D:\Data\Janelia Farm\Movies\6Mice\six_mice_15.41.17.171.seq';
strctMovInfo = fnReadVideoInfo(strMovie);

aiInterval = 1:5:2000;
Mov = fnMovieFadeInOut(strctMovInfo, astrctTrackers, aiInterval,2, 2,Mov,MovieOutputSize);

clf;
acText = {0.1, 0.5, 20, 'Soon available for download at';
          0.3, 0.3, 25, 'http://BrainStory.info/'};
Mov = fnMovieText(acText, 3, 3,3,Mov,MovieOutputSize);


Mov = close(Mov);
 