function fnEntryPoint_Fig_ComparePatterns
% This script reads a bunch of identity files containing HOF features and
% image patches and generates the figure for the paper showing
% classification performance as a function of different patterns
%
% The second part of the script generates the figure which compares the
% performance of classifier on a video of the same mice taken a month
% later.

%aiSelectedPatterns =[ 28   8    19    23    24    7    21       29    30    32];
% acAvailFiles = {...
% 'D:\Data\Janelia Farm\Results\b6_pop_cage_14_vs\Identities.mat',...
% 'D:\Data\Janelia Farm\Results\new_bleach_marks_stripes_2_antpost_horiz\Identities.mat',...
% 'D:\Data\Janelia Farm\Results\new_bleach_marks_stripes_2midvert\Identities.mat',...
% 'D:\Data\Janelia Farm\Results\new_bleach_marks_stripes_2post_horiz\Identities.mat',...
% 'D:\Data\Janelia Farm\Results\new_bleach_marks_stripes_3_antmidpost_horiz\Identities.mat',...
% 'D:\Data\Janelia Farm\Results\new_bleach_marks_stripes_3_midvert\Identities.mat',...
% 'D:\Data\Janelia Farm\Results\single_black_female_2\Identities.mat',...
% 'D:\Data\Janelia Farm\Results\single_mouse_100607_diagstripe1\Identities.mat',...
% 'D:\Data\Janelia Farm\Results\single_mouse_100607_dots5\Identities.mat',...
% 'D:\Data\Janelia Farm\Results\single_mouse_100607_vertstripe2\Identities.mat'};
if 0
acAvailFiles = {...
    'D:\Data\Janelia Farm\Final_Data_For_Paper\DifferentPatternsPlot\b6_popcage_16_singles_dg\Identities.mat',...
    'D:\Data\Janelia Farm\Final_Data_For_Paper\DifferentPatternsPlot\b6_popcage_16_singles_hs\Identities.mat',...
    'D:\Data\Janelia Farm\Final_Data_For_Paper\DifferentPatternsPlot\b6_popcage_16_singles_sp\Identities.mat',...
    'D:\Data\Janelia Farm\Final_Data_For_Paper\DifferentPatternsPlot\b6_popcage_16_singles_vs\Identities.mat'};
fnEntryPoint_Fig_ComparePatternsAux(acAvailFiles,true)

end
acAvailFiles = {...
    'D:\Data\Janelia Farm\Final_Data_For_Paper\DifferentPatternsPlot\b6_popcage_16_singles_dg\Identities.mat',...
    'D:\Data\Janelia Farm\Final_Data_For_Paper\DifferentPatternsPlot\b6_popcage_16_singles_hs\Identities.mat',...
    'D:\Data\Janelia Farm\Final_Data_For_Paper\DifferentPatternsPlot\b6_popcage_16_singles_sp\Identities.mat',...
    'D:\Data\Janelia Farm\Final_Data_For_Paper\DifferentPatternsPlot\b6_popcage_16_singles_vs\Identities.mat',...
'D:\Data\Janelia Farm\Results\new_bleach_marks_stripes_2_antpost_horiz\Identities.mat',...
'D:\Data\Janelia Farm\Results\new_bleach_marks_stripes_2midvert\Identities.mat',...
'D:\Data\Janelia Farm\Results\new_bleach_marks_stripes_2post_horiz\Identities.mat',...
'D:\Data\Janelia Farm\Results\new_bleach_marks_stripes_3_antmidpost_horiz\Identities.mat',...
'D:\Data\Janelia Farm\Results\new_bleach_marks_stripes_3_midvert\Identities.mat',...
'D:\Data\Janelia Farm\Final_Data_For_Paper\DifferentPatternsPlot\roian_unmarked_single_21-03-25.974\Identities.mat'};


fnEntryPoint_Fig_ComparePatternsAux(acAvailFiles,false)


function fnEntryPoint_Fig_ComparePatternsAux(acAvailFiles,bRunOnDirtySamples)

% Global parameters
if 0 %exist('D:\Data\Janelia Farm\Final_Data_For_Paper\DifferentPatternsPlot\DataCache.mat','file')
    load('D:\Data\Janelia Farm\Final_Data_For_Paper\DifferentPatternsPlot\DataCache.mat')
