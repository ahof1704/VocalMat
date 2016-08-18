function astrctTrackersFixed2=fnFixHeadTail(astrctTrackersFixed2,iNumFramesInChunk,strctAdditionalInfo,iLeftFrame,iRightFrame)
%iNumFrames = iRightFrame-iLeftFrame+1; %length(astrctTrackersFixed2(1).m_afX); % 
iNumMice = length(astrctTrackersFixed2);

for iFrameIter=iLeftFrame:iNumFramesInChunk:iRightFrame
    aiFramesToAnalyze = iFrameIter:min(length(astrctTrackersFixed2(1).m_afX),...
        iFrameIter+iNumFramesInChunk-1);
    fprintf('Solving Orientation on interval [%d - %d]\n',aiFramesToAnalyze(1),aiFramesToAnalyze(end));
    for iMouseIter=1:iNumMice
        afDiffX = [0,astrctTrackersFixed2(iMouseIter).m_afX(aiFramesToAnalyze(2:end))-astrctTrackersFixed2(iMouseIter).m_afX(aiFramesToAnalyze(1:end-1))];
        afDiffY = [0,astrctTrackersFixed2(iMouseIter).m_afY(aiFramesToAnalyze(2:end))-astrctTrackersFixed2(iMouseIter).m_afY(aiFramesToAnalyze(1:end-1))];
        afAlpha = atan2(-afDiffY,afDiffX);
        afAlpha(afAlpha < 0) = afAlpha(afAlpha<0)+2*pi;
        afVel = sqrt(afDiffX.^2+afDiffY.^2);
        afTheta = astrctTrackersFixed2(iMouseIter).m_afTheta(aiFramesToAnalyze);
        afTheta(afTheta < 0) = afTheta(afTheta<0)+2*pi;
        afHeadTailValue = cat(1,astrctTrackersFixed2(iMouseIter).m_astrctClass(aiFramesToAnalyze).m_fHeadTailValue);
        astrctTrackersFixed2(iMouseIter).m_afTheta(aiFramesToAnalyze) = ...
            fnCorrectOrientation(afTheta, afAlpha, afVel, afHeadTailValue, strctAdditionalInfo.m_strctHeadTailClassifier);
    end;
end;