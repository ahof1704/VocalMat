function [afX, afHistPos,W,fThres] = fnFisherDiscriminantTrainTestStandardMethod(a2fFeatures, ...
    aiTrainPos, aiTrainNeg, iPDFQuantizer)
% We are handling huge amounts of data here. To make sure nothing is
% duplicated, we send everything to a MEX file....
% Otherwise, accessing with a2fFeatures(aiTrainPos,:) will generate a
% temporary matrix with all these entries, which will, essentially,
% duplicate the entire sample set in memory....

DataPos = a2fFeatures(aiTrainPos,:);
afMeanPos = mean(DataPos,1);
DataCenteredPos = DataPos - repmat(afMeanPos, size(DataPos,1),1);
a2fCovPos  = DataCenteredPos' * DataCenteredPos;
clear DataCenteredPos DataPos

DataNeg = a2fFeatures(aiTrainNeg,:);
afMeanNeg = mean(DataNeg,1);
DataCenteredNeg = DataNeg - repmat(afMeanNeg, size(DataNeg,1),1);
a2fCovNeg  = DataCenteredNeg' * DataCenteredNeg;
clear DataCenteredNeg DataNeg

W = pinv(a2fCovNeg+a2fCovPos) * (afMeanPos-afMeanNeg)';
fThres =  (afMeanPos+afMeanNeg)/2 * W;

afProjPos = a2fFeatures(aiTrainPos,:) * W;
afProjNeg = a2fFeatures(aiTrainNeg,:) * W;
[afX, afHistPos] = ...
      fnEstimateDistribution(afProjPos, afProjNeg,iPDFQuantizer, 1e-3,1); % this is a degenerate way of using this function

return;
