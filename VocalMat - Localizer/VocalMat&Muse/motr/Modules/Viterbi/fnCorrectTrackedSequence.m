function astrctTrackersFixed2 = fnCorrectTrackedSequence(astrctTrackers, strctAdditionalInfo,iLeftFrame,iRightFrame)
%
%Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

% Before we can correct identities using Viterbi, we must ensure that
% there are no NaN values....

astrctTrackersFixed = astrctTrackers;
iNumMice = length(astrctTrackers);
iNumFrames = iRightFrame-iLeftFrame+1;%length(astrctTrackers(1).m_afX);
aiFrameInterval = iLeftFrame:iRightFrame;
iNumFramesInMovie = length(astrctTrackers(1).m_afX);
% --------------------------------------------------------------- %
% (1) detect missing data.
a2bMissingInfo = zeros(iNumMice, iNumFrames);
for iMouseIter=1:iNumMice
    a2bMissingInfo(iMouseIter,:) = isnan(astrctTrackers(iMouseIter).m_afX(iLeftFrame:iRightFrame));
end;
% --------------------------------------------------------------- %
if ~all(a2bMissingInfo(:,1) == 0) || ~all(a2bMissingInfo(:,end) == 0)
    msgbox('Missing information on first or last frames.','Error - Can not interpolate');
    return;
end;


% --------------------------------------------------------------- %
% (2) Interpoalte missing values
fprintf('Interpolating Missing Values...\n');
iOffset = 3;
for iMouseIter=1:iNumMice
    astrctGaps = fnGetIntervals(a2bMissingInfo(iMouseIter,:));
    for iGapIter=1:length(astrctGaps)
        astrctTrackersFixed = fnInterpolateBetweenFrames(...
            astrctTrackersFixed, iMouseIter, max(1,(iLeftFrame-1)+astrctGaps(iGapIter).m_iStart-iOffset), ...
            min(iNumFrames,(iLeftFrame-1)+astrctGaps(iGapIter).m_iEnd+iOffset), false);
    end;
end;

% --------------------------------------------------------------- %
% (3) Run Viterbi and correct mice identities.
iNumFramesInChunk = 60000;
a2iIdentities = zeros(iNumFrames,iNumMice);
for iFrameIter=1:iNumFramesInChunk:iNumFrames
    aiFramesToAnalyze = aiFrameInterval(iFrameIter):min(iNumFramesInMovie,aiFrameInterval(iFrameIter)+iNumFramesInChunk-1);
    fprintf('Solving Identities on interval [%d - %d]\n',aiFramesToAnalyze(1),aiFramesToAnalyze(end));
    a2iIdentities(aiFramesToAnalyze,:)  = fnCorrectIdentities(astrctTrackers, strctAdditionalInfo,aiFramesToAnalyze);
end;

astrctTrackersFixed2 = astrctTrackersFixed;
for iMouseIter=1:iNumMice
    iMouseIndex = iMouseIter;
    for iFrameIter=1:iNumFrames
        astrctTrackersFixed2(iMouseIndex).m_afX(aiFrameInterval(iFrameIter)) = ...
            astrctTrackersFixed(a2iIdentities(iFrameIter,iMouseIter)).m_afX(aiFrameInterval(iFrameIter));
        astrctTrackersFixed2(iMouseIndex).m_afY(aiFrameInterval(iFrameIter)) = ...
            astrctTrackersFixed(a2iIdentities(iFrameIter,iMouseIter)).m_afY(aiFrameInterval(iFrameIter));
        astrctTrackersFixed2(iMouseIndex).m_afA(aiFrameInterval(iFrameIter)) = ...
            astrctTrackersFixed(a2iIdentities(iFrameIter,iMouseIter)).m_afA(aiFrameInterval(iFrameIter));
        astrctTrackersFixed2(iMouseIndex).m_afB(aiFrameInterval(iFrameIter)) = ...
            astrctTrackersFixed(a2iIdentities(iFrameIter,iMouseIter)).m_afB(aiFrameInterval(iFrameIter));
        astrctTrackersFixed2(iMouseIndex).m_afTheta(aiFrameInterval(iFrameIter)) = ...
            astrctTrackersFixed(a2iIdentities(iFrameIter,iMouseIter)).m_afTheta(aiFrameInterval(iFrameIter));
        astrctTrackersFixed2(iMouseIndex).m_astrctClass(aiFrameInterval(iFrameIter)) = ...
            astrctTrackersFixed(a2iIdentities(iFrameIter,iMouseIter)).m_astrctClass(aiFrameInterval(iFrameIter));
    end;
end

dbg = 1;
%--------------------------------------------------------------- %

%% (4) Fix head-tail 
bFixHeadTail = 0;
if bFixHeadTail
    astrctTrackersFixed2=fnFixHeadTail(astrctTrackersFixed2,iNumFramesInChunk,strctAdditionalInfo,iLeftFrame,iRightFrame);
end;

fprintf('Done!\n');
