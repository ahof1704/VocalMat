% This scripts generates the identity error plot for the paper using the
% following ground truth data...


% GT collected by Sager:
% cage_11
% Problem: we cannot generate new results on this sequence because we do
% not have the single mouse clips :(
% However, we do have the old results available somehow.....in a huge 1G
% matlab file....
%  They array of 12 entries correspond to:
% day 0: 09.58.54.843 and 21.58.55.781 (truncated to only ~ 6 hours)
% day 1: 10.04.19.390 and 22.04.20.265
% day 2: 10.04.21.125 and 22.04.21.984
% day 3: 10.04.22.843 and 22.04.23.796
% day 4: 10.04.24.687 and 22.04.25.593
% day 5: 10.04.26.468 and 22.04.27.312
% it contains both GT and results for the entire 6 days experiment...
iNumMice = 4;

bLoadSagerData = true;
bLoadAnu = false;
iCounter = 1;

if bLoadSagerData
    acSeqNames = {'09.58.54.843','21.58.55.781','10.04.19.390','22.04.20.265','10.04.21.125','22.04.21.984','10.04.22.843','22.04.23.796','10.04.24.687','22.04.25.593','10.04.26.468','22.04.27.312'};
    strctGT = load('D:\Data\Janelia Farm\GroundTruth\SagerFull\AllSagerGT_UnRandomized.mat');
    clear astrctGroundTruth
    for iIter=iCounter:iCounter+11
        % By default, the tracking result is taken from the same version that
        % was used to generate the ground truth data....
        % However, if newer results are available, they can be loaded instead.
        astrctGroundTruth(iIter) = fnGenereateIdentityErrorPlotLoad(strctGT.astrctGT(iIter),acSeqNames{iIter},'cage11');%,['E:\JaneliaResults\cage11\Results\Tracks\',acSeqNames{iIter},'.mat']) ;
    end
    iCounter = iCounter+12;
end

%%
%% Load Anu's ground truth data
if bLoadAnu
    strctGT = load('D:\Data\Janelia Farm\FinalGroundTruth\GroundTruth_b6_pop_cage_14_12.03.10_09.52.07.992._newcomplete.seq_UnRandomized.mat');
    astrctGroundTruth(iCounter) = fnGenereateIdentityErrorPlotLoad(strctGT,'12.03.10_09.52.07.992','cage14','D:\Data\Janelia Farm\Baseline_rev170\cage14\Results\Tracks\b6_pop_cage_14_12.03.10_09.52.07.992.mat') ;

    strctGT = load('D:\Data\Janelia Farm\FinalGroundTruth\GroundTruth_b6_popcage_16_110405_09.58.30.268.seq._5808_UnRandomized.mat');
    astrctGroundTruth(iCounter+1) = fnGenereateIdentityErrorPlotLoad(strctGT,'110405_09.58.30.268','cage16','D:\Data\Janelia Farm\Baseline_rev170\cage16\Results\Tracks\b6_popcage_16_110405_09.58.30.268.mat') ;
    iCounter = iCounter + 2;
end

a2fColors = fnGetFancyColors();
%% Compare....
% For each ground truth entry, compute the normalized distance between 
iNumGroundTruthEntries = length(astrctGroundTruth);
a2iCumAssignments = [];
a2fCumNormDistance = [];
afCumMinPosDist = [];
for iGT=1:iNumGroundTruthEntries
    [a2iAssignment, a2fNormDistance, afMinPosDistance] = fnGenerateIdentityErrorPlotAux(astrctGroundTruth(iGT).m_astrctCorrectPosition, astrctGroundTruth(iGT).m_astrctTrackers);
    a2iCumAssignments = [a2iCumAssignments;a2iAssignment];
    a2fCumNormDistance = [a2fCumNormDistance;a2fNormDistance];
    afCumMinPosDist = [afCumMinPosDist,afMinPosDistance];
end

figure;plot(afMinPosDistance)

figure(10);
clf;
[afX,afY]=hist(afCumMinPosDist,300);

semilogx(afY,afX);


iNumFrames = size(a2iCumAssignments,1);
aiNumWrongAssignments = sum((a2iCumAssignments - repmat([1,2,3,4],iNumFrames,1)) ~= 0,2);
%%
figure(15);
clf;
[afHist,afCent]=hist(aiNumWrongAssignments,[0 1 2 3 4]);
bar(afCent,afHist);
set(gca,'xtick',[0 2 3 4])
set(gca,'xticklabel',{'All Correct','Two ID wrong','Three ID wrong','All incorrect'});
ylabel('Number of key frames');
%%

abHuddling = (afCumMinPosDist < 35);
sum(aiNumWrongAssignments == 0)/  iNumFrames * 1e2

title('All');
subplot(1,3,2);
hist(aiNumWrongAssignments(abHuddling))
title('While Huddling');
subplot(1,3,3);
hist(aiNumWrongAssignments(~abHuddling))
title('Not Huddling');



%%
 a2fTimeMin = zeros(12,2);
for k=1:12
    a2fTimeMin(k,:) = (k-1)*12*60 + astrctGroundTruth(k).m_aiFrames([1,end])/30 / 60;
end
figure(20);
clf;hold on;
% Draw Days (dark, light)
for iDayIter=0:5
    % Dark Period
    x = iDayIter * 24 * 60;
    y = 0;
    h = 1;
    w = 12 * 60;
    rectangle('Position',[x,y,w,h],'facecolor',[0.3 0.3 0.3]);
    % Dark Period
    x = iDayIter * 24 * 60 + 12*60;
    y = 0;
    h = 1;
    w = 12 * 60;
    rectangle('Position',[x,y,w,h],'facecolor',[0.9 0.9 0.9]);
    
end

for k=1:size(a2fTimeMin,1)
    x = a2fTimeMin(k,1);
    y = 0;
    h = 1;
    w = a2fTimeMin(k,2)-a2fTimeMin(k,1);
    rectangle('Position',[x,y,w,h],'facecolor',a2fColors(1,:));
end
set(gca,'ytick',[]);
set(gca,'xtick',[0:12:145]*60);
set(gca,'xticklabel',{'0',   '12'  , '24'  , '36'   ,'48' , '60'   ,'72' ,'84'  ,'96'  ,'108'  ,'120'  ,'132','140'});
set(gca,'xlim',[0 144]*60);	
set(gca,'xtick',[])
set(gca,'ytick',[])
set(20,'position',[513        1009         727          89])

%% 
% Show that some frames are very difficult to identify patterns (huddling)
% while others are easier....
strctMov = fnReadSeqInfo('L:\popcage_16\b6_popcage_16_110405_09.58.30.268.seq');
aiKeyFrames = [376379, 325746 1257646];
a2fFocus = [606.7595  742.5084   186.4934  300.3050;
                     100 261  623, 744
                     424 592,  602 730];
figure(100);
clf;
for k=1:length(aiKeyFrames)
I=fnReadFrameFromSeq(strctMov,aiKeyFrames(k));
subplot(1,3,k);
imshow(I,[]);
axis(a2fFocus(k,:));
end


afMinDist1 = fnGetMinimumDist('D:\Data\Janelia Farm\Baseline_rev170\cage16\Results\Tracks\b6_popcage_16_110405_09.58.30.268.mat');
afMinDist2 = fnGetMinimumDist('D:\Data\Janelia Farm\Baseline_rev170\cage16\Results\Tracks\b6_popcage_16_110405_21.58.31.238.mat');
afMinDist3 = fnGetMinimumDist('D:\Data\Janelia Farm\Baseline_rev170\cage16\Results\Tracks\b6_popcage_16_110405_09.58.32.269.mat');
 
%%
afRange = [0:800];
figure(10);
[afH,afC]=hist(afMinDist1,afRange)    
semilogx(afC,afH);
xlabel('Minimum distance');
ylabel('Number of frames');
figure(11);
[afH,afC]=hist(afMinDist2,afRange)    
plot(afC,afH);
xlabel('Minimum distance');
ylabel('Number of frames');
figure(12);
[afH,afC]=hist(afMinDist3,afRange)    
plot(afC,afH);
xlabel('Minimum distance');
ylabel('Number of frames');
figure(13);
[afH,afC]=hist([afMinDist1,afMinDist2,afMinDist3],afRange)    
loglog(afC,afH);
xlabel('Minimum distance');
ylabel('Number of frames');


semilogx(afC,afH);

%%