else
    
    iMaxSamplesPerMouse = 10000;
    fGoodTrainingSampleMinA  = 20;
    fGoodTrainingSampleMinB = 10;
    fImagePatchHeight = 51;
    fImagePatchWidth = 111;
    iHOG_Dim = 837;
    
    %
    
    
    % 1. find all identity files...
    if 0
    strResultsFolder = 'D:\Data\Janelia Farm\Results';
    acDirs = parsedirs(genpath(strResultsFolder));
    iCounter = 1;
    for k=1:length(acDirs)
        if exist([acDirs{k}(1:end-1),'\Identities.mat'],'file')
            acAvailFiles{iCounter} = [acDirs{k}(1:end-1),'\Identities.mat'];
            iCounter=iCounter+1;
        end
    end
        [aiSelectedID,v] = listdlg('PromptString','Select Identities:','SelectionMode','multiple','ListString',acAvailFiles,'ListSize',[700,300]);
    iNumMice = length(aiSelectedID);
    else
        iNumMice = length(acAvailFiles);
        aiSelectedID=1:iNumMice;
    end
    % Allow use to select which ones to run on
    % Read data from each ID
    
    a3fRepresentativePatch = zeros(fImagePatchHeight,fImagePatchWidth, iNumMice);
    aiStart = zeros(1, iNumMice);
    aiEnd = zeros(1, iNumMice);
    a2fFeatures = zeros(iMaxSamplesPerMouse*iNumMice, iHOG_Dim,'single');

    aiStartBad = zeros(1, iNumMice);
    aiEndBad = zeros(1, iNumMice);
    a2fFeaturesBad = zeros(iMaxSamplesPerMouse*iNumMice, iHOG_Dim,'single');

    
    aiStart(1) = 1;
    aiStartBad(1) = 1;
    for iIter=1:iNumMice
        fprintf('Reading %d out of %d\n',iIter,iNumMice);
        strctTmp = load( acAvailFiles{aiSelectedID(iIter)});
        aiGoodExemplars = find(strctTmp.strctIdentity.m_afA > fGoodTrainingSampleMinA & ...
            strctTmp.strctIdentity.m_afB > fGoodTrainingSampleMinB);
        aiBadExemplars = find(strctTmp.strctIdentity.m_afA < fGoodTrainingSampleMinA | ...
            strctTmp.strctIdentity.m_afB < fGoodTrainingSampleMinB);
        
        % Pick Random examplars....
        aiRandPerm = randperm(length(aiGoodExemplars));
        aiGoodExemplars = aiGoodExemplars(aiRandPerm);
        
        aiRandPermBad = randperm(length(aiBadExemplars));
        aiBadExemplars = aiBadExemplars(aiRandPermBad);
        
        
        % Extract representative patch
        [fDummy,iIndex]=min(abs(strctTmp.strctIdentity.m_afA-median(strctTmp.strctIdentity.m_afA))+...
            abs(strctTmp.strctIdentity.m_afB-median(strctTmp.strctIdentity.m_afB))    );
        
        a3fRepresentativePatch(:,:,iIter) = strctTmp.strctIdentity.m_a3iPatches(1:51,1:111,iIndex);
        
        iNumSamplesTaken = min(length(aiGoodExemplars), iMaxSamplesPerMouse);
        aiEnd(iIter) = aiStart(iIter) + iNumSamplesTaken-1 ;
        if iIter ~= iNumMice
            aiStart(iIter+1) = aiEnd(iIter) + 1;
        end;

        iNumSamplesTakenBad = min(length(aiBadExemplars), iMaxSamplesPerMouse);
        aiEndBad(iIter) = aiStartBad(iIter) + iNumSamplesTakenBad-1 ;
        if iIter ~= iNumMice
            aiStartBad(iIter+1) = aiEndBad(iIter) + 1;
        end;

        
        a2fFeatures(aiStart(iIter):aiEnd(iIter),:) = strctTmp.strctIdentity.m_a3fHOGFeatures(aiGoodExemplars(1:iNumSamplesTaken),:);
        a2fFeaturesBad(aiStartBad(iIter):aiEndBad(iIter),:) = strctTmp.strctIdentity.m_a3fHOGFeatures(aiBadExemplars(1:iNumSamplesTakenBad),:);
    end
    
    if aiEnd(iNumMice) < iMaxSamplesPerMouse*iNumMice
        a2fFeatures=a2fFeatures( 1:aiEnd(iNumMice),:);
    end

    if aiEndBad(iNumMice) < iMaxSamplesPerMouse*iNumMice
        a2fFeaturesBad=a2fFeaturesBad( 1:aiEndBad(iNumMice),:);
    end
    
    clear strctTmp aiGoodExemplars
    save('D:\Data\Janelia Farm\Final_Data_For_Paper\DifferentPatternsPlot\DataCache');
end

%% Display 

% Selected patterns for paper are;


