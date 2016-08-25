function fnTuneBackgroundFromScratch(strctInfo, strctID, strOutputFolder)
%%
%
fnLog('In fnTuneBackgroundFromScratch');
iNumFrames = strctInfo.m_iNumFrames;
iNumSamples = min(30, ceil((iNumFrames-1)/2));
iNumBatchSize = round(iNumSamples^0.6);
iStep = max(1,floor(iNumFrames/iNumSamples/4));
aiFrames = iStep:iStep:iNumFrames;
randSampleIndices = floor(length(aiFrames)*rand(1,10000))+1;

% Choose first sample
iRandStartPtr = 1;
iRandEndPtr = iNumBatchSize;
aiRandBatch = randSampleIndices(iRandStartPtr:iRandEndPtr);
fMean = zeros(1,iNumBatchSize);
for i=1:iNumBatchSize
   a2fIm = fnReadFrameFromVideo(strctInfo, aiFrames(aiRandBatch(i)));
   fMean(i) = mean(a2fIm(:));
end
[fMinMean, iMinMean] = min(fMean);
aiSamples = aiRandBatch(iMinMean);
a2fIm = double(fnReadFrameFromVideo(strctInfo, aiFrames(aiSamples)))/255;
fnLog(sprintf('Chose frame %d for first sample form the batch of frames: %s', ...
              aiFrames(aiSamples), ...
              sprintf('%d,',aiFrames(aiRandBatch))), ...
      1, ...
      a2fIm);
a2fMinIm = a2fIm;
a3fImMed = zeros(size(a2fIm,1),size(a2fIm,2),iNumSamples);
a3fImMed(:,:,1) = a2fMinIm;
% Choose the rest of the samples
for k=2:2*iNumSamples-1
   iRandStartPtr = iRandStartPtr + iNumBatchSize;
   iRandEndPtr = iRandEndPtr + iNumBatchSize - 1;
   aiRandBatch = [];
   while length(aiRandBatch)<iNumBatchSize
      iRandEndPtr = iRandEndPtr + 1;
      aiRandBatch = setdiff(randSampleIndices(iRandStartPtr:iRandEndPtr), ...
                            aiSamples);
   end
   afMean = zeros(1,length(aiRandBatch));
   % Fixed by SO (09/Nov/2011)
   % Changed to a maximum heuristic instead of minimum
   a3fTemp =  zeros(size(a2fIm,1),size(a2fIm,2),length(aiRandBatch));
   for i=1:length(aiRandBatch)
      a3fTemp(:,:,i) = double(fnReadFrameFromVideo(strctInfo, ...
                                                   aiFrames(aiRandBatch(i))))/255;
      a2fTmp = max(a2fMinIm,a3fTemp(:,:,i));
      afMean(i) = mean(a2fTmp (:));
   end
   [fMinMean, iMinMean] = max(afMean);
   a2fMinIm = max(a2fMinIm,  a3fTemp(:,:,iMinMean));
   
   if mod(k,2)==1
      fnLog(sprintf('Chose frame %d for %dth sample form the batch of frames: %s', ...
                    aiFrames(aiRandBatch(iMinMean)), ...
                    (k+1)/2, ...
                    sprintf('%d,',aiFrames(aiRandBatch))), ...
            1, ...
            a2fIm);
      aiSamples = [aiSamples aiRandBatch(iMinMean)];
      if k<=100
         a3fImMed(:,:,(k+1)/2) = a3fTemp(:,:,iMinMean);
      end
   else
      fnLog(sprintf(['Chose frame %d for sample form the batch of frames: ' ...
                     '%s but discarded it, so to make room for less dark samples'], ...
                    aiFrames(aiRandBatch(iMinMean)), ...
                    sprintf('%d,',aiFrames(aiRandBatch))), ...
            1, ...
            a2fIm);
   end
end
%%
fprintf('Calculating median over %d sample frames...', size(a3fImMed, 3));
strctAdditionalInfo.strctBackground.m_a2fMedian = median(a3fImMed, 3);
fnLog(['Calculated median over ' num2str(size(a3fImMed, 3)) ' samples'], ...
      1, ...
      strctAdditionalInfo.strctBackground.m_a2fMedian);
fprintf('Done.\n');
global g_strMouseStuffRootDirName;
segParamsFN= ...
  fullfile(g_strMouseStuffRootDirName,'Config','defaultSegmentationParams.mat');
if exist(segParamsFN,'file')
    load(segParamsFN);  % puts strctSegParams in namespace
else
  % Load the default default segmentation parameters.
  strDefaultDefaultSegmentationParamsFileName= ...
    fullfile(g_strMouseStuffRootDirName,'Config', ...
             'DefaultDefaultSegmentationParams.xml');
  strctSegParams= ...
    fnLoadDefaultDefaultSegmentationParamsXML( ...
      strDefaultDefaultSegmentationParamsFileName);
%     strctSegParams.iLargestSeparationDueToLightAndMarkingPix =  10;
%     strctSegParams.fLargeMotionThreshold =0.2000;
%     strctSegParams.iSmallestMouseRadiusPix =  11;
%     strctSegParams.fMinimalMinorAxes =  5;
%     strctSegParams.fIntensityThrOut= 0.4500;
%     strctSegParams.fIntensityThrIn  = 0.9000;
%     strctSegParams.iGoodCCopenSize = 5;
%     strctSegParams.aiAxisBounds = [8 26 15 63];  % ALT 2011/10/20,
%                                                  % got value from a
%                                                  % copy of
%                                                  % defaultSegmentationParams.mat
%                                                  % somewhere
    % Store them in a .mat so we can get at them quicker next time.
    save(segParamsFN,'strctSegParams');
end
strctAdditionalInfo.strctBackground.m_strctSegParams = strctSegParams;
strctAdditionalInfo.strctBackground.m_strMethod = 'FrameDiff_v7';
strctAdditionalInfo.strctMovieInfo = strctInfo;
strctAdditionalInfo.strctAppearance.m_iNumBins = 10;
strctAdditionalInfo.strctAppearance.m_a2fFeatures = ...
  strctID.a2fAppearanceFeatures;
iNumMice = length(strctID.strctIdentityClassifier.m_astrctClassifiers);
fnLog(['Calling TuneSegmentstionGUI with sample frames ' ...
       num2str(aiFrames(aiSamples))]);
astrctSampleFrames = TuneSegmentationGUI(iNumMice, ...
                                         strOutputFolder, ...
                                         strctAdditionalInfo, ...
                                         aiFrames(aiSamples));

end

