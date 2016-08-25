function afProb = fnApplyTDist(strctClassifier, a2fFeatures)

a2fZeroMeanFeatures = a2fFeatures-repmat(strctClassifier.m_afMean',size(a2fFeatures,1),1); %% zero-mean the data
afDataProj = strctClassifier.m_afLDA' * a2fZeroMeanFeatures';

afProb = tlspdf(afDataProj, strctClassifier.m_fMu,strctClassifier.m_fSigma,strctClassifier.m_fNu);


