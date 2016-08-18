function astrctTrackersJob=fnAddClassifierInfoLogistic(a3iRectified, strctAdditionalInfo,iFrameIndex,astrctTrackersJob)
%global g_astrctTrackersJob
iNumMice = length(astrctTrackersJob);
for iMouseIter=1:iNumMice
    % Apply identity classifiers on image patch
    Tmp = fnHOGfeatures(a3iRectified(:,:,iMouseIter),strctAdditionalInfo.m_strctMiceIdentityClassifier.iNumBins);
    afFeatures = Tmp(:);
    for iClassifierIter=1:iNumMice
        astrctTrackersJob(iMouseIter).m_a2fClassifer(iFrameIndex,iClassifierIter) =...
        fnApplyLDALogistic(strctAdditionalInfo.m_strctMiceIdentityClassifier.m_astrctClassifiers(iClassifierIter), afFeatures');
    end
    % Apply identity classifiers on flipped image patch
    Tmp = fnHOGfeatures(a3iRectified(end:-1:1,end:-1:1,iMouseIter),strctAdditionalInfo.m_strctMiceIdentityClassifier.iNumBins);
    afFeatures = Tmp(:);
    for iClassifierIter=1:iNumMice  
            astrctTrackersJob(iMouseIter).m_a2fClassiferFlip(iFrameIndex,iClassifierIter) =...
        fnApplyLDALogistic(strctAdditionalInfo.m_strctMiceIdentityClassifier.m_astrctClassifiers(iClassifierIter), afFeatures');
    end
    % Apply head tail classifier on image patch
    Tmp = fnHOGfeatures(a3iRectified(:,:,iMouseIter),strctAdditionalInfo.m_strctHeadTailClassifier.iNumBins);
    afFeatures = Tmp(:);
    
    astrctTrackersJob(iMouseIter).m_afHeadTail(iFrameIndex) = ...
       fnApplyLDALogistic(strctAdditionalInfo.m_strctHeadTailClassifier, afFeatures');
     
    Tmp = fnHOGfeatures(a3iRectified(end:-1:1,end:-1:1,iMouseIter),strctAdditionalInfo.m_strctHeadTailClassifier.iNumBins);
    afFeatures = Tmp(:);
    
    
    astrctTrackersJob(iMouseIter).m_afHeadTailFlip(iFrameIndex) = ...
       fnApplyLDALogistic(strctAdditionalInfo.m_strctHeadTailClassifier, afFeatures');
     
end;
return;