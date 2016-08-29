% Script to generate the mice images in the six mice video
strVideoName = 'D:\Data\Janelia Farm\Movies\6Mice\six_mice_15.41.17.171.seq';
strResultsFile = 'D:\Data\Janelia Farm\Results\six_mice_15.41.17.171\SequenceViterbi.mat';

iNumFramesToSample = 1400;

iSampleIntervalSec = 12*60*60 / iNumFramesToSample;

strctMov = fnReadVideoInfo(strVideoName);
iNumFrames = strctMov .m_iNumFrames;
% Sample every X frame
aiFrameNumbers = round(linspace(1,iNumFrames,iNumFramesToSample));

strctTrackingData = load(strResultsFile);
iNumMice = length(strctTrackingData.astrctTrackers);

a4iRectified = ones(iNumFramesToSample,51,111, iNumMice,'uint8');

for iFrameIter=1:iNumFramesToSample
    iFrameIndex = aiFrameNumbers(iFrameIter);
    fprintf('Reading %d/%d\n',iFrameIter,iNumFramesToSample);
    a2iFrame = fnReadFrameFromSeq(strctMov,iFrameIndex);
    for iMouseIter=1:iNumMice
        if ~isnan(strctTrackingData.astrctTrackers(iMouseIter).m_afX(iFrameIndex))
            a4iRectified(iFrameIter,:,:,iMouseIter) = fnRectifyPatch(single(a2iFrame), ...
                strctTrackingData.astrctTrackers(iMouseIter).m_afX(iFrameIndex),...
                strctTrackingData.astrctTrackers(iMouseIter).m_afY(iFrameIndex),...
                strctTrackingData.astrctTrackers(iMouseIter).m_afTheta(iFrameIndex));
        end;
    end;
end
    
save('Patches','a4iRectified','aiFrameNumbers','strVideoName','strResultsFile');

if 0

%% Show
iSubsetSize = 5;
for iFrameIter=1:iSubsetSize :iNumFramesToSample
    aiFrameSubset = iFrameIter+[0:iSubsetSize-1];
    figure(2);
    clf;
    for iSubsetIter=1:iSubsetSize
        
        for k=1:iNumMice
            tightsubplot(iSubsetSize,iNumMice,(iSubsetIter-1)*iNumMice+k,'Spacing',0.05);
            imagesc(squeeze(a4iRectified(aiFrameSubset(iSubsetIter),:,:,k)));
            axis equal
            axis off
        end
    end
    set(gcf,'Name',sprintf('%d - %d',aiFrameSubset(1),aiFrameSubset(end)));
    drawnow
end

end