function astrctTrackersJob=fnUpdateOutput(iOutputIndex, strctFrameOutput,astrctTrackersJob)

% Copies the direllipses in strctFrameOutput to the iOutputIndex'th record
% of astrctTrackersJob.

iNumMice = length(astrctTrackersJob);
for iMouseIter=1:iNumMice
    astrctTrackersJob(iMouseIter).m_afX(iOutputIndex) = strctFrameOutput(iMouseIter).m_fX;
    astrctTrackersJob(iMouseIter).m_afY(iOutputIndex) = strctFrameOutput(iMouseIter).m_fY;
    astrctTrackersJob(iMouseIter).m_afA(iOutputIndex) = strctFrameOutput(iMouseIter).m_fA;
    astrctTrackersJob(iMouseIter).m_afB(iOutputIndex) = strctFrameOutput(iMouseIter).m_fB;
    astrctTrackersJob(iMouseIter).m_afTheta(iOutputIndex) = strctFrameOutput(iMouseIter).m_fTheta;
end;
