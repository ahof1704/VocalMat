function astrctTrackers = fnCreateEmptyTrackStruct(iNumMice, iNumFrames)
afNaN = ones(1,iNumFrames,'single') * single(NaN);
a2fNaN = ones(iNumFrames,iNumMice,'single') * single(NaN);
strctTracker = struct('m_afX',afNaN,'m_afY',afNaN,'m_afA',afNaN,'m_afB',afNaN,'m_afTheta',afNaN, 'm_a2fClassifer',a2fNaN);
for iMouseIter=1:iNumMice
    astrctTrackers(iMouseIter) = strctTracker;
end;

return;
