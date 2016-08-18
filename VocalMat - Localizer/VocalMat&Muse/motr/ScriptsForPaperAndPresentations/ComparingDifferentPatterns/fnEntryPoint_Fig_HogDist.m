
strctMovInfo=fnReadVideoInfo('D:\Data\Janelia Farm\Movies\ExpG\b6_pop_cage_14_12.02.10_09.52.04.882_cropped_5000-54999.seq');
strctResult = load('D:\Data\Janelia Farm\ResultsTdist\b6_pop_cage_14_12.02.10_09.52.04.882_cropped_5000-54999\SequenceViterbi.mat');
iNumMice = 4;

a4iRectified = ones(51,111,4,strctMovInfo.m_iNumFrames,'uint8');
for iFrameIndex=1:strctMovInfo.m_iNumFrames
    if mod(iFrameIndex,100) == 0
        fprintf('%d out of %d\n',iFrameIndex,strctMovInfo.m_iNumFrames);
    end
    a2iFrame=fnReadFrameFromSeq(strctMovInfo,iFrameIndex);
    a3iRectified = ones(51,111,4,'uint8');
    for iMouseIter=1:iNumMice
        if ~isnan(strctResult.astrctTrackers(iMouseIter).m_afX(iFrameIndex))
            a4iRectified(:,:,iMouseIter,iFrameIndex) =  fnRectifyPatch(single(a2iFrame), ...
                strctResult.astrctTrackers(iMouseIter).m_afX(iFrameIndex),...
                strctResult.astrctTrackers(iMouseIter).m_afY(iFrameIndex),...
                strctResult.astrctTrackers(iMouseIter).m_afTheta(iFrameIndex));
        end;
    end;
end
save('a4iRectified','a4iRectified');
%%
figure(10);
clf;
for f=1:5000
for k=1:4
subplot(2,2,k);
imshow(a4iRectified(:,:,k,f),[]);
end

drawnow
end
%%
a3fFeatures = zeros(iHOG_Dim,iNumMice,strctMovInfo.m_iNumFrames,'single');
for iFrameIndex=1:strctMovInfo.m_iNumFrames
   for iMouseIter=1:iNumMice
    % Apply identity classifiers on image patch
    Tmp = fnHOGfeatures(a4iRectified(:,:,iMouseIter,iFrameIndex), 10);
    a3fFeatures(:,iMouseIter,iFrameIndex) = Tmp(:);
   end
