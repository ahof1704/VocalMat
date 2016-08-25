function aiOrientationClass = fnCollectMiceOrientation(a2iFrame, astrctTrackers,HeadTailModel)
iNumMice = length(astrctTrackers);
aiOrientationClass = zeros(1,4);
for iMouseIter=1:iNumMice
   a2iRectifiedPatch = uint8(fnRectifyPatch(single(a2iFrame), ...
        astrctTrackers(iMouseIter).m_fX,...
        astrctTrackers(iMouseIter).m_fY,...
        astrctTrackers(iMouseIter).m_fTheta));
    
    a2fFeatures = fnHOGfeatures(a2iRectifiedPatch, 8);
    aiOrientationClass(iMouseIter) = fnsvmpredict(1, double(a2fFeatures(:))', HeadTailModel);
end;
return;

