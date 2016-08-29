function afImageError = fnScoreFunction(a2iFrame, astrctOptimized, strctApperance)
% Compute HOG features for the patches.
% Then, subtract the mean, and compute the correlation with a saved
% data set. 
% Repeat for patches that are in the incorrect orientation (180 flip)
% return the maximum correlation encountered...
%

a3iRectified = fnCollectRectifiedMice(a2iFrame, astrctOptimized);
iNumMice = length(astrctOptimized);
iNumFeatures = size(strctApperance.m_a2fFeatures,1);
a2fCurrFeatures = zeros(iNumFeatures,iNumMice);
a2fCurrFeaturesFlipped = zeros(iNumFeatures,iNumMice);

for iMouseIter=1:iNumMice
        Tmp = fnHOGfeatures(a3iRectified(:,:,iMouseIter),strctApperance.m_iNumBins);
        a2fCurrFeatures(:,iMouseIter) = Tmp(:);
        Tmp = fnHOGfeatures(a3iRectified(end:-1:1,end:-1:1,iMouseIter),strctApperance.m_iNumBins);
        a2fCurrFeaturesFlipped(:,iMouseIter) = Tmp(:);
end;

a2fT1 = a2fCurrFeatures - repmat(mean(a2fCurrFeatures,1),iNumFeatures, 1);
a2fT2 = a2fT1 ./ repmat(sqrt(sum(a2fT1.^2,1)), iNumFeatures, 1);
a2fTmp = a2fT2' * strctApperance.m_a2fFeatures;


a2fT1 = a2fCurrFeaturesFlipped - repmat(mean(a2fCurrFeatures,1),iNumFeatures, 1);
a2fT2 = a2fT1 ./ repmat(sqrt(sum(a2fT1.^2,1)), iNumFeatures, 1);
a2fTmp2 = a2fT2' * strctApperance.m_a2fFeatures;

afImageError = max([a2fTmp,a2fTmp2],[],2)';
return;
