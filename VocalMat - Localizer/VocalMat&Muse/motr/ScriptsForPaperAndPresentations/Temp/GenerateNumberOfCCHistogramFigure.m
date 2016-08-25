load('SolveUsingConstrainedEMDebug');
strctMovInfo = fnReadVideoInfo('E:\JaneliaData\cage14\ExperimentClips\\b6_pop_cage_14_12.02.10_09.52.04.882.seq');

iNumFramesInHistogram = 10000;
aiSampledFrames = round(linspace(1,strctMovInfo.m_iNumFrames,iNumFramesInHistogram));
aiNumBlobs = zeros(1,length(aiSampledFrames));
for iFrameIter=1:length(aiSampledFrames)
    fprintf('%d out of %d\n',iFrameIter,length(aiSampledFrames));
    a2iFrame = fnReadFrameFromVideo(strctMovInfo, aiSampledFrames(iFrameIter));
    [a2iLForeground,aiNumBlobs(iFrameIter)] = fnSegmentForeground2(double(a2iFrame)/255, strctAdditionalInfo);
end

[aiHist,aiCent]=hist(aiNumBlobs,1:5);
figure;
clf;
bar(aiCent,log10(strctMovInfo.m_iNumFrames/iNumFramesInHistogram *aiHist))
xlabel('Number of components');
ylabel('log10 (# frames)');
save('NumberofCCinSeqCage14_882','aiNumBlobs','aiSampledFrames');

%%
strctMovInfo = fnReadVideoInfo('E:\JaneliaData\cage14\ExperimentClips\b6_pop_cage_14_12.02.10_21.52.06.570.seq');

iNumFramesInHistogram = 10000;
aiSampledFrames = round(linspace(1,strctMovInfo.m_iNumFrames,iNumFramesInHistogram));
aiNumBlobsNight = zeros(1,length(aiSampledFrames));

for iFrameIter=1:length(aiSampledFrames)
    fprintf('%d out of %d\n',iFrameIter,length(aiSampledFrames));
    a2iFrame = fnReadFrameFromVideo(strctMovInfo, aiSampledFrames(iFrameIter));
    [a2iLForeground,aiNumBlobsNight(iFrameIter)] = fnSegmentForeground2(double(a2iFrame)/255, strctAdditionalInfo);
end

[aiHistNight,aiCentNight]=hist(aiNumBlobsNight,1:5);
figure;
clf;
bar(aiCentNight,log10(130*aiHistNight))
xlabel('Number of components');
ylabel('log10 (# frames)');
save('NumberofCCinSeqCage14_570','aiNumBlobsNight','aiSampledFrames');
