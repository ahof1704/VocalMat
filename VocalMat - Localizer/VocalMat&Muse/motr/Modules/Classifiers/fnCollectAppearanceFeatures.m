function a2fAppearanceFeatures= ...
  fnCollectAppearanceFeatures(acHOGFeaturesCulledForID)

global g_strctGlobalParam
iMaxNumApperanceSamplesPerMouse= ...
  g_strctGlobalParam.m_strctClassifiers.m_fNumApperanceSamplesPerMouse;
clear g_strctGlobalParam

% Collect the feature vectors from all mice, put them in one array
a2fHOGFeaturesCulledForID=vertcat(acHOGFeaturesCulledForID{:});

% SO Feb 08 2011: This collects a large set of HOG features of random mice 
% exemplars. This is later used during tracking. See technical report 
% section "Segmentation Validation"
iNumMice=length(acHOGFeaturesCulledForID);
iMaxNumSamplesForAppearanceModel=iMaxNumApperanceSamplesPerMouse*iNumMice;
iNumExemplars=size(a2fHOGFeaturesCulledForID,1);
iNumSamplesForAppearanceModel=min(iNumExemplars,...
                                  iMaxNumSamplesForAppearanceModel);
% aiRandSamples = ...
%     1+round(rand(1,iNumSamplesForAppearanceModel)) * (iNumExemplars-1);
aiRandSamples = randi(iNumExemplars,[1 iNumSamplesForAppearanceModel]);
a2fAppearanceFeatures = a2fHOGFeaturesCulledForID(aiRandSamples,:)';

% SO : Feb 08 2012: This takes the features through a Z transform
iNumSamples = size(a2fAppearanceFeatures,1);
a2fAppearanceFeatures = ...
    a2fAppearanceFeatures - ...
    repmat(mean(a2fAppearanceFeatures,1),iNumSamples, 1);
a2fAppearanceFeatures = ...
    a2fAppearanceFeatures ./ ...
    repmat(sqrt(sum(a2fAppearanceFeatures.^2,1)), iNumSamples, 1);

end
