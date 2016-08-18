function [W,fThres, iTP,iTN,iFP,iFN, afDataProjPos, afDataProjNeg]=fnFisherDiscriminant(DataPos, DataNeg)
afMeanPos = mean(DataPos,1);
DataCenteredPos = DataPos - repmat(afMeanPos, size(DataPos,1),1);
a2fCovPos  = DataCenteredPos' * DataCenteredPos;
clear DataCenteredPos

afMeanNeg = mean(DataNeg,1);
DataCenteredNeg = DataNeg - repmat(afMeanNeg, size(DataNeg,1),1);
a2fCovNeg  = DataCenteredNeg' * DataCenteredNeg;
clear DataCenteredNeg
% Use Moore-Penrose Pseudo Inverse since Sw is typically singular...
W = pinv(a2fCovNeg+a2fCovPos) * (afMeanPos-afMeanNeg)';
fThres =  (afMeanPos+afMeanNeg)/2 * W;

afDataProjPos = DataPos * W;
afDataProjNeg = DataNeg * W;

iFP = sum(afDataProjPos < fThres);
iFN = sum(afDataProjNeg > fThres);
iTP = sum(afDataProjPos >= fThres);
iTN = sum(afDataProjNeg <= fThres);


return;
