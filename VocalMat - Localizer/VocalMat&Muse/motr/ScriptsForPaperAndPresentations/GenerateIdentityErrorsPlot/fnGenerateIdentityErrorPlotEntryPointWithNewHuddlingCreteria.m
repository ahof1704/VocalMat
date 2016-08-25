% This scripts generates the identity error plot for the paper using the
% following ground truth data...


a2fColors = [188,44,47; % Red
 46,87,139; % Blue
 93,149,72; % Green
 231,160,60; % Brown/yellow
 0,162,232; % Bright blue
 192,192,192;
 128,128,128];

afStats= [99.4,0.3,0.3]/100;

figure(18);clf;hold on;
bar(2,afStats(2),'facecolor',[46,87,139]/255);
bar(1,afStats(1),'facecolor',[93,149,72]/255);
bar(3,afStats(3),'facecolor',[188,44,47]/255);
set(gca,'xticklabel',[]);
set(gca,'ytick',0:0.2:1);
ylabel('Fraction of annotated images');

bLoadAhsleyData = false;
bLoadAndrewData = true;

if bLoadAndrewData
    acSeqNames = {'b6_popcage_18_09.15.11_10.56.24.135','b6_popcage_18_09.15.11_22.56.24.848','b6_popcage_18_09.17.11_10.56.27.049',...
        'b6_popcage_18_09.17.11_22.56.27.802','b6_popcage_18_09.19.11_10.56.29.998','b6_popcage_18_09.19.11_22.56.30.748'};
    clear strctGT
    strctGT.astrctGT(1) = load('D:\Data\Janelia Farm\GroundTruth\popcage18gt_andrew\Unrandom\b6_popcage_18_09.15.11_10.56.24.135.mat'); % 1 Dark
    strctGT.astrctGT(2) = load('D:\Data\Janelia Farm\GroundTruth\popcage18gt_andrew\Unrandom\b6_popcage_18_09.15.11_22.56.24.848.mat'); % 2 Light
    strctGT.astrctGT(3) = load('D:\Data\Janelia Farm\GroundTruth\popcage18gt_andrew\Unrandom\b6_popcage_18_09.17.11_10.56.27.049.mat'); % 5 Dark
    strctGT.astrctGT(4) = load('D:\Data\Janelia Farm\GroundTruth\popcage18gt_andrew\Unrandom\b6_popcage_18_09.17.11_22.56.27.802.mat'); % 6 Light
    strctGT.astrctGT(5) = load('D:\Data\Janelia Farm\GroundTruth\popcage18gt_andrew\Unrandom\b6_popcage_18_09.19.11_10.56.29.998.mat'); % 9 Dark
    strctGT.astrctGT(6) = load('D:\Data\Janelia Farm\GroundTruth\popcage18gt_andrew\Unrandom\b6_popcage_18_09.19.11_22.56.30.748.mat'); % 10 Light
    
    aiLight = [2,4,6];
    aiDark = [1,3,5];
    
    clear astrctGroundTruth
    strFileSeekRoot = 'D:\Data\Janelia Farm\ResultsFromNewTrunk\cage18\SEQ\';
    for iIter=1:6
        % By default, the tracking result is taken from the same version that
        % was used to generate the ground truth data....
        % However, if newer results are available, they can be loaded instead.
        astrctGroundTruth(iIter) = fnGenereateIdentityErrorPlotLoad(strctGT.astrctGT(iIter),acSeqNames{iIter},'cage18',[], strFileSeekRoot);%,['E:\JaneliaResults\cage11\Results\Tracks\',acSeqNames{iIter},'.mat']) ;
    end
end

if bLoadAhsleyData
    acSeqNames = {'b6_popcage_18_09.15.11_10.56.24.135','b6_popcage_18_09.15.11_22.56.24.848','b6_popcage_18_09.17.11_10.56.27.049',...
        'b6_popcage_18_09.17.11_22.56.27.802','b6_popcage_18_09.19.11_10.56.29.998','b6_popcage_18_09.19.11_22.56.30.748'};
    clear strctGT
    strctGT.astrctGT(1) = load('D:\Data\Janelia Farm\GroundTruth\popcage18gt_ashley\Unrandomized\b6_popcage_18_09.15.11_10.56.24.135.mat');
    strctGT.astrctGT(2) = load('D:\Data\Janelia Farm\GroundTruth\popcage18gt_ashley\Unrandomized\b6_popcage_18_09.15.11_22.56.24.848.mat');
    strctGT.astrctGT(3) = load('D:\Data\Janelia Farm\GroundTruth\popcage18gt_ashley\Unrandomized\b6_popcage_18_09.17.11_10.56.27.049.mat');
    strctGT.astrctGT(4) = load('D:\Data\Janelia Farm\GroundTruth\popcage18gt_ashley\Unrandomized\b6_popcage_18_09.17.11_22.56.27.802.mat');
    strctGT.astrctGT(5) = load('D:\Data\Janelia Farm\GroundTruth\popcage18gt_ashley\Unrandomized\b6_popcage_18_09.19.11_10.56.29.998.mat');
    strctGT.astrctGT(6) = load('D:\Data\Janelia Farm\GroundTruth\popcage18gt_ashley\Unrandomized\b6_popcage_18_09.19.11_22.56.30.748.mat');
    clear astrctGroundTruth
    strFileSeekRoot = 'D:\Data\Janelia Farm\ResultsFromNewTrunk\cage18\SEQ\';
    for iIter=1:6
        % By default, the tracking result is taken from the same version that
        % was used to generate the ground truth data....
        % However, if newer results are available, they can be loaded instead.
        astrctGroundTruth(iIter) = fnGenereateIdentityErrorPlotLoad(strctGT.astrctGT(iIter),acSeqNames{iIter},'cage18',[], strFileSeekRoot);%,['E:\JaneliaResults\cage11\Results\Tracks\',acSeqNames{iIter},'.mat']) ;
    end
end

%%


%% Correct Huddling annotation using hard-data
load('D:\Data\Janelia Farm\ResultsFromNewTrunk\cage18_dist.mat');
a2fDistance(a2fDistance>2000) = NaN;
Pos18=load('D:\Data\Janelia Farm\ResultsFromNewTrunk\cage18_matrix.mat');
% Compute velocity
a2fVel = [zeros(1,4); sqrt((Pos18.X(2:end,:)-Pos18.X(1:end-1,:)).^2+(Pos18.Y(2:end,:)-Pos18.Y(1:end-1,:)).^2)];

a2bHuddling = zeros(size(a2fVel),'uint8')>0;
for k=1:4
    a2bHuddling(:,k) = min(a2fDistance(:, a2iMinMouseDist(k,:)),[],2) < fHuddlingThreshold;
end


a2fVelSmooth=conv2(a2fVel, fspecial('gaussian',[1 5*7],5)','same');
PIX_TO_CM = 0.08;
VelocityStatioaryCMsec = 7.2;
VelocityStationaryPix = VelocityStatioaryCMsec/30 / PIX_TO_CM;


a2iMinMouseDist = [1,2,3;
 1,4,5;
 2,4,6;
 3,5,6];


fHuddlingThreshold = 7;
fStationaryThreshold = VelocityStationaryPix;

for iIter=1:length(astrctGroundTruth)

    for iMouseIter=1:4
        astrctGroundTruth(iIter).m_a2bStationary(iMouseIter,:) = a2fVelSmooth(astrctGroundTruth(iIter).m_aiFramesRelativeToExpStart, iMouseIter) <fStationaryThreshold;
    end
    
    for iMouseIter=1:4
        astrctGroundTruth(iIter).m_a2bHuddlingData(iMouseIter,:) = ...
            min(a2fDistance(astrctGroundTruth(iIter).m_aiFramesRelativeToExpStart, a2iMinMouseDist(iMouseIter,:)),[],2) < fHuddlingThreshold &  astrctGroundTruth(iIter).m_a2bStationary(iMouseIter,:)';
    end
        
    astrctGroundTruth(iIter).m_a2bCorrectIdentification = fnGenerateIdentityErrorPlotAuxNew(...
        astrctGroundTruth(iIter).m_astrctCorrectPosition, astrctGroundTruth(iIter).m_astrctTrackers);
    
end
% a2bStat = cat(2,astrctGroundTruth.m_a2bStationary);
% a2bHud = cat(2,astrctGroundTruth.m_a2bHuddlingData);
% fprintf('%d images are available\n',prod(size(a2bStat)));
% fprintf('Out of which, %d are huddling images (%.2f %%) \n',sum(a2bHud(:)),sum(a2bHud(:))/prod(size(a2bStat))*1e2);
% fprintf('Out of the %d huddling images, %d are also stationary\n',sum(a2bHud(:)),sum(a2bStat(:) & a2bHud(:)));
% sum(a2bStat(:) & a2bHud(:))/sum(a2bHud(:))

figure(100);
clf;
[afY,afX]=hist(a2fDistance(:,1),1000);
semilogy(afX,afY);
xlabel('Inter-mouse distance (pix)');
ylabel('Log number of frames');




%% Come up with the number per session....
for iIter=1:6

    % The magic numbers are:
    
    
    a2bHuddling = cat(2,astrctGroundTruth(iIter).m_a2bHuddlingData)';
    a2bID= cat(1,astrctGroundTruth(iIter).m_a2bCorrectIdentification);

    % 1. total number of annotations in this interval
    
    astrctStats(iIter).m_iTotalNumberOfImages = length(a2bID(:));
    astrctStats(iIter).m_iNumHuddling = sum(a2bHuddling(:));
    astrctStats(iIter).m_iNumNonHuddling = sum(~a2bHuddling(:));
    % 2. What is the number of failed segmentation?
    astrctStats(iIter).m_iNumFailedSegmentation = sum(isnan(a2bID(:)));
    % Out of those, how many were during huddling?
    astrctStats(iIter).m_iNumFailedSegmentationHuddling = sum(sum(isnan(a2bID) & a2bHuddling));
    astrctStats(iIter).m_iNumFailedSegmentationNonHuddling = sum(sum(isnan(a2bID) & ~a2bHuddling));

    
    % Correct segmented:
    iNumCorrectlySegmented = length(a2bID(:)) - sum(isnan(a2bID(:)));
    astrctStats(iIter).m_iNumCorrectSegmentation = iNumCorrectlySegmented;

    % 3. What is the number of correct identification?
    astrctStats(iIter).m_iNumCorrectID = sum(a2bID(:) == 1);
    
    astrctStats(iIter).m_iNumCorrectIDHuddling = sum(a2bID(:) == 1 & a2bHuddling(:));
    astrctStats(iIter).m_iNumCorrectIDNotHuddling = sum(a2bID(:) == 1 & ~a2bHuddling(:));
    
    % What is the number of incorrect identification
    astrctStats(iIter).m_iNumIncorrectID = sum(a2bID(:) == 0);
    astrctStats(iIter).m_iNumIncorrectIDHuddling = sum(a2bID(:) == 0 & a2bHuddling(:));
    astrctStats(iIter).m_iNumIncorrectIDNotHuddling = sum(a2bID(:) == 0 & ~a2bHuddling(:));
end



%% Now, draw the statistics as bar plots:
for iIter=1:6
    a2fStats(iIter,:) = [astrctStats(iIter).m_iNumFailedSegmentation, astrctStats(iIter).m_iNumCorrectID,astrctStats(iIter).m_iNumIncorrectID];
    a2fStatsDetailed(iIter,:) = [astrctStats(iIter).m_iNumFailedSegmentationHuddling, ...
                                 astrctStats(iIter).m_iNumFailedSegmentationNonHuddling,...
                                 astrctStats(iIter).m_iNumCorrectIDHuddling,...
                                 astrctStats(iIter).m_iNumCorrectIDNotHuddling,...
                                 astrctStats(iIter).m_iNumIncorrectIDHuddling,...
                                 astrctStats(iIter).m_iNumIncorrectIDNotHuddling];
end
a2fStatsNormalized = a2fStats ./ repmat(sum(a2fStats,2),1,3);
a2fStatsDetailedNormalized = a2fStatsDetailed ./ repmat(sum(a2fStatsDetailed,2),1,6)
%%
a2fColors = [188,44,47; % Red
 46,87,139; % Blue
 93,149,72; % Green
 231,160,60; % Brown/yellow
 0,162,232; % Bright blue
 192,192,192;
 128,128,128];

figure(3);
clf;
set(gcf,'Color',[1 1 1]);
subplot(1,2,1);
h1=bar(1:2:6,a2fStats(1:2:6,:),'stacked','barwidth',0.4);hold on;
set(h1(1),'facecolor',[46,87,139]/255);
set(h1(2),'facecolor',[93,149,72]/255);
set(h1(3),'facecolor',[188,44,47]/255);
h2=bar([1:2:6]+0.2,a2fStatsDetailed(1:2:6,:),'stacked','barwidth',0.2);
set(h2([1,3,5]),'facecolor',[128 128 128]/255);
set(h2([2,4,6]),'facecolor',[192 192 192]/255);
set(gca,'XtickLabel',{'Day 1','Day 3','Day 5'});
ylabel('Number of annotated images');
box off
title('Dark Cycle');
subplot(1,2,2);
h1=bar(1:2:6,a2fStats(2:2:6,:),'stacked','barwidth',0.4);hold on;
set(h1(1),'facecolor',[46,87,139]/255);
set(h1(2),'facecolor',[93,149,72]/255);
set(h1(3),'facecolor',[188,44,47]/255);
h2=bar([1:2:6]+0.2,a2fStatsDetailed(2:2:6,:),'stacked','barwidth',0.2);
set(h2([1,3,5]),'facecolor',[128 128 128]/255);
set(h2([2,4,6]),'facecolor',[192 192 192]/255);
set(gca,'XtickLabel',{'Day 1','Day 3','Day 5'});
box off
title('Light Cycle');


%%
figure(4);
clf;
set(gcf,'Color',[1 1 1]);
subplot(1,2,1);
h1=bar(1:2:6,a2fStatsNormalized(1:2:6,:),'stacked','barwidth',0.4);hold on;
set(h1(1),'facecolor',[46,87,139]/255);
set(h1(2),'facecolor',[93,149,72]/255);
set(h1(3),'facecolor',[188,44,47]/255);
h2=bar([1:2:6]+0.2,a2fStatsDetailedNormalized(1:2:6,:),'stacked','barwidth',0.2);
set(h2([1,3,5]),'facecolor',[128 128 128]/255);
set(h2([2,4,6]),'facecolor',[192 192 192]/255);
set(gca,'XtickLabel',{'Day 1','Day 3','Day 5'});
ylabel('Fraction of annotated images');
box off
title('Dark Cycle');
subplot(1,2,2);
h1=bar(1:2:6,a2fStatsNormalized(2:2:6,:),'stacked','barwidth',0.4);hold on;
set(h1(1),'facecolor',[46,87,139]/255);
set(h1(2),'facecolor',[93,149,72]/255);
set(h1(3),'facecolor',[188,44,47]/255);
h2=bar([1:2:6]+0.2,a2fStatsDetailedNormalized(2:2:6,:),'stacked','barwidth',0.2);
set(h2([1,3,5]),'facecolor',[128 128 128]/255);
set(h2([2,4,6]),'facecolor',[192 192 192]/255);
set(gca,'XtickLabel',{'Day 1','Day 3','Day 5'});
box off
title('Light Cycle');
%%
figure(5);
clf;
h=pie(sum(a2fStats));
set(h(1),'facecolor',[46,87,139]/255);
set(h(3),'facecolor',[93,149,72]/255);
set(h(5),'facecolor',[188,44,47]/255);
figure(7);
clf;

h=pie([sum(cat(1,astrctStats.m_iNumHuddling)), sum(cat(1,astrctStats.m_iNumNonHuddling))]);
set(h(3),'facecolor',[128,128,128]/255);
set(h(1),'facecolor',[192,192,192]/255);

figure(6);
h=bar(1:3,sum(a2fStats))
set(gca,'xtickLabel',{'Segmentation Error','Correct ID','Incorrect ID'});
ylabel('Number of annotated images');

figure(8);clf;hold on;
afSumNorm = sum(a2fStatsDetailed,1)/ sum(sum(a2fStatsDetailed,1));
afSumNorm2 = afSumNorm([2,4,6])/sum(afSumNorm([2,4,6]));
afSumNorm3 = afSumNorm([1,3,5])/sum(afSumNorm([1,3,5]));
bar(2,afSumNorm2(1),'facecolor',[46,87,139]/255);
bar(1,afSumNorm2(2),'facecolor',[93,149,72]/255);
bar(3,afSumNorm2(3),'facecolor',[188,44,47]/255);

bar(6,afSumNorm3(1),'facecolor',[46,87,139]/255);
bar(5,afSumNorm3(2),'facecolor',[93,149,72]/255);
bar(7,afSumNorm3(3),'facecolor',[188,44,47]/255);
set(gca,'xtick',[2,6],'xticklabel',{'Non-huddling','Huddling'});
grid off
ylabel('Fraction of annotated images');

%%
% Days x [FailedSeg_Hud, FailedSeg_NonHudd, CorrectHudd,Correct_NonHudd,Incorrect_Hudd,Incorrect_NonHudd

a2fSubSet = a2fStatsDetailed(:,[1,3,5]);
a2fSubSetNorm = a2fSubSet ./ repmat(sum(a2fSubSet,2),[1,3]);
figure(10);clf;hold on;
h=bar(1:6,a2fSubSetNorm(:,[2 1 3]),'stacked');
set(gca,'xtick',1:6,'xticklabel',{})
set(gca,'xlim',[0.5 6.5])
set(h(2),'facecolor',[46,87,139]/255);
set(h(1),'facecolor',[93,149,72]/255);
set(h(3),'facecolor',[188,44,47]/255);
set(gca,'yticklabel',[]);
ylabel('Fraction of annotated images');
ylabel('');

a2fSubSet2 = a2fStatsDetailed(:,[2,4,6]);
a2fSubSetNorm2 = a2fSubSet2 ./ repmat(sum(a2fSubSet2,2),[1,3]);

figure(10);clf;hold on;
h=bar(1:6,a2fSubSetNorm2(:,[2,1,3]),'stacked');
set(gca,'xtick',1:6,'xticklabel',{},'ytick',0:0.2:1)
set(gca,'xlim',[0.5 6.5])
set(h(2),'facecolor',[46,87,139]/255);
set(h(1),'facecolor',[93,149,72]/255);
set(h(3),'facecolor',[188,44,47]/255);

ylabel('Fraction of annotated images');


a2iHuddlingStat = [cat(1,astrctStats.m_iNumHuddling), cat(1,astrctStats.m_iNumNonHuddling)];

afPercHuddling = a2iHuddlingStat ./ [sum(a2iHuddlingStat,2),sum(a2iHuddlingStat,2)];



figure(11);clf;hold on;
h=bar(1:3,afPercHuddling([1,3,5],:),'stacked');
set(gca,'xtick',1:3,'xticklabel',{'Day 1','Day 3','Day 5'})
set(h(1),'facecolor',[75,172,198]/255);
set(h(2),'facecolor',[247,150,70]/255);
set(gca,'yticklabel',[]);

figure(12);clf;hold on;
h=bar(1:3,afPercHuddling([2,4,6],:),'stacked');
set(gca,'xtick',1:3,'xticklabel',{'Day 1','Day 3','Day 5'})
set(h(1),'facecolor',[75,172,198]/255);
set(h(2),'facecolor',[247,150,70]/255);
set(gca,'yticklabel',[]);




%%
legend('Segmentation Error','Correct ID','Incorrect ID','location','northeastoutside');
%%

fprintf('%d mice images were annotated\n', length(a2bID(:)));
fprintf('Out of which, %d (%.2f%%) were not segmented properly\n',sum(isnan(a2bID(:))),...
    1e2*sum(isnan(a2bID(:)))/length(a2bID(:)));
fprintf('Out of the %d correctly segmented images, the identities of %d (%.2f%%) was correct.\n',...
    iNumCorrectlySegmented, sum(a2bID(:) == 1), sum(a2bID(:) == 1)/iNumCorrectlySegmented*1e2)
a2bCorrectlySegmented = ~isnan(a2bID);
fprintf('Out of the %d correctly segmented images, %d (%.2f%%) were of mice huddled togather.\n',...
    sum(a2bCorrectlySegmented(:)),sum(a2bHuddling(a2bCorrectlySegmented)), 1e2*sum(a2bHuddling(a2bCorrectlySegmented))/sum(a2bCorrectlySegmented(:))) ;
fprintf('Out of the %d huddling frames that were correctly segmented, %.2f%% (%d) had correct identities.\n',...
    sum(a2bHuddling(a2bCorrectlySegmented)),...
    1e2*sum(sum(a2bID == 1 & a2bCorrectlySegmented == 1 & a2bHuddling))/sum(a2bHuddling(a2bCorrectlySegmented)),...
sum(sum(a2bID == 1 & a2bCorrectlySegmented == 1 & a2bHuddling)));

iNumNonHuddlingAndCorrectlySegmented = sum(a2bCorrectlySegmented(:))-sum(a2bHuddling(a2bCorrectlySegmented));
fprintf('Out of the %d non-huddling frames that were correctly segmented, %.2f%% (%d) had correct identities.\n',...
    iNumNonHuddlingAndCorrectlySegmented,...
    1e2*sum(sum(a2bID == 1 & a2bCorrectlySegmented == 1 & ~a2bHuddling))/iNumNonHuddlingAndCorrectlySegmented,...
sum(sum(a2bID == 1 & a2bCorrectlySegmented == 1 & ~a2bHuddling)));
%% Stats only for light cycle
fprintf('During the light cycle:\n');
a2bHuddling = cat(2,astrctGroundTruth(aiLight).m_a2bHuddlingData)';
a2bID= cat(1,astrctGroundTruth(aiLight).m_a2bCorrectIdentification);

fprintf('%d mice images were annotated\n', length(a2bID(:)));
fprintf('Out of which, %d (%.2f%%) were not segmented properly\n',sum(isnan(a2bID(:))),...
    1e2*sum(isnan(a2bID(:)))/length(a2bID(:)));
iNumCorrectlySegmented = length(a2bID(:)) - sum(isnan(a2bID(:)));
fprintf('Out of the %d correctly segmented images, the identities of %d (%.2f%%) was correct.\n',...
    iNumCorrectlySegmented, sum(a2bID(:) == 1), sum(a2bID(:) == 1)/iNumCorrectlySegmented*1e2)
a2bCorrectlySegmented = ~isnan(a2bID);
fprintf('Out of the %d correctly segmented images, %d (%.2f%%) were of mice huddled togather.\n',...
    sum(a2bCorrectlySegmented(:)),sum(a2bHuddling(a2bCorrectlySegmented)), 1e2*sum(a2bHuddling(a2bCorrectlySegmented))/sum(a2bCorrectlySegmented(:))) ;
fprintf('Out of the %d huddling frames that were correctly segmented, %.2f%% (%d) had correct identities.\n',...
    sum(a2bHuddling(a2bCorrectlySegmented)),...
    1e2*sum(sum(a2bID == 1 & a2bCorrectlySegmented == 1 & a2bHuddling))/sum(a2bHuddling(a2bCorrectlySegmented)),...
sum(sum(a2bID == 1 & a2bCorrectlySegmented == 1 & a2bHuddling)));

iNumNonHuddlingAndCorrectlySegmented = sum(a2bCorrectlySegmented(:))-sum(a2bHuddling(a2bCorrectlySegmented));
fprintf('Out of the %d non-huddling frames that were correctly segmented, %.2f%% (%d) had correct identities.\n',...
    iNumNonHuddlingAndCorrectlySegmented,...
    1e2*sum(sum(a2bID == 1 & a2bCorrectlySegmented == 1 & ~a2bHuddling))/iNumNonHuddlingAndCorrectlySegmented,...
sum(sum(a2bID == 1 & a2bCorrectlySegmented == 1 & ~a2bHuddling)));

%% Stats only for dark cycle
fprintf('During the dark cycle:\n');
a2bHuddling = cat(2,astrctGroundTruth(aiDark).m_a2bHuddlingData)';
a2bID= cat(1,astrctGroundTruth(aiDark).m_a2bCorrectIdentification);

fprintf('%d mice images were annotated\n', length(a2bID(:)));
fprintf('Out of which, %d (%.2f%%) were not segmented properly\n',sum(isnan(a2bID(:))),...
    1e2*sum(isnan(a2bID(:)))/length(a2bID(:)));
iNumCorrectlySegmented = length(a2bID(:)) - sum(isnan(a2bID(:)));
fprintf('Out of the %d correctly segmented images, the identities of %d (%.2f%%) was correct.\n',...
    iNumCorrectlySegmented, sum(a2bID(:) == 1), sum(a2bID(:) == 1)/iNumCorrectlySegmented*1e2)
a2bCorrectlySegmented = ~isnan(a2bID);
fprintf('Out of the %d correctly segmented images, %d (%.2f%%) were of mice huddled togather.\n',...
    sum(a2bCorrectlySegmented(:)),sum(a2bHuddling(a2bCorrectlySegmented)), 1e2*sum(a2bHuddling(a2bCorrectlySegmented))/sum(a2bCorrectlySegmented(:))) ;
fprintf('Out of the %d huddling frames that were correctly segmented, %.2f%% (%d) had correct identities.\n',...
    sum(a2bHuddling(a2bCorrectlySegmented)),...
    1e2*sum(sum(a2bID == 1 & a2bCorrectlySegmented == 1 & a2bHuddling))/sum(a2bHuddling(a2bCorrectlySegmented)),...
sum(sum(a2bID == 1 & a2bCorrectlySegmented == 1 & a2bHuddling)));

iNumNonHuddlingAndCorrectlySegmented = sum(a2bCorrectlySegmented(:))-sum(a2bHuddling(a2bCorrectlySegmented));
fprintf('Out of the %d non-huddling frames that were correctly segmented, %.2f%% (%d) had correct identities.\n',...
    iNumNonHuddlingAndCorrectlySegmented,...
    1e2*sum(sum(a2bID == 1 & a2bCorrectlySegmented == 1 & ~a2bHuddling))/iNumNonHuddlingAndCorrectlySegmented,...
sum(sum(a2bID == 1 & a2bCorrectlySegmented == 1 & ~a2bHuddling)));

%% Final Stats

a2bHuddling = cat(2,astrctGroundTruth.m_a2bHuddlingData)';
a2bID= cat(1,astrctGroundTruth.m_a2bCorrectIdentification);
a2bIDNo_NaN = a2bID;
a2bIDNo_NaN(isnan(a2bIDNo_NaN))=0;
a2bSegErr = isnan(a2bID);

N=prod(size(a2bHuddling))

NumHuddling = sum(a2bHuddling(:));
NumNonHuddling = sum(~a2bHuddling(:));
fprintf('Huddling: %d (%.2f%%)\n',NumHuddling,NumHuddling/N*1e2)
fprintf('Non Huddling Data (%d)\n', NumNonHuddling);
fprintf('Segmentation Error : %d, (%.2f%%)\n', sum(a2bSegErr(:) & ~a2bHuddling(:)),sum(a2bSegErr(:) & ~a2bHuddling(:))/NumNonHuddling*1e2);
fprintf('Correct  ID : %d, (%.2f%%)\n', sum(~a2bSegErr(:) & ~a2bHuddling(:) &  a2bIDNo_NaN(:)),sum(~a2bSegErr(:) & ~a2bHuddling(:) &  a2bIDNo_NaN(:))/NumNonHuddling*1e2)
fprintf('Incorrect  ID : %d, (%.2f%%)\n', sum(~a2bSegErr(:) & ~a2bHuddling(:) &  ~a2bIDNo_NaN(:)),sum(~a2bSegErr(:) & ~a2bHuddling(:) &  ~a2bIDNo_NaN(:))/NumNonHuddling*1e2)

fprintf('Huddling Data (%d)\n', NumHuddling);
fprintf('Segmentation Error : %d, (%.2f%%)\n', sum(a2bSegErr(:) & a2bHuddling(:)),sum(a2bSegErr(:) & a2bHuddling(:))/NumHuddling*1e2);
fprintf('Correct  ID : %d, (%.2f%%)\n', sum(~a2bSegErr(:) & a2bHuddling(:) &  a2bIDNo_NaN(:)),sum(~a2bSegErr(:) & a2bHuddling(:) &  a2bIDNo_NaN(:))/NumHuddling*1e2)
fprintf('Incorrect  ID : %d, (%.2f%%)\n', sum(~a2bSegErr(:) & a2bHuddling(:) &  ~a2bIDNo_NaN(:)),sum(~a2bSegErr(:) & a2bHuddling(:) &  ~a2bIDNo_NaN(:))/NumHuddling*1e2)

a2bID & ~a2bHuddling
%%






%%

if 1
    acSeqNames = {'b6_popcage_18_09.15.11_10.56.24.135','b6_popcage_18_09.15.11_22.56.24.848','b6_popcage_18_09.17.11_10.56.27.049',...
        'b6_popcage_18_09.17.11_22.56.27.802','b6_popcage_18_09.19.11_10.56.29.998','b6_popcage_18_09.19.11_22.56.30.748'};
    clear strctGT
    strctGT.astrctGT(1) = load('D:\Data\Janelia Farm\GroundTruth\popcage18gt_ashley\Unrandomized\b6_popcage_18_09.15.11_10.56.24.135.mat');
    strctGT.astrctGT(2) = load('D:\Data\Janelia Farm\GroundTruth\popcage18gt_ashley\Unrandomized\b6_popcage_18_09.15.11_22.56.24.848.mat');
    strctGT.astrctGT(3) = load('D:\Data\Janelia Farm\GroundTruth\popcage18gt_ashley\Unrandomized\b6_popcage_18_09.17.11_10.56.27.049.mat');
    strctGT.astrctGT(4) = load('D:\Data\Janelia Farm\GroundTruth\popcage18gt_ashley\Unrandomized\b6_popcage_18_09.17.11_22.56.27.802.mat');
    strctGT.astrctGT(5) = load('D:\Data\Janelia Farm\GroundTruth\popcage18gt_ashley\Unrandomized\b6_popcage_18_09.19.11_10.56.29.998.mat');
    strctGT.astrctGT(6) = load('D:\Data\Janelia Farm\GroundTruth\popcage18gt_ashley\Unrandomized\b6_popcage_18_09.19.11_22.56.30.748.mat');
    
    strFileSeekRoot = 'D:\Data\Janelia Farm\ResultsFromNewTrunk\cage18\SEQ\';
    for iIter=1:6
        % By default, the tracking result is taken from the same version that
        % was used to generate the ground truth data....
        % However, if newer results are available, they can be loaded instead.
        astrctGroundTruth2(iIter) = fnGenereateIdentityErrorPlotLoad(strctGT.astrctGT(iIter),acSeqNames{iIter},'cage18',[], strFileSeekRoot);%,['E:\JaneliaResults\cage11\Results\Tracks\',acSeqNames{iIter},'.mat']) ;
    end
end



for iIter=1:length(astrctGroundTruth2)

    for iMouseIter=1:4
        astrctGroundTruth2(iIter).m_a2bStationary(iMouseIter,:) = a2fVelSmooth(astrctGroundTruth2(iIter).m_aiFramesRelativeToExpStart, iMouseIter) <fStationaryThreshold;
    end
    
    for iMouseIter=1:4
        astrctGroundTruth2(iIter).m_a2bHuddlingData(iMouseIter,:) = ...
            min(a2fDistance(astrctGroundTruth2(iIter).m_aiFramesRelativeToExpStart, a2iMinMouseDist(iMouseIter,:)),[],2) < fHuddlingThreshold &  astrctGroundTruth2(iIter).m_a2bStationary(iMouseIter,:)';
    end
        
    astrctGroundTruth2(iIter).m_a2bCorrectIdentification = fnGenerateIdentityErrorPlotAuxNew(...
        astrctGroundTruth2(iIter).m_astrctCorrectPosition, astrctGroundTruth2(iIter).m_astrctTrackers);
    
end



%% Compare Ashley and Andrew ground truth
clear aiDisagreeOnIdentity  aiDisagreeOnFailSeg aiNumImages
for iIter=1:length(astrctGroundTruth)
  % Find which frames were done by both annotators....
  
    aiSharedFrames = intersect(astrctGroundTruth(iIter).m_aiFrames,    astrctGroundTruth2(iIter).m_aiFrames);
    
    abFrames1 = ismember(astrctGroundTruth(iIter).m_aiFrames,aiSharedFrames);
    abFrames2 = ismember(astrctGroundTruth2(iIter).m_aiFrames,aiSharedFrames);

    aiFrames1 = find(abFrames1);
    aiFrames2 = find(abFrames2);
    
    abFailedSeg1 = isnan(astrctGroundTruth(iIter).m_a2bCorrectIdentification(abFrames1,:));
    abFailedSeg2 = isnan(astrctGroundTruth2(iIter).m_a2bCorrectIdentification(abFrames2,:));

    a2bAgreeOnID = astrctGroundTruth(iIter).m_a2bCorrectIdentification(abFrames1,:) == astrctGroundTruth2(iIter).m_a2bCorrectIdentification(abFrames2,:);
    a2bAgreeOnNotFail = ~abFailedSeg1 & ~abFailedSeg2;
    aiDisagreeOnIdentity(iIter) = sum(~a2bAgreeOnID(:));
    aiDisagreeOnFailSeg(iIter) =  sum(~a2bAgreeOnNotFail(:));
    aiNumImages(iIter) = prod(size(a2bAgreeOnID));
end
1e2*aiDisagreeOnFailSeg / aiNumImages
1e2*aiDisagreeOnIdentity / aiNumImages


sum(aiDisagreeOnIdentity)/sum(aiNumFrames)
sum(aiNotSameFailedSeg)

%%
%astrctGroundTruthAshley = astrctGroundTruth2;
%astrctGroundTruthAndrew = astrctGroundTruth;
%astrctGroundTruth = astrctGroundTruth2;

aiNumFailedFrames = cat(1,astrctGroundTruth.m_iNumFailedSegFrames)';
a2iCumAssignments = [];
a2iCumAssignmentsHuddling = [];

for k=1:length(astrctGroundTruth)
    aiNumCheckedFrames(k) = length(astrctGroundTruth(k).m_aiFrames);
    aiNumHuddling(k) = sum(astrctGroundTruth(k).m_abHuddling );
    aiNumNotHuddling(k) = sum(~astrctGroundTruth(k).m_abHuddling );
    aiNotHuddlingAndFailedSeg(k) = sum(~astrctGroundTruth(k).m_abHuddling & astrctGroundTruth(k).m_abFailedSeg);
    aiHuddlingAndCorrectSeg(k) = sum(astrctGroundTruth(k).m_abHuddling & ~astrctGroundTruth(k).m_abFailedSeg);
    aiHuddlingAndFailedSeg(k) = sum(astrctGroundTruth(k).m_abHuddling & astrctGroundTruth(k).m_abFailedSeg);
    
    [a2iAssignment, a2fNormDistance, afMinPosDistance] = fnGenerateIdentityErrorPlotAux(astrctGroundTruth(k).m_astrctCorrectPosition, astrctGroundTruth(k).m_astrctTrackers, ...
        find(~astrctGroundTruth(k).m_abFailedSeg & ~astrctGroundTruth(k).m_abHuddling));

    [a2iAssignmentHuddling] = fnGenerateIdentityErrorPlotAux(astrctGroundTruth(k).m_astrctCorrectPosition, astrctGroundTruth(k).m_astrctTrackers, ...
        find(~astrctGroundTruth(k).m_abFailedSeg & astrctGroundTruth(k).m_abHuddling));
    
    a2iCumAssignmentsHuddling = [a2iCumAssignmentsHuddling;a2iAssignmentHuddling];
    a2iCumAssignments = [a2iCumAssignments;a2iAssignment];
end

iNumFrames = size(a2iCumAssignments,1);
aiNumWrongAssignments = sum((a2iCumAssignments - repmat([1,2,3,4],iNumFrames,1)) ~= 0,2);
iNumFramesHuddling = size(a2iCumAssignmentsHuddling,1);
aiNumWrongAssignmentsHuddling = sum((a2iCumAssignmentsHuddling - repmat([1,2,3,4],iNumFramesHuddling,1)) ~= 0,2);



aiNumFailedFrames./(aiNumFailedFrames+aiNumCheckedFrames)*1e2

% Final statistics:
fprintf('%d key frames that were annotated\n', sum(aiNumCheckedFrames))

fprintf('- %d(%.2f%%) were labeled by annotator as non-huddling.\n', ...
    sum(aiNumNotHuddling), sum(aiNumNotHuddling)/sum(aiNumCheckedFrames)*100);

fprintf('- Out of the %d non-huddled frames, %d (%.2f%%) were labeled as failed segmentation\n',...
    sum(aiNumNotHuddling), sum(aiNotHuddlingAndFailedSeg), sum(aiNotHuddlingAndFailedSeg)/sum(aiNumNotHuddling)*1e2);


fprintf('- Out of the %d non-huddling key frames with correct segmentation, %d (%.2f%%) had all correct identities\n',...
    length(aiNumWrongAssignments), sum(aiNumWrongAssignments == 0),sum(aiNumWrongAssignments==0)/length(aiNumWrongAssignments)*100);

fprintf('- %d (%.2f%%) had two incorrect identities, %d (%.2f%%) three incorrect idnetities and %d (%.2f%%) were all incorrect\n',...
    sum(aiNumWrongAssignments == 2), sum(aiNumWrongAssignments == 2)/length(aiNumWrongAssignments)*1e2,...
    sum(aiNumWrongAssignments == 3), sum(aiNumWrongAssignments == 3)/length(aiNumWrongAssignments)*1e2,...
    sum(aiNumWrongAssignments == 4), sum(aiNumWrongAssignments == 4)/length(aiNumWrongAssignments)*1e2);

fprintf('- Alternatively, out of %d annotated mice images, %d (%.2f%%) were correctly identified\n',...
    length(aiNumWrongAssignments)*4, ...
(sum(aiNumWrongAssignments==0)*4+sum(aiNumWrongAssignments==2)*2+sum(aiNumWrongAssignments==3)*1),...
1e2*(sum(aiNumWrongAssignments==0)*4+sum(aiNumWrongAssignments==2)*2+sum(aiNumWrongAssignments==3)*1)/(length(aiNumWrongAssignments)*4));

fprintf('****\n');
fprintf('- %d (%.2f%%) were labeled by annotator as huddling.\n', ...
    sum(aiNumHuddling), sum(aiNumHuddling)/sum(aiNumCheckedFrames)*100);

fprintf('Out of the %d huddling key frames, %d (%.2f%%) were labeled as incorrect segmentation\n',...
    sum(aiNumHuddling), sum(aiHuddlingAndFailedSeg),sum(aiHuddlingAndFailedSeg)/sum(aiNumHuddling)*100);

fprintf('Out of the %d huddling key frames that were correctly segmented, %d (%.2f%%) also had correct identities\n',...
    length(aiNumWrongAssignmentsHuddling), sum(aiNumWrongAssignmentsHuddling == 0), sum(aiNumWrongAssignmentsHuddling == 0)/length(aiNumWrongAssignmentsHuddling)*1e2);

fprintf('Alternatively, out of %d huddled mice images, %d (%.2f%%) were correctly identified\n',...
    length(aiNumWrongAssignmentsHuddling)*4, ...
(sum(aiNumWrongAssignmentsHuddling==0)*4+sum(aiNumWrongAssignmentsHuddling==2)*2+sum(aiNumWrongAssignmentsHuddling==3)*1),...
1e2*(sum(aiNumWrongAssignmentsHuddling==0)*4+sum(aiNumWrongAssignmentsHuddling==2)*2+sum(aiNumWrongAssignmentsHuddling==3)*1)/(length(aiNumWrongAssignmentsHuddling)*4));

%%




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
figure(16);
clf;
abHuddling = (afCumMinPosDist < 35);
sum(aiNumWrongAssignments == 0)/  iNumFrames * 1e2

title('All');
subplot(1,2,1);
hist(aiNumWrongAssignments(abHuddling))
title('While Huddling');
subplot(1,2,2);
hist(aiNumWrongAssignments(~abHuddling))
title('Not Huddling');



%%
a2fColors = fnGetFancyColors();

a2fTS = [];
for k=1:length(astrctGroundTruth)
    aiSubInd = [1;find(diff(astrctGroundTruth(k).m_aiFrames) > 10*300); length(astrctGroundTruth(k).m_aiFrames)];
    for j=1:length(aiSubInd)-1
        fprintf('Interval: %d - %d\n',astrctGroundTruth(k).m_aiFrames(aiSubInd(j)+1),astrctGroundTruth(k).m_aiFrames(aiSubInd(j+1)));
        a2fTS = [a2fTS; astrctGroundTruth(k).m_afTimestamps(aiSubInd(j)+1),astrctGroundTruth(k).m_afTimestamps(aiSubInd(j+1))];
    end;
    
end

a2fTimeMin = round(a2fTS/60);


figure(20);
clf;hold on;
% Draw Days (dark, light)
for iDayIter=0:4
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

afAnnotationColor = [0,0,0]/255;

for k=1:size(a2fTimeMin,1)
    x = a2fTimeMin(k,1);
    y = 0;
    h = 1;
    w = a2fTimeMin(k,2)-a2fTimeMin(k,1);
    if w > 0
        rectangle('Position',[x,y,w,h],'facecolor',afAnnotationColor,'edgecolor','none');
    end
end
set(gca,'ytick',[]);
set(gca,'xtick',[0:12:145]*60);
set(gca,'xticklabel',{'0',   '12'  , '24'  , '36'   ,'48' , '60'   ,'72' ,'84'  ,'96'  ,'108'  ,'120'  ,'132','140'});
set(gca,'xlim',[0 120]*60);	
xlabel('Hours');

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





%% Compare asheley and andrew
strctGT_Andrew.astrctGT(1) = load('D:\Data\Janelia Farm\GroundTruth\popcage18gt_andrew\Unrandom\b6_popcage_18_09.15.11_10.56.24.135.mat');
strctGT_Andrew.astrctGT(2) = load('D:\Data\Janelia Farm\GroundTruth\popcage18gt_andrew\Unrandom\b6_popcage_18_09.15.11_22.56.24.848.mat');
strctGT_Andrew.astrctGT(3) = load('D:\Data\Janelia Farm\GroundTruth\popcage18gt_andrew\Unrandom\b6_popcage_18_09.17.11_10.56.27.049.mat');

strctGT_Ahsley.astrctGT(1) = load('D:\Data\Janelia Farm\GroundTruth\popcage18gt_ashley\Unrandomized\b6_popcage_18_09.15.11_10.56.24.135.mat');
strctGT_Ahsley.astrctGT(2) = load('D:\Data\Janelia Farm\GroundTruth\popcage18gt_ashley\Unrandomized\b6_popcage_18_09.15.11_22.56.24.848.mat');
strctGT_Ahsley.astrctGT(3) = load('D:\Data\Janelia Farm\GroundTruth\popcage18gt_ashley\Unrandomized\b6_popcage_18_09.17.11_10.56.27.049.mat');

iNumMismatch = 0;
iNumTotal = 0;
for iIter=1:3
    a2iAndrew = cat(1,strctGT_Andrew.astrctGT(iIter).astrctGT.m_aiPerm);
    a2iAshley= cat(1,strctGT_Ahsley.astrctGT(iIter).astrctGT.m_aiPerm);
    aiAnnotatedByBoth = find(sum(a2iAndrew,2) > 0 & sum(a2iAshley,2) > 0);
    iNumTotal = iNumTotal + length(aiAnnotatedByBoth);
    iNumMismatch=iNumMismatch+sum(sum(a2iAndrew(aiAnnotatedByBoth,:)  ==a2iAshley(aiAnnotatedByBoth,:),2) ~= 4);
end

fprintf('Percent inconsistent between two annotators: %.2f\n',iNumMismatch/3988 *1e2);
