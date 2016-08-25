function a3iRectified = fnCollectRectifiedMice(a2iFrame, astrctTrackers, arg)
global g_strctGlobalParam
iNumMice = length(astrctTrackers);
a3iRectified = ones(g_strctGlobalParam.m_strctClassifiers.m_fImagePatchHeight,g_strctGlobalParam.m_strctClassifiers.m_fImagePatchWidth, iNumMice,'uint8');
for iMouseIter=1:iNumMice
    if ~isnan(astrctTrackers(iMouseIter).m_fX)
        a3iRectified(:,:,iMouseIter) = fnRectifyPatch(single(a2iFrame), ...
            astrctTrackers(iMouseIter).m_fX,...
            astrctTrackers(iMouseIter).m_fY,...
            astrctTrackers(iMouseIter).m_fTheta);
    end;
end;
return;

