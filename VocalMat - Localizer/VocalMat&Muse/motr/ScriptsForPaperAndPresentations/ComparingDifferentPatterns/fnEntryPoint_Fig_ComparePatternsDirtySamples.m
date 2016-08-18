function fnEntryPoint_Fig_ComparePatternsDirtySamples()

% Use 10,000 frames from cage 16 to test classifier's
% performance...

% 1. Read "Ground truth" (i.e., Viterbi's output, hoping it is correct...)
strctData = load('D:\Data\Janelia Farm\ResultsFromNewTrunk\cage16_array.mat');
strctMovInfo = fnReadSeqInfo('D:\Data\Janelia Farm\Movies\cage16\b6_popcage_16_110405_09.58.30.268.seq');

aiFrameInterval = 40000:50000-1;%30000:40000-1; % Skip the first 10k frames. Only two mice are present.
iNumMice = 4;
iNumFrames = length(aiFrameInterval);
iHOG_Dim = 837;
        fImagePatchHeight = 51;
    fImagePatchWidth = 111;
iNumBins = 10;
a3fFeatures = zeros(iNumFrames,iNumMice, iHOG_Dim,'single');

for iFrameIter=1:30:length(aiFrameInterval)
    if mod(iFrameIter,100)==0
        fprintf('%d out of %d\n',iFrameIter,length(aiFrameInterval));
    end
    iCurrentFrame = aiFrameInterval(iFrameIter);
    a2iFrame = fnReadFrameFromSeq(strctMovInfo,iCurrentFrame);
    % extract patches
    a3iRectified = ones(fImagePatchHeight,fImagePatchWidth, iNumMice,'uint8');
    
    for iMouseIter=1:iNumMice
        if ~isnan(strctData.astrctTrackers(iMouseIter).m_afX(iCurrentFrame))
            a3iRectified(:,:,iMouseIter) = fnRectifyPatch(single(a2iFrame), ...
                strctData.astrctTrackers(iMouseIter).m_afX(iCurrentFrame),...
                strctData.astrctTrackers(iMouseIter).m_afY(iCurrentFrame),...
                strctData.astrctTrackers(iMouseIter).m_afTheta(iCurrentFrame));
            
             Tmp = fnHOGfeatures(a3iRectified(:,:,iMouseIter),iNumBins);
            a3fFeatures(iFrameIter,iMouseIter,:) = Tmp(:);
        end;
    end;
    
    a2fDist = zeros(4,4);
    for i=1:4
        for j=1:4
                a2fDist(i,j)=sqrt( (strctData.astrctTrackers(i).m_afX(iCurrentFrame)-strctData.astrctTrackers(j).m_afX(iCurrentFrame)).^2+...
                (strctData.astrctTrackers(i).m_afY(iCurrentFrame)-strctData.astrctTrackers(j).m_afY(iCurrentFrame)).^2);
        end
    end
    
    
    a2fDist(eye(4)==1) = NaN;
    [aiI,aiJ]=find(a2fDist > 200);
    if ~isempty(aiI)
        figure(11);
        clf;
        imagesc(a3iRectified(:,:,aiI(1)));
        colormap gray
        axis equal
        axis off
        set(gcf,'position',[  1385         943         169         127]);
        dbg = 1;
        
    end;
    
end
save('D:\Data\Janelia Farm\Final_Data_For_Paper\DifferentPatternsPlot\a3fFeatures_4Mice_Cage16_10kFrames.mat','a3fFeatures');


% %% Now train classifier
% acAvailFiles = {...
%     'D:\Data\Janelia Farm\Final_Data_For_Paper\DifferentPatternsPlot\b6_popcage_16_singles_dg\Identities.mat',...
%     'D:\Data\Janelia Farm\Final_Data_For_Paper\DifferentPatternsPlot\b6_popcage_16_singles_hs\Identities.mat',...
%     'D:\Data\Janelia Farm\Final_Data_For_Paper\DifferentPatternsPlot\b6_popcage_16_singles_sp\Identities.mat',...
%     'D:\Data\Janelia Farm\Final_Data_For_Paper\DifferentPatternsPlot\b6_popcage_16_singles_vs\Identities.mat'};
% 
%     
%     for iIdentityIter= 1 : 4
%         fprintf('CV %d, Training %d out of %d\n', iSetIter,iIdentityIter,iNumIdentities);
%         [aiTrainingPos,  aiTraininNeg] = fnComputeSetsIndices(aiStart,aiEnd, iIdentityIter, iSetIter, K);
%         [astrctClassifierPos(iIdentityIter),astrctTrainingPlots(iIdentityIter),...
%             astrctClassifierNeg(iIdentityIter)] = fnTrainTdistClassifier(a2fFeatures(aiTrainingPos,:),...
%             a2fFeatures(aiTraininNeg,:));
%     end
% 
% load('D:\Data\Janelia Farm\Final_Data_For_Paper\DifferentPatternsPlot\a3fFeatures_4Mice_Cage16_10kFrames.mat','a3fFeatures');

