
strctInfo = fnReadVideoInfo('E:\JaneliaData\cage14\ExperimentClips\\b6_pop_cage_14_12.02.10_09.52.04.882.seq');
%%
%
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
a2fMinIm = a2fIm;
a3fImMed = zeros(size(a2fIm,1),size(a2fIm,2),iNumSamples);
a3fImMed(:,:,1) = a2fMinIm;

figure(11);
clf;

iNumBatchSize = 4;
tightsubplot(5,6, 6);
imshow(a2fIm,[]);
% Choose the rest of the samples
for k=1:4
    iRandStartPtr = iRandStartPtr + iNumBatchSize;
    iRandEndPtr = iRandEndPtr + iNumBatchSize - 1;
    aiRandBatch = [];
    while length(aiRandBatch)<iNumBatchSize
        iRandEndPtr = iRandEndPtr + 1;
        aiRandBatch = setdiff(randSampleIndices(iRandStartPtr:iRandEndPtr), aiSamples);
    end
    aiRandBatch = aiRandBatch(1:iNumBatchSize);
    afMean = zeros(1,length(aiRandBatch));
    % Fixed by SO (06/Sep/2011)
    % Minimum was not computed correctly!
    a3fTemp =  zeros(size(a2fIm,1),size(a2fIm,2),length(aiRandBatch));
    for i=1:length(aiRandBatch)
        a3fTemp(:,:,i) = double(fnReadFrameFromVideo(strctInfo, aiFrames(aiRandBatch(i))))/255;
        a2fTmp = min(a2fMinIm,a3fTemp(:,:,i));
        afMean(i) = mean(a2fTmp (:));
        
        tightsubplot(5,6, (k)*6+i);
        imshow( a3fTemp(:,:,i));
    end
    [fMinMean, iMinMean] = min(afMean);
    
        tightsubplot(5,6, (k)*6+iMinMean);
        hold on;
        rectangle('position',[0.5 0.5 1024 768],'edgecolor',[1 0 0],'LineWidth',3);

    
    a2fMinIm = min(a2fMinIm,  a3fTemp(:,:,iMinMean));
    
      tightsubplot(5,6, (k)*6+6);
      imshow(a2fMinIm,[])
     
    aiSamples = [aiSamples aiRandBatch(iMinMean)];
    a3fImMed(:,:,k) = a3fTemp(:,:,iMinMean);
end