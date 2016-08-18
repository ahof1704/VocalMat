function [strctHeadTailClassifier,strctHeadTailClassifierNeg] = ...
  fnCullExemplarsAndTrainTdistHeadTailClassifier(acHOGFeatures, ...
                                                 acHOGFeaturesFlipped, ...
                                                 acA, ...
                                                 acB)

% Computes the head-tail classifier from the HOG vectors for the
% non-rotated and the rotated (i.e. flipped) image patches, after culling
% them for just the good ones.
                                               
% Get the max number of head-tail exemplars out of the global 
% g_strctGlobalParam                                        
global g_strctGlobalParam
iMaxNumExemplars=...
  g_strctGlobalParam.m_strctClassifiers.m_fMaxSamplesPerMouseForHeadTailTraining;
clear g_strctGlobalParam

% Cull high-quality exemplars, up to iMaxNumExemplars per mouse, from
% the HOG feature vectors
[acHOGFeaturesCulled,acHOGFeaturesFlippedCulled] = ...
  fnCullExemplarsFromSMTracks(acHOGFeatures, ...
                              acA,acB, ...
                              iMaxNumExemplars, ...
                              acHOGFeaturesFlipped);
                            
% Unpack the feature vectors from the cell arrays into float arrays
% We don't care about mouse identity at this point---We want the head-tail
% classifier to figure out whether the image is head-right or head-left
% regardless of what mouse it is.
a2fHOGFeaturesCulled=vertcat(acHOGFeaturesCulled{:});
a2fHOGFeaturesFlippedCulled=vertcat(acHOGFeaturesFlippedCulled{:});

% train the classifier for discriminating head-left from head-right patches
[strctHeadTailClassifier,dummy,strctHeadTailClassifierNeg] = ...
  fnTrainTdistClassifier(a2fHOGFeaturesCulled, ...
                         a2fHOGFeaturesFlippedCulled);  %#ok

end
