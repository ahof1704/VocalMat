% for k=1:12
%     fprintf('%d \n ',k);
%     astrctGT(k) = load(['D:\Data\Janelia Farm\GroundTruth\SagerFull\GroundTruth_seg',num2str(k),'_complete_UnRandomized.mat']);
% end
%save('D:\Data\Janelia Farm\GroundTruth\SagerFull\AllSagerGT_UnRandomized','astrctGT');
load('D:\Data\Janelia Farm\GroundTruth\SagerFull\AllSagerGT_UnRandomized');


acSequences = {'10.04.19.390','10.04.19.390','10.04.19.390','22.04.20.265',...
               '10.04.22.843','10.04.22.843','10.04.22.843','10.04.22.843',...
               '10.04.26.468','10.04.26.468','10.04.26.468','22.04.27.312'};
           
% 
% seg1=day 1, 10.04.19.390, frames 540000:648000 - 79%
% seg2=day 1, 10.04.19.390, frames 216000:324000 - 98% (12:04 - 13:04, 15:04-16:04, 20:00-21:00, 01:00-02:00
% seg3=day 1, 10.04.19.390, frames 1080000:1188000 - 77%
% seg4, day 1, 22.04.20.265, frames 324000:432000 - 70%
% 
% seg5, day 3, 10.04.22.843, frames 972000:1080000 - 70%
% seg6, day 3, 10.04.22.843, frames 324000:432000 - 92% (13:00-14:00,  14:00-15:00, 19:00-20:00, 04:00-05:00)
% seg7, day 3, 10.04.22.843, frames 432000:540000 - 97 %
% seg8, day 3, 22.04.23.796, frames 648000:756000 - 93 %
% 
% seg9, day 5, 10.04.26.468, frames 756000:864000 - 80%
% seg10, day 5, 10.04.26.468, frames 972000:1080000 - 83 % (17:00-18:00, 19:00-20:00, 20:00-21:00, 05:00-06:00)
% seg11, day 5, 10.04.26.468, frames 1080000:1188000 - 96 %
% seg12, day 5, 22.04.27.312, frames 756000:864000 - 23 % ?




strctBack = load('D:\Data\Janelia Farm\Results\10.04.19.390\Background.mat');
a2bMicrophones = imopen(strctBack.strctBackground.m_a2fMedian<0.65 & strctBack.strctBackground.m_a2bFloor,ones(3,3));
a2fDistToMicrophones =bwdist(a2bMicrophones);

if 0
a2bTubeRegion = a2bTubeRegion | roipoly(strctBack.strctBackground.m_a2fMedian);
save('Exp1Tubes','a2bTubeRegion');
else
load('Exp1Tubes');
    
end


iNumSubset = 11;

% iNeighborhood = 500;
% fStationaryThres = 10;
% fCloseTogetherThres = 25;

fProximityThresholdPix = 100;
fProximityToMic = 40;

iTotalFailedSeg = 0;
iTotalFramesChecked = 0;
iTotalFramesCorrect = 0;
aiNumIncorrect = zeros(1,4);
iIncorrectButStationaryAndClose = 0;
iIncorrectButMicrophone = 0;

acCorrectInd = cell(1,iNumSubset);
acIncorrectInd = cell(1,iNumSubset);
afPerformanceAll = zeros(1,iNumSubset);
afPerformanceM4 = zeros(1,iNumSubset);
afPerformanceM3 = zeros(1,iNumSubset);
afPerformanceM = zeros(1,iNumSubset);
afPerformanceTube = zeros(1,iNumSubset);
for iIter=1:iNumSubset
    a2iPerms = cat(1,astrctGT(iIter).astrctGT.m_aiPerm);
    iNumKeyFrames = size(a2iPerms,1);
    abNotChecked = zeros(1,iNumKeyFrames)>0;
    abFailedSeg = zeros(1,iNumKeyFrames)>0;
    abCorrect = zeros(1,iNumKeyFrames)>0;
    abFullyMarked = zeros(1,iNumKeyFrames)>0;

    for j=1:iNumKeyFrames
        abNotChecked(j) = strcmp(astrctGT(iIter).astrctGT(j).m_strDescr,'Not Checked');
        abFailedSeg(j) = strcmp(astrctGT(iIter).astrctGT(j).m_strDescr,'Failed Seg');
        abCorrect(j) = all(astrctGT(iIter).astrctGT(j).m_aiPerm == [1,2,3,4]);
        abFullyMarked(j) = all(astrctGT(iIter).astrctGT(j).m_aiPerm > 0);
    end;
    abChecked = ~abNotChecked;
    
    
    abIncorrect = abChecked & ~abFailedSeg & ~abCorrect & abFullyMarked;
        
    acCorrectInd{iIter} = find(abCorrect);
    acIncorrectInd{iIter} = find(abIncorrect);
    
    iStartInterval = find(~abNotChecked,1,'first');
    iEndInterval = find(~abNotChecked,1,'last');
    % Only key frames between start and end were actually labeled.
    aiInterval = iStartInterval:iEndInterval;

    aiIncorrectKeyFrames = find(abIncorrect);
    % Finer analysis of incorrect frames
    iNumIncorrect = length(aiIncorrectKeyFrames);
    
    abTube = zeros(1,iNumIncorrect);
    abMicrophone = zeros(1,iNumIncorrect);
    abClusterTwo = zeros(1,iNumIncorrect);
    abClusterThree = zeros(1,iNumIncorrect);
    abClusterFour = zeros(1,iNumIncorrect);
    for iIncorrectIter=1:length(aiIncorrectKeyFrames)
        iKeyFrame = aiIncorrectKeyFrames(iIncorrectIter);
        iActualFrame =  astrctGT(iIter).astrctGT(iKeyFrame).m_iFrame;
        iNumInCorrect = sum(astrctGT(iIter).astrctGT(iKeyFrame).m_aiPerm ~= [1,2,3,4]);
        aiNumIncorrect(iNumInCorrect) = aiNumIncorrect(iNumInCorrect) + 1;
        
        
        
        %abActive = 
        
        a2fDist = inf*ones(4,4);
        for i=1:4
            for j=setdiff(1:4,i)
                a2fDist(i,j) =sqrt((astrctGT(iIter).astrctTrackers(i).m_afX(iActualFrame)-astrctGT(iIter).astrctTrackers(j).m_afX(iActualFrame)).^2+...
                              (astrctGT(iIter).astrctTrackers(i).m_afY(iActualFrame)-astrctGT(iIter).astrctTrackers(j).m_afY(iActualFrame)).^2);
            end
        end
        
        if sum(min(a2fDist,[],1) < fProximityThresholdPix) == 2
            abClusterTwo(iIncorrectIter) = 1;
        elseif sum(min(a2fDist,[],1) < fProximityThresholdPix) == 3
            abClusterThree(iIncorrectIter) = 1;
        elseif sum(min(a2fDist,[],1) < fProximityThresholdPix) == 4
            abClusterFour(iIncorrectIter) = 1;
        end    
        
        if all(min(a2fDist,[],1) < fProximityThresholdPix)
            iIncorrectButStationaryAndClose =iIncorrectButStationaryAndClose+1;
        end
        
        aiIncorrectPerm = astrctGT(iIter).astrctGT(iKeyFrame).m_aiPerm;
        aiIncorrectID = find(astrctGT(iIter).astrctGT(iKeyFrame).m_aiPerm ~= [1,2,3,4]);
        afDistToMicrophone = zeros(1,length(aiIncorrectID));
        abInTube = zeros(1,length(aiIncorrectID));
        for iMouseIter=1:length(aiIncorrectID)
            iTracker = aiIncorrectID(iMouseIter);
            abInTube(iMouseIter) = a2bTubeRegion(round(astrctGT(iIter).astrctTrackers(iTracker).m_afY(iActualFrame)),...
                round(astrctGT(iIter).astrctTrackers(iTracker).m_afX(iActualFrame)));
            
            afDistToMicrophone(iMouseIter) = a2fDistToMicrophones(round(astrctGT(iIter).astrctTrackers(iTracker).m_afY(iActualFrame)),...
                round(astrctGT(iIter).astrctTrackers(iTracker).m_afX(iActualFrame)));
        end
        abTube(iIncorrectIter) = sum(abInTube) > 0;
        if min(afDistToMicrophone) < fProximityToMic
            abMicrophone(iIncorrectIter) = true;
            iIncorrectButMicrophone = iIncorrectButMicrophone + 1;
        end
        
%        abCloseAndStationary = zeros(1,length(aiIncorrectID)) > 0;
%         for iMouseIter=1:length(aiIncorrectID)
%             
%             iTracker = aiIncorrectID(iMouseIter);
%             iIncorrectID = find(aiIncorrectPerm == iTracker);
%             if isempty(iIncorrectID)
%                 continue;
%             end
%             
%             % Is iTracker Stationary ?
%             aiSmallInterval = iActualFrame-iNeighborhood:iActualFrame+iNeighborhood;
%             
%             bTrackerStationary = ...
%                 max(sqrt((astrctGT(iIter).astrctTrackers(iTracker).m_afX(aiSmallInterval) - astrctGT(iIter).astrctTrackers(iTracker).m_afX(iActualFrame)).^2 + ...
%                          (astrctGT(iIter).astrctTrackers(iTracker).m_afY(aiSmallInterval) - astrctGT(iIter).astrctTrackers(iTracker).m_afY(iActualFrame)).^2)) < fStationaryThres;
%             
%             bOtherIdentityStationary = ...
%                 max(sqrt((astrctGT(iIter).astrctTrackers(iIncorrectID).m_afX(aiSmallInterval) - astrctGT(iIter).astrctTrackers(iIncorrectID).m_afX(iActualFrame)).^2 + ...
%                          (astrctGT(iIter).astrctTrackers(iIncorrectID).m_afY(aiSmallInterval) - astrctGT(iIter).astrctTrackers(iIncorrectID).m_afY(iActualFrame)).^2)) < fStationaryThres;
%             
%             bTrackerCloseToIncorrectID =  ...
%                 sqrt((astrctGT(iIter).astrctTrackers(iIncorrectID).m_afX(iActualFrame) - astrctGT(iIter).astrctTrackers(iTracker).m_afX(iActualFrame)).^2+...
%                      (astrctGT(iIter).astrctTrackers(iIncorrectID).m_afY(iActualFrame) - astrctGT(iIter).astrctTrackers(iTracker).m_afY(iActualFrame)).^2) < fCloseTogetherThres;
%             
%             abCloseAndStationary(iMouseIter) = bTrackerStationary && bOtherIdentityStationary && bTrackerCloseToIncorrectID;
%         end
        
    end
    afPerformanceAll(iIter) = sum(abCorrect(aiInterval)) / sum(abChecked(aiInterval))  * 1e2;
    afPerformanceTube(iIter) = (sum(abCorrect(aiInterval)) + sum(abMicrophone) )/ sum(abChecked(aiInterval))  * 1e2;
    
    afPerformanceM4(iIter) = (sum(abCorrect(aiInterval)) + sum(abClusterFour) )/ sum(abChecked(aiInterval))  * 1e2;
    afPerformanceM3(iIter) = (sum(abCorrect(aiInterval)) + sum(abClusterThree|abClusterFour) )/ sum(abChecked(aiInterval))  * 1e2;
    afPerformanceM(iIter) = (sum(abCorrect(aiInterval)) + sum(abClusterThree|abClusterFour|abMicrophone) )/ sum(abChecked(aiInterval))  * 1e2;
    fprintf('Seq %d - %.2f Perc Correct, all frames\n', iIter,afPerformanceAll(iIter));
    fprintf('Seq %d - %.2f Perc Correct, dropping 4 clusters\n', iIter, afPerformanceM4(iIter));
    fprintf('Seq %d - %.2f Perc Correct, dropping 3&4 clusters\n', iIter,afPerformanceM3(iIter));
    iTotalFramesChecked = iTotalFramesChecked + sum(abChecked(aiInterval));
    iTotalFailedSeg = iTotalFailedSeg + sum(abFailedSeg(aiInterval));
    iTotalFramesCorrect = iTotalFramesCorrect + sum(abCorrect(aiInterval));
   
end
figure(11);clf;
plot(1:iNumSubset,afPerformanceAll,1:iNumSubset,afPerformanceM,   1:iNumSubset,afPerformanceM3,1:iNumSubset,afPerformanceM4,1:iNumSubset,afPerformanceTube,'LineWidth',2);
legend('All Key Frames','Ignoring 3&4-Cluster &Microphone','Ignoring 3&4-Cluster','Ignoring 4 Cluster','Ignoring Tubes');
xlabel('12 Hour Sequence Number');
ylabel('Percent Correct (i.e. all IDs are correct)');

iTotalFramesIncorrect = iTotalFramesChecked-iTotalFailedSeg-iTotalFramesCorrect;

fprintf('%d Frames (%.2f hours) were checked\n',iTotalFramesChecked,iTotalFramesChecked*150 / 30 / 60 / 60);
fprintf('%d (%.2f %%) Frames were labeled as Failed Segmentation \n',iTotalFailedSeg, iTotalFailedSeg/iTotalFramesChecked*1e2);
fprintf('The statistics for the remaining %d Frames: \n',iTotalFramesChecked-iTotalFailedSeg)
fprintf('%d (%.2f %%) were marked as correct \n',iTotalFramesCorrect, iTotalFramesCorrect/(iTotalFramesChecked-iTotalFailedSeg)*1e2); 
fprintf('Incorrect frames %d (%.2f %%)\n',iTotalFramesIncorrect, iTotalFramesIncorrect/(iTotalFramesChecked-iTotalFailedSeg)*1e2);
fprintf('Out of which, %d were when all mice were close together\n',iIncorrectButStationaryAndClose);
fprintf('The remaining %d incorrect frames:\n',iTotalFramesIncorrect);
for k=2:4
    fprintf('%d Identity Swaps : %d (%.2f %%) \n',k,aiNumIncorrect(k), aiNumIncorrect(k)/iTotalFramesIncorrect*100)
end
fprintf('Microphone errors: %d\n',iIncorrectButMicrophone);






%% Classifier likelihood for "correct"
iNumMice = 4;
iNumBins = 10;
strctClassifier = load('D:\Data\Janelia Farm\Identities\LDA_Logistic_Exp1.mat');

afLogLikelihoodCorrect = [];
afLogLikelihoodIncorrect = [];
for iIter=1:iNumSubset
    strctMovInf = fnReadVideoInfo(['M:\Data\Movies\Experiment1\',acSequences{iIter},'.seq']);
    
    iNumCorrect = length(acCorrectInd{iIter});
    fprintf('Correct Ind for Seq %d, (%d)\n',iIter,iNumCorrect);
    a2fProbCorrect = zeros(iNumCorrect,4);
    for iCorrectIter=1:iNumCorrect
        iKeyFrame = acCorrectInd{iIter}(iCorrectIter);
        iActualFrame = astrctGT(iIter).astrctGT(iKeyFrame).m_iFrame;
       
        a2iFrame = fnReadFrameFromSeq(strctMovInf, iActualFrame);
        a3iRectified  = fnCollectRectifiedMice2(a2iFrame, astrctGT(iIter).astrctTrackers, iActualFrame);

        afProb = zeros(1,iNumMice);
        for iMouseIter=1:iNumMice
            Tmp = fnHOGfeatures(a3iRectified(:,:,iMouseIter),iNumBins);
            afFeatures = Tmp(:);
            a2fProbCorrect(iCorrectIter,iMouseIter) = fnApplyLDALogistic(strctClassifier.strctIdentityClassifier.m_astrctClassifiers(iMouseIter),afFeatures');
        end

%         
%         figure(10);
%         clf;
%         imshow(a2iFrame);hold on;
%         fnDrawTrackers4(astrctGT(iIter).astrctTrackers, iActualFrame, gca);
%         
    end
    afLogLikelihoodCorrect = [afLogLikelihoodCorrect;sum(log(a2fProbCorrect),2);];

    
    
    iNumIncorrect = length(acIncorrectInd{iIter});
    fprintf('Incorrect Ind for Seq %d, (%d)\n',iIter,iNumIncorrect);
    a2fProbIncorrect = zeros(iNumIncorrect,4);
    for iIncorrectIter=1:iNumIncorrect
        iKeyFrame = acIncorrectInd{iIter}(iIncorrectIter);
        iActualFrame = astrctGT(iIter).astrctGT(iKeyFrame).m_iFrame;
       
        a2iFrame = fnReadFrameFromSeq(strctMovInf, iActualFrame);
        a3iRectified  = fnCollectRectifiedMice2(a2iFrame, astrctGT(iIter).astrctTrackers, iActualFrame);

        afProb = zeros(1,iNumMice);
        for iMouseIter=1:iNumMice
            Tmp = fnHOGfeatures(a3iRectified(:,:,iMouseIter),iNumBins);
            afFeatures = Tmp(:);
            a2fProbIncorrect(iIncorrectIter,iMouseIter) = fnApplyLDALogistic(strctClassifier.strctIdentityClassifier.m_astrctClassifiers(iMouseIter),afFeatures');
        end
    end
    afLogLikelihoodIncorrect = [afLogLikelihoodIncorrect;sum(log(a2fProbIncorrect),2);];
     
end

[afHistCorrect, afCentCorrect] = hist(afLogLikelihoodCorrect,100);
[afHistIncorrect, afCentIncorrect] = hist(afLogLikelihoodIncorrect,100);
figure(11);
clf;hold on;
bar(afCentCorrect, afHistCorrect,'facecolor','b');
bar(afCentIncorrect, afHistIncorrect,'facecolor','r');
xlabel('Log Likelihood');
ylabel('Key frame count');
legend({'Correct Key Frames','Incorrect Key Frames'});



for iIter=1:iNumSubset
    Tmp = randperm(length(acCorrectInd{iIter}));
    aiSelectedKeyFrames = sort(acCorrectInd{iIter}(Tmp(1:9)));
    fprintf('Sequence %s, GT %d \n',acSequences{iIter},iIter);
    aiSelectedKeyFrames
end


for iIter=1:iNumSubset
    Tmp = randperm(length(acIncorrectInd{iIter}));
    aiSelectedKeyFrames = sort(acIncorrectInd{iIter}(Tmp(1:9)));
    fprintf('Sequence %s, GT %d \n',acSequences{iIter},iIter);
    aiSelectedKeyFrames
end


%% 

%TODO: Verify 100 samples from correct and from incorrect. 

%% TODO


% Can we divide up the wrongly labeled frames into different situations:
% 1. Mislabeled mice stationary and apart
% 2. Mislabeled mice stationary and close
% 3. Mislabeled ice moving and apart
% 4. Mislabeled mice moving and close


% 
% fprintf('%d key frames not checked\n',sum(abNotChecked));
% fprintf('%d key frames checked\n',sum(abChecked));
% fprintf('   - Out of those : %d were fully marked\n',sum(abCheckedAndMarkedAll))
% fprintf('       - Out of those : %d were correct\n',sum(abCheckedCorrect))
% fprintf('\n');
% fprintf('Incorrect keyframes according to annotator:\n');
% 
% for k=1:length(aiIncorrectKeyFrames)
%     fprintf('Key frame %5d (frame %5d)\n',aiIncorrectKeyFrames(k),strctGT.astrctGT(aiIncorrectKeyFrames(k)).m_iFrame);
% end
% 

% 721 key frames checked
%    - Out of those : 715 were fully marked
%        - Out of those : 565 were correct

% 724 key frames checked
%    - Out of those : 724 were fully marked
%        - Out of those : 713 were correct
% 
% 
% 432000/150
% 
% seg1=day 1, 10.04.19.390, frames 540000:648000 - 79%
% seg2=day 1, 10.04.19.390, frames 216000:324000 - 98% (12:04 - 13:04, 15:04-16:04, 20:00-21:00, 01:00-02:00
% seg3=day 1, 10.04.19.390, frames 1080000:1188000 - 77%
% seg4, day 1, 22.04.20.265, frames 324000:432000 - 70%
% 
% seg5, day 3, 10.04.22.843, frames 972000:1080000 - 70%
% seg6, day 3, 10.04.22.843, frames 324000:432000 - 92% (13:00-14:00,  14:00-15:00, 19:00-20:00, 04:00-05:00)
% seg7, day 3, 10.04.22.843, frames 432000:540000 - 97 %
% seg8, day 3, 10.04.22.843, frames 648000:756000 - 93 %
% 
% seg9, day 5, 10.04.26.468, frames 756000:864000 - 80%
% seg10, day 5, 10.04.26.468, frames 972000:1080000 - 83 % (17:00-18:00, 19:00-20:00, 20:00-21:00, 05:00-06:00)
% seg11, day 5, 10.04.26.468, frames 1080000:1188000 - 96 %
% seg12, day 5, 22.04.27.312, frames 756000:864000 - 23 % ?

% Check for inconsistencies

if 0
strctGT1 = load('D:\Data\Janelia Farm\GroundTruth\SagerFull\GroundTruth_seg1_complete_UnRandomized.mat');
strctGT2 = load('D:\Data\Janelia Farm\GroundTruth\SagerFull\GroundTruth_seg1_redo_UnRandomized.mat');

a2iPerm1 = cat(1,strctGT1.astrctGT.m_aiPerm);
a2iPerm2 = cat(1,strctGT2.astrctGT.m_aiPerm);

aiInconsistent = find(sum(a2iPerm1 ~= a2iPerm2,2));

sum(a2iPerm1(:,1) > 0)
sum(a2iPerm1(:,2) > 0)

length(aiInconsistent)

[a2iPerm1(aiInconsistent,:), a2iPerm2(aiInconsistent,:)]
end