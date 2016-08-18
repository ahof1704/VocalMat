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


Mov = avifile('Demo2.avi','fps',30,'compression','xvid');
    
MovieOutputSize = [384 512];

acText = {0.3, 0.5, 40, 'Smart-Mouse';
          0.37  0.37, 20, 'Tracking Results';
          0.45  0.25, 10, 'Sep 2009';          
          };
Mov = fnMovieText(acText, 3, 4,3,Mov,MovieOutputSize);

aiInterval = 102000:5:103000;
Mov = fnMovieFadeInOut(strctMovInfo, astrctTrackers, aiInterval,2, 2,Mov,MovieOutputSize);

acText = {0.3, 0.5, 40, '7 Hours Later...';
          0.33 0.37 20, 'Identities are still correct'};
Mov = fnMovieText(acText, 3, 3,3,Mov,MovieOutputSize);

aiInterval = 1158777:5:1160000;
Mov = fnMovieFadeInOut(strctMovInfo, astrctTrackers, aiInterval,2, 2,Mov,MovieOutputSize);


acText = {0.13, 0.5, 30, 'Correct identities in complex interactions'};
Mov = fnMovieText(acText, 3, 3,3,Mov,MovieOutputSize);

aiInterval = round(397700:1:397795);
Mov = fnMovieFadeInOut(strctMovInfo, astrctTrackers, aiInterval,0.5, 0.2,Mov,MovieOutputSize);

acText = {0.13, 0.5, 30, 'Correct identities in complex interactions';
          0.35, 0.4, 20, 'Slow motion version'};

Mov = fnMovieText(acText, 3, 3,3,Mov,MovieOutputSize);

aiInterval = round(397747:0.3:397792);
Mov = fnMovieFadeInOut(strctMovInfo, astrctTrackers, aiInterval,0.2, 0.2,Mov,MovieOutputSize);


acText = {0.1, 0.5, 40, 'Automatic Behavior Detection';
          0.33 0.37 20, 'Red Following Green'};
Mov = fnMovieText(acText, 3, 3,3,Mov,MovieOutputSize);


aiInterval = astrctIntervalsFollowing(1).m_iStart:1:astrctIntervalsFollowing(1).m_iEnd+60;
Mov = fnMovieFadeInOut(strctMovInfo, astrctTrackers, aiInterval,0.3, 0.3,Mov,MovieOutputSize);

aiInterval = astrctIntervalsFollowing(2).m_iStart:1:astrctIntervalsFollowing(2).m_iEnd+60;
Mov = fnMovieFadeInOut(strctMovInfo, astrctTrackers, aiInterval,0.3, 0.3,Mov,MovieOutputSize);

aiInterval = astrctIntervalsFollowing(3).m_iStart:1:astrctIntervalsFollowing(3).m_iEnd+60;
Mov = fnMovieFadeInOut(strctMovInfo, astrctTrackers, aiInterval,0.3, 0.3,Mov,MovieOutputSize);

acText = {0.1, 0.5, 40, 'Automatic Behavior Detection';
          0.33 0.37 20, 'Blue Following Red'};
Mov = fnMovieText(acText, 3, 3,3,Mov,MovieOutputSize);

aiInterval = astrctIntervalsFollowing2(1).m_iStart:1:astrctIntervalsFollowing2(1).m_iEnd+60;
Mov = fnMovieFadeInOut(strctMovInfo, astrctTrackers, aiInterval,0.3, 0.3,Mov,MovieOutputSize);

aiInterval = astrctIntervalsFollowing2(2).m_iStart:1:astrctIntervalsFollowing2(2).m_iEnd+60;
Mov = fnMovieFadeInOut(strctMovInfo, astrctTrackers, aiInterval,0.3, 0.3,Mov,MovieOutputSize);

acText = {0.1, 0.5, 40, 'Automatic Behavior Detection';
          0.33 0.37 20, 'Red Sniff Cyan''s butt'};
Mov = fnMovieText(acText, 3, 3,3,Mov,MovieOutputSize);

aiInterval = astrctIntervalsSniffButt1(1).m_iStart-30:1:astrctIntervalsSniffButt1(1).m_iEnd+30;
Mov = fnMovieFadeInOut(strctMovInfo, astrctTrackers, aiInterval,0.3, 0.3,Mov,MovieOutputSize);


aiInterval = astrctIntervalsSniffButt1(3).m_iStart-30:1:astrctIntervalsSniffButt1(3).m_iEnd+30;
Mov = fnMovieFadeInOut(strctMovInfo, astrctTrackers, aiInterval,0.3, 0.3,Mov,MovieOutputSize);

acText = {0.1, 0.5, 40, 'Automatic Behavior Detection';
          0.33 0.37 20, 'Blue Sniff Red''s butt'};
Mov = fnMovieText(acText, 3, 3,3,Mov,MovieOutputSize);

aiInterval = astrctIntervalsSniffButt1(5).m_iStart-30:1:astrctIntervalsSniffButt1(5).m_iEnd+30;
Mov = fnMovieFadeInOut(strctMovInfo, astrctTrackers, aiInterval,0.3, 0.3,Mov,MovieOutputSize);


acText = {0.1, 0.5, 40, 'Automatic Behavior Detection';
          0.33 0.37 20, 'Red Sniff Cyan''s head'};
Mov = fnMovieText(acText, 3, 4,3,Mov,MovieOutputSize);

aiInterval = strctIntervalsKiss1(5).m_iStart-30:1:strctIntervalsKiss1(5).m_iEnd+30;
Mov = fnMovieFadeInOut(strctMovInfo, astrctTrackers, aiInterval,0.3, 0.3,Mov,MovieOutputSize);

aiInterval = strctIntervalsKiss1(1).m_iStart-30:1:strctIntervalsKiss1(1).m_iEnd+30;
Mov = fnMovieFadeInOut(strctMovInfo, astrctTrackers, aiInterval,0.3, 0.3,Mov,MovieOutputSize);


aiInterval = strctIntervalsKiss1(2).m_iStart-30:1:strctIntervalsKiss1(2).m_iEnd+20;
Mov = fnMovieFadeInOut(strctMovInfo, astrctTrackers, aiInterval,0.3, 0.3,Mov,MovieOutputSize);


Mov = close(Mov);
 