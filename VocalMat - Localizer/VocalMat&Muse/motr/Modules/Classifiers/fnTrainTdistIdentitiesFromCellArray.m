function strctIdentityClassifier = ...
  fnTrainTdistIdentitiesFromCellArray(acFeatures)

% Make an array that will be useful later for selecting out-of-class HOG
% vectors
iNumMice = length(acFeatures);
aiMouseIndex=(1:iNumMice)';

% Train a classifier for each mouse
for i=1:iNumMice
  % Extract the in-class and out-of-classHOG vectors for this mouse
  a2fFeaturesPos=acFeatures{i};
  abNotThis=~(aiMouseIndex==i);
  a2fFeaturesNeg=vertcat(acFeatures{abNotThis});  
  % Train the classifier
  [classifierThis,dummy,classifierNegClassThis]= ...
    fnTrainTdistClassifier(a2fFeaturesPos,a2fFeaturesNeg);  %#ok
  % Store the classifier with the rest
  strctIdentityClassifier.m_astrctClassifiers(i)=classifierThis;
  strctIdentityClassifier.m_astrctClassifiersNegClass(i) = ...
    classifierNegClassThis;
end

end
