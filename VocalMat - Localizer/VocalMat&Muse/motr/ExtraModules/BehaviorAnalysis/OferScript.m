%% set file names
% strResultFile = 'C:\MouseTrack\Data\Janelia Farm\Results\10.04.19.390_cropped_120-175\SequenceViterbi_28-Mar-2010.mat';
% strMovieFile = 'C:\MouseTrack\Data\Janelia Farm\Movies\SeqFiles\10.04.19.390_cropped_120-175.seq';
strResultFile = 'C:\MouseTrack\Data\Results\10.04.19.390_cropped_120-175\SequenceViterbi_28-Mar-2010.mat';
strMovieFile = 'C:\MouseTrack\Data\Movies\10.04.19.390_cropped_120-175.seq';

%% load files
strctMovInfo = fnReadVideoInfo(strMovieFile);
strctResults = load(strResultFile);

%%
astrctTrackers = strctResults.astrctTrackers;

%%
strctMousePOIparams1 = struct('iPointsNum',  {1, 1}, 'fNormRadius', {0, 1});
strctMousePOIparams2 = struct('iPointsNum',  {1, 2}, 'fNormRadius', {0, 1});
astrctFramePOI = struct('x', 0, 'y', 0);
strctFeatureParams = struct('bMouseFrame', false, 'bMousePair', true, 'aTimeScales', [2], 'bCoordinates', true, 'bDistances', false);
F = fnCalcMouseFeatures(1, astrctTrackers, strctMousePOIparams1, strctMousePOIparams2, astrctFramePOI, strctFeatureParams);

%% calc all positions
strctAllPos = fnCalcAllPos(strctResults.astrctTrackers);

%% calc features
aTimeScales = [2 8];
iTimeScale = max(aTimeScales);
[F, distInd, miceInd] = fnCalcFeatures(strctAllPos, aTimeScales);

%% calc head (nose) positions
strctHeadPos = fnCalcHeadPos(strctResults.astrctTrackers);

%% calc min head dist
[headDist, distInd, miceInd] = fnCalcHeadDist(strctHeadPos);

%% create a list of head-proximity intervals 
astrctBehaviors = fnDetectHeadProximity(headDist, miceInd);

%% detect approach/depart
astrctBehaviors = fnDetectApproachDepart(astrctBehaviors, strctHeadPos);

%% show list of head-proximity intervals
eventInd = 1;
frameStart = max(1, astrctBehaviors(eventInd).m_iStart-30);
frameEnd = min(strctMovInfo.m_iNumFrames, astrctBehaviors(eventInd).m_iEnd+20);
for iFrame=frameStart:frameEnd
    showFrame(iFrame, strctMovInfo, strctResults.astrctTrackers, strctHeadPos);
end

%% show list of head-proximity intervals
navigateMovie(strctMovInfo, strctResults.astrctTrackers, strctHeadPos, iTimeScale, Sniff);

%% define behavior from scratch or edit previously defined behavior
iMouseNum = 2; % num of mice this behavior is defined over
% aBehaviorExamples = [];
aBehaviorExamples=fnDefineBehavior(strctMovInfo, strctResults.astrctTrackers, ...
                                                                                           strctHeadPos, iTimeScale, iMouseNum, aBehaviorExamples)
                                                                                       
 %%
[aBehaviorResults, classifier] = fnGeneralizeBehavior(aBehaviorExamples, miceInd, F, iTimeScale);
aBehaviorResultsEdited = fnDefineBehavior(strctMovInfo, strctResults.astrctTrackers, ...
                                                                                                           strctHeadPos, iTimeScale, iMouseNum, aBehaviorResults);
                                                                                                       
 %%
 fnCompareBehaviorAnnotationToGroundTruth('C:\MouseTrack\Data\Results\AnnotationOA_1.mat', 'C:\MouseTrack\Data\Results\10.04.19.390_cropped_120-175\Annotation, Blue 10K, Red, 4.6K.mat');
                                                                                                       
                                                                                       
%% compare heuristic classification with boosting
heuristic = -ones(size(miceInd,1),size(F,2));
for i=1:length(astrctBehaviors)
    aFrames = max(1, (astrctBehaviors(i).m_iStart+1:astrctBehaviors(i).m_iEnd) - iTimeScale);
    heuristic(astrctBehaviors(i).m_iPair, aFrames) = 1;
end
for pairInd=4:4
    display(['Compare pairInd ' num2str(pairInd)])
    compareClassifiers(strctMovInfo, strctResults.astrctTrackers, strctHeadPos, iTimeScale, ...
                                                     heuristic(pairInd,:), sniff(pairInd,:), miceInd(pairInd,:));
end

%% call gentleboost
Nrounds = 16;
pairsNum = size(miceInd,1);
y = -ones(pairsNum,size(F,2));
headProxFrameNum = 0;
for i=1:length(astrctBehaviors)
    aFrames = max(1, (astrctBehaviors(i).m_iStart+1:astrctBehaviors(i).m_iEnd) - iTimeScale);
    y(astrctBehaviors(i).m_iPair, aFrames) = 1;
    headProxFrameNum = headProxFrameNum + length(aFrames);
end
% Frs = [[F(1:4,:); F(9:18,:)] [F([1 2 5 6],:); F(19:28,:)] [F([1 2 7 8],:); F(29:38,:)] [F(3:6,:); F(39:48,:)] [F([3 4 7 8],:); F(49:58,:)] [F(5:8,:); F(59:68,:)]];
Frs = [];
for k=1:pairsNum
    [i, j] = miceInd(k);
    Frs = [Frs [F([4*i-3:4*i 4*j-3:4*j],:); F(15*k+2:15*k+17,:)]];
