function astrctTrackersHistory = fnPrepareHistory(aiHistoryIndices,astrctTrackersJob)
% Crop to history indices.
% Copy the direllipses to the output from the input astrctTrackerJob,
% keeping only those indices indicated by aiHistoryIndices.

% Get dimensions.
iNumMice = length(astrctTrackersJob);
iNumFrames=length(aiHistoryIndices);

% Pre-allocate astrctTrackersHistory.
astrctTrackersHistory=struct('m_afX',cell(1,iNumMice), ...
                             'm_afY',cell(1,iNumMice), ...
                             'm_afA',cell(1,iNumMice), ...
                             'm_afB',cell(1,iNumMice), ...
                             'm_afTheta',cell(1,iNumMice));
                             
% Copy the direllipses to astrctTrackersHistory from astrctTrackersJob,
% keeping only the "historical" elements indicated by aiHistoryIndices.
for iMouseIter=1:iNumMice
    astrctTrackersHistory(iMouseIter).m_afX = astrctTrackersJob(iMouseIter).m_afX(aiHistoryIndices);
    astrctTrackersHistory(iMouseIter).m_afY = astrctTrackersJob(iMouseIter).m_afY(aiHistoryIndices);
    astrctTrackersHistory(iMouseIter).m_afA = astrctTrackersJob(iMouseIter).m_afA(aiHistoryIndices);
    astrctTrackersHistory(iMouseIter).m_afB = astrctTrackersJob(iMouseIter).m_afB(aiHistoryIndices);
    astrctTrackersHistory(iMouseIter).m_afTheta = astrctTrackersJob(iMouseIter).m_afTheta(aiHistoryIndices);    
end;

return;