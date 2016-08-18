function a3iRectified = fnCollectRectifiedMice2(a2iFrame, astrctTrackersJob, iFrameIndex)
global g_strctGlobalParam

iNumMice = length(astrctTrackersJob);
a3iRectified = ones(g_strctGlobalParam.m_strctClassifiers.m_fImagePatchHeight,g_strctGlobalParam.m_strctClassifiers.m_fImagePatchWidth, iNumMice,'uint8');
for iMouseIter=1:iNumMice
    if ~isnan(astrctTrackersJob(iMouseIter).m_afX(iFrameIndex))
        a3iRectified(:,:,iMouseIter) = fnRectifyPatch(single(a2iFrame), ...
            astrctTrackersJob(iMouseIter).m_afX(iFrameIndex),...
            astrctTrackersJob(iMouseIter).m_afY(iFrameIndex),...
            astrctTrackersJob(iMouseIter).m_afTheta(iFrameIndex));
    end;
end;
return;