end
yrs = y';
classifier = gentleBoost(Frs, yrs(:)', Nrounds);
[sniff,sniffScore] = strongGentleClassifier(Frs, classifier);
sniff = reshape(sniff, strctMovInfo.m_iNumFrames-iTimeScale, pairsNum)';

%% calc single mouse features and call gentleboost
aTimeScales = [2 8];
iTimeScale = max(aTimeScales);
Nrounds = 10;
F1 = fnCalcFeatures1(strctAllPos, aTimeScales);
[Fb,y]=fnPrepareLearnInput(aBehaviorExamples, F1, iTimeScale);
classifier = gentleBoost(Fb, y, Nrounds);
aBehaviorResults = [];
for i=2:2
    r = (4*i-3):(4*i);
    [behaviorTags, behaviorScore] = strongGentleClassifier(F1(r,:), classifier);
    aBehaviorResults = [aBehaviorResults fnGetBehavior(behaviorTags, i, iTimeScale)];
end
aBehaviorResultsEdited=fnDefineBehavior(strctMovInfo, strctResults.astrctTrackers, ...
                                                                                                         strctHeadPos, iTimeScale, iMouseNum, aBehaviorResults);

%% show head-proximity stat
figure(2)
frameStart= [astrctBehaviors.m_iStart];
numOfFrames= [astrctBehaviors.m_iEnd] - [astrctBehaviors.m_iStart];
group = [astrctBehaviors.m_iPair];
% group(group~=1) = 2;
% gscatter(frameStart, numOfFrames, group,[],[],5);
[frameSort, perm] = sort(frameStart);
pairSeq = group(perm);
P = [pairSeq(1:end-1); pairSeq(2:end)];
S = P(1,:) + 6*(P(2,:)-1);
H = hist(S,1:36);
H2 = reshape( H,6,6);
imagesc(H2), colormap(gray)
P = [pairSeq(1:end-2); pairSeq(2:end-1); pairSeq(3:end)];
S = P(1,:) + 6*(P(2,:)-1) + 36*(P(3,:)-1);
H = hist(S,1:216);
plot(sort(H))
find(H>10)



% for eventInd=1:length(astrctBehaviors)
%     if all(astrctBehaviors(eventInd).m_bApproach==0)
%         aMice = astrctBehaviors(eventInd).m_aMice;
%         showEvent(astrctBehaviors(eventInd), strctMovInfo, strctResults.astrctTrackers, strctHeadPos);
%     end
% end

%% prepare intervals of (presumably) head sniffing
iNumMice = length(strctResults.astrctTrackers);
ind = distInd(1, 3);
distThrHystExt = 16;
distThrHyst = 20;
distThr = 16;
iFrameStart = find(headDist(ind,2:end) < distThr & headDist(ind,1:end-1) > distThr);
iFrameEnd = find(headDist(ind,2:end) > distThr & headDist(ind,1:end-1) < distThr);
if iFrameStart(1) > iFrameEnd(1)
    iFrameStart = [1, iFrameStart];
end
if iFrameEnd(end) < iFrameStart(end)
    iFrameEnd = [iFrameEnd strctMovInfo.m_iNumFrames];
end
for i=1:length(iFrameEnd)-1
    if sum(headDist(ind,iFrameEnd(i):iFrameStart(i+1))-distThrHyst) < distThrHystExt
       iFrameEnd(i) = 0; iFrameStart(i+1) = 0;
    end
end
iFrameStart = iFrameStart(find(iFrameStart>0));
iFrameEnd = iFrameEnd(find(iFrameEnd>0));
iFrameInterval = [iFrameStart; iFrameEnd];

%% skip between (presumably) head sniffing intervals and show frames with marked heads
iFrame = iFrameInterval(60);
a2iFrame = fnReadFrameFromVideo(strctMovInfo, iFrame);
figure(1); clf;
imshow(a2iFrame,[]);
hAxes = gca;
hold on;
title(['frame ' num2str(iFrame)]);
fnDrawTrackers4(strctResults.astrctTrackers, iFrame, hAxes);
for iMouseIndex=1:iNumMice
    X =  strctResults.astrctTrackers(iMouseIndex).m_afX(iFrame);
    Y =  strctResults.astrctTrackers(iMouseIndex).m_afY(iFrame);
    plot(X, Y, '+b');
    plot(strctHeadPos(iMouseIndex).x(iFrame), strctHeadPos(iMouseIndex).y(iFrame), '+r');
end
hold off

%% show frame with marked heads
iNumMice = length(strctResults.astrctTrackers);
iFrame = 2513;
a2iFrame = fnReadFrameFromVideo(strctMovInfo, iFrame);
figure(1); clf;
imshow(a2iFrame,[]);
hAxes = gca;
hold on;
title(['frame ' num2str(iFrame)]);
fnDrawTrackers4(strctResults.astrctTrackers, iFrame, hAxes);
for iMouseIndex=2:3 %iNumMice
    X =  strctResults.astrctTrackers(iMouseIndex).m_afX(iFrame);
    Y =  strctResults.astrctTrackers(iMouseIndex).m_afY(iFrame);
    plot(X, Y, '+b');
    plot(strctHeadPos(iMouseIndex).x(iFrame), strctHeadPos(iMouseIndex).y(iFrame), '+r');
end
hold off

% figure(2); clf
% plot(strctResults.astrctTrackers(1).m_afX)

