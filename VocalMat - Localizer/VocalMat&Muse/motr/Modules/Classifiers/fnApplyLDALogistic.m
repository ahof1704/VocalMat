function afProb = fnApplyLDALogistic(strctClassifier,a2fFeatures)
% Project onto best separating hyperplane and apply logistic regression to
% obtain the probability of being "Positive" class
afDataProj = a2fFeatures * strctClassifier.m_afW - strctClassifier.m_fThres;

sigmoid = @(a) 1./(1+exp(-a));
afProb = sigmoid([ones(size(a2fFeatures,1),1), afDataProj] * strctClassifier.m_afBCoeff);

return;
