function astrctTrackersJob=...
  fnAddClassifierInfoTdist(a3iRectified, strctAdditionalInfo,iFrameIndex, astrctTrackersJob)
%global g_astrctTrackersJob
iNumMice = length(astrctTrackersJob);
for iMouseIter=1:iNumMice
    % Apply identity classifiers on image patch
    Tmp = fnHOGfeatures(a3iRectified(:,:,iMouseIter),strctAdditionalInfo.m_strctMiceIdentityClassifier.iNumBins);
    afFeatures = Tmp(:);
    for iClassifierIter=1:iNumMice
        astrctTrackersJob(iMouseIter).m_a2fClassifer(iFrameIndex,iClassifierIter) =...
        fnApplyTDist(strctAdditionalInfo.m_strctMiceIdentityClassifier.m_astrctClassifiers(iClassifierIter), afFeatures');
    end
    % Apply identity classifiers on flipped image patch
    Tmp = fnHOGfeatures(a3iRectified(end:-1:1,end:-1:1,iMouseIter),strctAdditionalInfo.m_strctMiceIdentityClassifier.iNumBins);
    afFeatures = Tmp(:);
    for iClassifierIter=1:iNumMice  
            astrctTrackersJob(iMouseIter).m_a2fClassiferFlip(iFrameIndex,iClassifierIter) =...
        fnApplyTDist(strctAdditionalInfo.m_strctMiceIdentityClassifier.m_astrctClassifiers(iClassifierIter), afFeatures');
    end
    
    % Apply head tail classifier on image patch
    Tmp = fnHOGfeatures(a3iRectified(:,:,iMouseIter),strctAdditionalInfo.m_strctHeadTailClassifier.iNumBins);
    afFeatures = Tmp(:);
    % The only way that I can see this makes sense is if we use the output
    % of fnApplyTDist for the head-tail classifier (which gives the density
    % of p(projected features|head-right), and use it along with
    % p(projected features|head-left) to construct P(head-right|projected features). 
    %astrctTrackersJob(iMouseIter).m_afHeadTail(iFrameIndex) = ...
    %   fnApplyTDist(strctAdditionalInfo.m_strctHeadTailClassifier, afFeatures');
    fProbDensityFeaturesGivenHeadRight = ...
       fnApplyTDist(strctAdditionalInfo.m_strctHeadTailClassifier, afFeatures');
    fProbDensityFeaturesGivenHeadLeft = ...
       fnApplyTDist(strctAdditionalInfo.m_strctHeadTailClassifierNeg, afFeatures');
    fLR=fProbDensityFeaturesGivenHeadRight/fProbDensityFeaturesGivenHeadLeft;
      % likelihood ratio
    fProbHeadRightGivenFeatures=1/(1+1/fLR);
    astrctTrackersJob(iMouseIter).m_afHeadTail(iFrameIndex) = ...
       fProbHeadRightGivenFeatures;  
     
    % Now do H-T for flipped image 
    Tmp = fnHOGfeatures(a3iRectified(end:-1:1,end:-1:1,iMouseIter),strctAdditionalInfo.m_strctHeadTailClassifier.iNumBins);
    afFeatures = Tmp(:);
    %astrctTrackersJob(iMouseIter).m_afHeadTailFlip(iFrameIndex) = ...
    %   fnApplyTDist(strctAdditionalInfo.m_strctHeadTailClassifier, afFeatures');
    fProbDensityFeaturesGivenHeadRight = ...
       fnApplyTDist(strctAdditionalInfo.m_strctHeadTailClassifier, afFeatures');
    fProbDensityFeaturesGivenHeadLeft = ...
       fnApplyTDist(strctAdditionalInfo.m_strctHeadTailClassifierNeg, afFeatures');
    fLR=fProbDensityFeaturesGivenHeadRight/fProbDensityFeaturesGivenHeadLeft;
      % likelihood ratio
    fProbHeadRightGivenFeatures=1/(1+1/fLR);
    astrctTrackersJob(iMouseIter).m_afHeadTailFlip(iFrameIndex) = ...
       fProbHeadRightGivenFeatures;  
     
end;
return;