% for k=1:length(aiSelectedPatterns)
%     figure(k);
%     fprintf('%d  %s\n',k,acAvailFiles{aiSelectedPatterns(k)});
%     %tightsubplot(2,5,k);
%     imagesc(a3fRepresentativePatch(:,:,aiSelectedPatterns(k)));
%     set(gca,'visible','off');
%     axis equal
%     colormap gray
% 
% end;
% 
figure(101);clf;
for k=1:length(acAvailFiles)
    fprintf('%d  %s\n',k,acAvailFiles{(k)});
    tightsubplot(2,5,k);
    imagesc(a3fRepresentativePatch(:,:,(k)));
    set(gca,'visible','off');
    hold on;
%     text(1,20,sprintf('%d',k));
    axis equal
    colormap gray

end;
% 
% 
%     figure(100);
% clf;
% for k=1:38
%     
%     tightsubplot(6,7,k);
%     imagesc(a3fRepresentativePatch(:,:,(k)));
%     set(gca,'visible','off');
%     axis equal
%     colormap gray
% 
% end;

%% Train on all data
   iNumIdentities = iNumMice;
   strctTmp = load('D:\Data\Janelia Farm\Final_Data_For_Paper\DifferentPatternsPlot\a3fFeatures_4Mice_Cage16_10kFrames.mat');

if bRunOnDirtySamples
    for iIdentityIter= 1 : iNumIdentities
        fprintf('Training using all data %d out of %d\n', iIdentityIter,iNumIdentities);
        [aiTrainingPos,  aiTraininNeg] = fnComputeSetsIndices(aiStart,aiEnd, iIdentityIter, 1, 1);
        [astrctClassifierPos_AllSamples(iIdentityIter),astrctTrainingPlots_AllSamples(iIdentityIter), astrctClassifierNeg_AllSamples(iIdentityIter)] = ...
            fnTrainTdistClassifier(a2fFeatures(aiTrainingPos,:), a2fFeatures(aiTraininNeg,:));
    end

    a2fPerformance = zeros(iNumMice,iNumMice);
    for iTrueID=1:iNumMice
        a2fTrueIDFeatures = squeeze(strctTmp.a3fFeatures(:,iTrueID,:));
        % Count Hits:
        afProbPos = fnApplyTDist(astrctClassifierPos_AllSamples(iTrueID),a2fTrueIDFeatures);
        afProbNeg = fnApplyTDist(astrctClassifierNeg_AllSamples(iTrueID),a2fTrueIDFeatures);
        fHitRate = sum(afProbPos*(1/iNumMice) > afProbNeg * (iNumMice-1)/iNumMice)/length(afProbPos);
        a2fPerformance(iTrueID,iTrueID)=fHitRate;
        for iPredID=setdiff(1:iNumMice,iTrueID)
            % Count false alarms...
            a2fTrueIDFeatures = squeeze(strctTmp.a3fFeatures(:,iPredID,:));
            % Count Hits:
            afProbPos = fnApplyTDist(astrctClassifierPos_AllSamples(iTrueID),a2fTrueIDFeatures);
            afProbNeg = fnApplyTDist(astrctClassifierNeg_AllSamples(iTrueID),a2fTrueIDFeatures);
            fFalseAlarmRate = sum(afProbPos*(1/iNumMice) > afProbNeg * (iNumMice-1)/iNumMice)/length(afProbPos);
            a2fPerformance(iTrueID,iPredID)=fFalseAlarmRate;
        end
    end
    set(gcf,'position',[680   935   188   163]);
end
    
%%
% Run Cross Validation
if 0
 [a2fConfusionMatrixTestingSet_Avg, fSingleScore] = fnComparePatternsAux(aiStart,aiEnd,a2fFeatures);
 
figure(4);clf;
imagesc(a2fConfusionMatrixTestingSet_Avg);
colormap(hot)
% colorbar
set(gca,'xtick',1:iNumIdentities,'ytick',1:iNumIdentities)
colorbar
end




% Now, run subsets to generate the auxiliary figure...
a2iAllMouseHex = nchoosek(1:10,6);
iNumHex= size(a2iAllMouseHex,1);
afMeanScore = zeros(1,iNumHex);
afStdScore = zeros(1,iNumHex);
for iIter=1:iNumHex
    fprintf('Hex %d out of %d\n',iIter,iNumHex);
    aiSelectedMice =a2iAllMouseHex( iIter,:);
    aiSelectedInt = [aiStart(aiSelectedMice(1)):aiEnd(aiSelectedMice(1)),aiStart(aiSelectedMice(2)):aiEnd(aiSelectedMice(2)),aiStart(aiSelectedMice(3)):aiEnd(aiSelectedMice(3)),aiStart(aiSelectedMice(4)):aiEnd(aiSelectedMice(4)),aiStart(aiSelectedMice(5)):aiEnd(aiSelectedMice(5)),aiStart(aiSelectedMice(6)):aiEnd(aiSelectedMice(6))];
     [a2fTest, c(iIter),afStdScore(iIter)] = fnComparePatternsAux([1 10001 20001 30001 40001 50001],[10000 20000 30000 40000 50000 60000],a2fFeatures(aiSelectedInt,:));