end
save('a3fFeatures','a3fFeatures');

    for iClassifierIter=1:iNumMice
        a2fRes =...
        fnApplyTDist(strctAdditionalInfo.m_strctMiceIdentityClassifier.m_astrctClassifiers(iClassifierIter), afFeatures');
    end

%%
  a2fConfusionMatrixTestingSet=zeros(4,4);
    for iTrueID = 1:iNumIdentities
        a2fFeaturesID = squeeze(a3fFeatures(:,iTrueID,:))';
         for iPredID = 1:iNumIdentities
             
             
             
            afProbTestingPos = fnApplyTDist(astrctClassifierPos(iPredID),a2fFeaturesID);
            afProbTestingNeg = fnApplyTDist(astrctClassifierNeg(iPredID),a2fFeaturesID);

                      
            % Decision...
            % We want to test that Pr(Mouse A|x), vs. Pr( ~MouseA | x)
            % Pr(Mouse A | x) = Pr(x|A)*Pr(A)/Pr(x)
            % Pr(~Mouse A | x) = Pr(x|~A)*Pr(~A)/Pr(x)
            % To mak the decision, we can discard Pr(x). It will be equal            % in both
            % The Apply T dist will give us Prob(x|A) or prob(x|~A)
            % so we still need to multiple by Pr(A) = 1/iNumMice
            % and Pr(~A) = (iNumMice-1)/iNumMice
              iCorrectDecisionTesting = sum(afProbTestingPos*(1/iNumMice) > afProbTestingNeg * (iNumMice-1)/iNumMice);
            a2fConfusionMatrixTestingSet(iTrueID,iPredID) =  iCorrectDecisionTesting/size(a2fFeaturesID,1);
        end
    end

figure(2);clf;
set(2,'Position',[1     1   294   176])
imagesc(a2fConfusionMatrixTestingSet([1,2,3,4],:));
colormap(hot)
colorbar
set(gca,'xtick',1:4,'ytick',1:4)

a2fSorted =a2fConfusionMatrixTestingSet([1,4,3,2],:);
figure(3);clf;
set(3,'Position',[1     1   294   176])
imagesc(a2fSorted);
colormap(hot)
colorbar
set(gca,'xtick',1:4,'ytick',1:4)
mean(diag(a2fSorted)), std(diag(a2fSorted))
%[0.886,0.095]
mean(a2fSorted( ~eye(4))), std(a2fSorted( ~eye(4)))
%[0.028, 0.023]

mean(diag(a2fConfusionMatrixTestingSet)), std(diag(a2fConfusionMatrixTestingSet))
%[0.966, 0.01]
mean(a2fConfusionMatrixTestingSet( ~eye(4))), std(a2fConfusionMatrixTestingSet( ~eye(4))), 
[0.007, 0.005]

acNames = {'TP single','TP group','FP single','FP group'};
afX = 1:4,
afY = [0.966,0.886, 0.007   ,0.028]
afS = [0.01, 0.095,  0.005 0.023];
figure(4);clf;hold on;
barh(afX(1:2),afY(1:2),'facecolor',[79,129,189]/255)
barh(afX(3:4),afY(3:4),'facecolor',[192,80,77]/255);
for k=1:length(afX)
    plot([afY(k)-afS(k),afY(k)+afS(k)],[afX(k) afX(k)],'k','Linewidth',2);
end
set(gca,'yticklabel',[])
set(gca,'xtick',afX);

xticklabel_rotate
hold on;
plot([1 1],[
ahHandles(1) = bar(a2iSigRatio(:,1),'facecolor',[79,129,189]/255);
ahHandles(2) = bar(-a2iSigRatio(:,2),'facecolor',[192,80,77]/255);

%%

% This script reads a bunch of identity files containing HOF features and
% image patches and generates the figure for the paper showing
% classification performance as a function of different patterns
%
% The second part of the script generates the figure which compares the
% performance of classifier on a video of the same mice taken a month
% later.

%aiSelectedPatterns =[ 28   8    19    23    24    7    21       29    30    32];
acAvailFiles = {...
'D:\Data\Janelia Farm\MouseHouseExperiments\ExpG\Tuning\b6_pop_cage_14_dg\Identities.mat',...
'D:\Data\Janelia Farm\MouseHouseExperiments\ExpG\Tuning\b6_pop_cage_14_vs\Identities.mat',...
'D:\Data\Janelia Farm\MouseHouseExperiments\ExpG\Tuning\b6_pop_cage_14_sp\Identities.mat',...
'D:\Data\Janelia Farm\MouseHouseExperiments\ExpG\Tuning\b6_pop_cage_14_hs\Identities.mat'

};
    iMaxSamplesPerMouse = 10000;
    fGoodTrainingSampleMinA  = 20;
    fGoodTrainingSampleMinB = 10;
    fImagePatchHeight = 51;
    fImagePatchWidth = 111;
    iHOG_Dim = 837;
    
    %
    
    
    % 1. find all identity files...
       iNumMice = length(acAvailFiles);
        aiSelectedID=1:iNumMice;
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
    
  
%% Display 

% Selected patterns for paper are;



%%
% Run Cross Validation
K = 4;
iNumIdentities = iNumMice;

a2fConfusionMatrixTrainingSet_Avg = zeros(iNumIdentities,iNumIdentities);
a2fConfusionMatrixTestingSet_Avg = zeros(iNumIdentities,iNumIdentities);

for iSetIter = 1 : K
    fprintf('Cross Validation Set %d out of %d \n',iSetIter,K);
    drawnow update
    
    for iIdentityIter= 1 : iNumIdentities
        fprintf('CV %d, Training %d out of %d\n', iSetIter,iIdentityIter,iNumIdentities);
        [aiTrainingPos,  aiTraininNeg] = fnComputeSetsIndices(aiStart,aiEnd, iIdentityIter, iSetIter, K);
        [astrctClassifierPos(iIdentityIter),astrctTrainingPlots(iIdentityIter),...
            astrctClassifierNeg(iIdentityIter)] = fnTrainTdistClassifier(a2fFeatures(aiTrainingPos,:),...
            a2fFeatures(aiTraininNeg,:));
    end
    % Evaluation on test and training sets...
    a2fConfusionMatrixTrainingSet = zeros(iNumIdentities,iNumIdentities);
    a2fConfusionMatrixTestingSet = zeros(iNumIdentities,iNumIdentities);
    
    for iTrueID = 1:iNumIdentities
       [aiTrainingPos,  aiTraininNeg, aiTestingPos] = fnComputeSetsIndices(aiStart,aiEnd, iTrueID, iSetIter, K);
        for iPredID = 1:iNumIdentities
            
            afProbTrainingPos = fnApplyTDist(astrctClassifierPos(iPredID),a2fFeatures(aiTrainingPos,:));
            afProbTestingPos = fnApplyTDist(astrctClassifierPos(iPredID),a2fFeatures(aiTestingPos,:));
            afProbTrainingNeg = fnApplyTDist(astrctClassifierNeg(iPredID),a2fFeatures(aiTrainingPos,:));
            afProbTestingNeg = fnApplyTDist(astrctClassifierNeg(iPredID),a2fFeatures(aiTestingPos,:));

            aiBadPos = aiStartBad(iPredID):aiEndBad(iPredID);
            afProbTestingBadPos = fnApplyTDist(astrctClassifierPos(iPredID),a2fFeaturesBad(aiBadPos,:));
            afProbTestingBadNeg = fnApplyTDist(astrctClassifierNeg(iPredID),a2fFeaturesBad(aiBadPos,:));
            
            % Decision...
            % We want to test that Pr(Mouse A|x), vs. Pr( ~MouseA | x)
            % Pr(Mouse A | x) = Pr(x|A)*Pr(A)/Pr(x)
            % Pr(~Mouse A | x) = Pr(x|~A)*Pr(~A)/Pr(x)
            % To mak the decision, we can discard Pr(x). It will be equal            % in both
            % The Apply T dist will give us Prob(x|A) or prob(x|~A)
            % so we still need to multiple by Pr(A) = 1/iNumMice
            % and Pr(~A) = (iNumMice-1)/iNumMice
            iCorrectDecisionTraining = sum(afProbTrainingPos*(1/iNumMice) > afProbTrainingNeg * (iNumMice-1)/iNumMice);
            iCorrectDecisionTesting = sum(afProbTestingPos*(1/iNumMice) > afProbTestingNeg * (iNumMice-1)/iNumMice);
            
            iCorrectDecisionTestingBad = sum(afProbTestingBadPos*(1/iNumMice) > afProbTestingBadNeg * (iNumMice-1)/iNumMice);
                        
            a2fConfusionMatrixTrainingSet(iTrueID,iPredID) = iCorrectDecisionTraining/length(aiTrainingPos);
            a2fConfusionMatrixTestingSet(iTrueID,iPredID) =  iCorrectDecisionTesting/length(aiTestingPos);
            a2fConfusionMatrixTestingSetBad(iTrueID,iPredID) =  iCorrectDecisionTestingBad/length(aiBadPos);
            
        end
    end
    % normalize each row 
    a2fConfusionMatrixTrainingSet_Avg = a2fConfusionMatrixTrainingSet_Avg + a2fConfusionMatrixTrainingSet;
    a2fConfusionMatrixTestingSet_Avg =a2fConfusionMatrixTestingSet_Avg + a2fConfusionMatrixTestingSet ;
    a2fConfusionMatrixTestingSetBad_Avg= a2fConfusionMatrixTestingSetBad_Avg+a2fConfusionMatrixTestingSetBad;
end;
a2fConfusionMatrixTrainingSet_Avg = a2fConfusionMatrixTrainingSet_Avg / K;
a2fConfusionMatrixTestingSet_Avg = a2fConfusionMatrixTestingSet_Avg / K;
a2fConfusionMatrixTestingSetBad_Avg=a2fConfusionMatrixTestingSetBad_Avg/K;



figure(2);clf;
imagesc(a2fConfusionMatrixTestingSet_Avg);
colormap(hot)
colorbar
set(gca,'xtick',1:4,'ytick',1:4)