end
save('SixMouseBestPatterns','a2iAllMouseHex','a2iAllMouseHex','afStdScore');
% Build the binary map...
a2bMap = zeros(10,iNumHex);
for k=1:iNumHex
    a2bMap(a2iAllMouseHex(k,:),k) = 1;
end
dbg = 1;
[afScoreSorted, aiInd]=sort(afMeanScore);
figure(11);
clf; hold on;
%plot(afScoreSorted,'b','linewidth',2);
fnFancyPlot2(1:210,afScoreSorted, afStdScore(aiInd)/12,[0 0 255]/255,[0 0 100]/255);
set(gca,'xlim',[1 210]);
figure(13);
clf;
imagesc(a2bMap(:,aiInd(1:10)));
set(gca,'ytick',1:10)
colormap gray

a2iMouseHexSorted = a2iAllMouseHex(aiInd,:);
abNotIncludingTen = ~(sum(a2iMouseHexSorted == 10,2)>0);

a2iBestPatternWithout10 = a2iMouseHexSorted(abNotIncludingTen,:);

a2bMapNo10 = zeros(10, sum(abNotIncludingTen));
for k=1:sum(abNotIncludingTen)
    a2bMapNo10(a2iBestPatternWithout10(k,:),k) = 1;
end
figure(14);
clf;
imagesc(a2bMapNo10(:,(1:10)));
set(gca,'ytick',1:10)
colormap gray


%%


% Now, run subsets to generate the auxiliary figure...
a2iAllMouseQuads = nchoosek(1:10,4);
iNumQuad = size(a2iAllMouseQuads,1);
afMeanScore = zeros(1,iNumQuad);
afStdScore = zeros(1,iNumQuad);
for iIter=1:iNumQuad
    fprintf('Quad %d out of %d\n',iIter,iNumQuad);
    aiSelectedMice =a2iAllMouseQuads( iIter,:);
    aiSelectedInt = [aiStart(aiSelectedMice(1)):aiEnd(aiSelectedMice(1)),aiStart(aiSelectedMice(2)):aiEnd(aiSelectedMice(2)),aiStart(aiSelectedMice(3)):aiEnd(aiSelectedMice(3)),aiStart(aiSelectedMice(4)):aiEnd(aiSelectedMice(4))];
     [a2fTest, afMeanScore(iIter),afStdScore(iIter)] = fnComparePatternsAux([1 10001 20001 30001],[10000 20000 30000 40000],a2fFeatures(aiSelectedInt,:));
end
save('D:\Data\Janelia Farm\Final_Data_For_Paper\DifferentPatternsPlot\DataCache_All_Permutations.mat','afMeanScore','afStdScore','a2iAllMouseQuads');

% Build the binary map...
a2bMap = zeros(10,210);
for k=1:210
    a2bMap(a2iAllMouseQuads(k,:),k) = 1;
end

dbg = 1;
[afScoreSorted, aiInd]=sort(afMeanScore);
figure(11);
clf; hold on;
%plot(afScoreSorted,'b','linewidth',2);
fnFancyPlot2(1:210,afScoreSorted, afStdScore(aiInd)/12,[0 0 255]/255,[0 0 100]/255);
set(gca,'xlim',[1 210]);

figure(12);
clf; hold on;
%plot(afScoreSorted,'b','linewidth',2);
fnFancyPlot2(1:210,afScoreSorted, afStdScore(aiInd)/12,[0 0 255]/255,[0 0 100]/255);
set(gca,'xlim',[1 10])

figure(13);
clf;
imagesc(a2bMap(:,aiInd(1:10)));
set(gca,'ytick',1:10)
colormap gray

find(aiInd==1)


%% And if we discard non marked mouse?

abInvalid = a2iAllMouseQuads(:,1) == 10 |  a2iAllMouseQuads(:,2) == 10 | a2iAllMouseQuads(:,3) == 10 | a2iAllMouseQuads(:,4) == 10 ;
afScoreNoTen = afMeanScore(~abInvalid);
aiValid = find(~abInvalid);

[~, aiIndNoTen]=sort(afScoreNoTen);
find(aiValid(aiIndNoTen) == 1)
109/126

figure;plot(afScoreSorted(~abInvalid ))
aiInd(~abInvalid ) 

aiInd(aiInd(~abInvalid ) == 1)
[afScoreSorted, aiInd]=sort(afMeanScore);
