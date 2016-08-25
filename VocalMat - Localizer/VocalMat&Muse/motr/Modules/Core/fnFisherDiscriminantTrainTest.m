function [W,fThres, afPerf_Train, afPerf_Test, afX, afHistPos, afHistNeg, afProb] = fnFisherDiscriminantTrainTest(a2fFeatures, ...
    aiTrainingSet, aiTestingSet, iIdentityIter, iNumIdentities, iPDFQuantizer)
% We are handling huge amounts of data here. To make sure nothing is
% duplicated, we send everything to a MEX file....
% Otherwise, accessing with a2fFeatures(aiTrainPos,:) will generate a
% temporary matrix with all these entries, which will, essentially,
% duplicate the entire sample set in memory....

aiTrainPos = find(aiTrainingSet == iIdentityIter);
aiTestPos = find(aiTestingSet == iIdentityIter);

aiTrainNeg = find(aiTrainingSet ~= iIdentityIter & aiTrainingSet > 0);
%aiTestNeg = find(aiTestingSet ~= iIdentityIter & aiTestingSet > 0);

if 1
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
    
else
    %[a2fCovPos, afMeanPos] = fndllCovInd(a2fFeatures, aiTrainPos);
    %[a2fCovNeg, afMeanNeg] = fndllCovInd(a2fFeatures, aiTrainNeg);
end

W = pinv(a2fCovNeg+a2fCovPos) * (afMeanPos-afMeanNeg)';
fThres =  (afMeanPos+afMeanNeg)/2 * W;



% Performance analysis
afPerf_Train  = zeros(1,iNumIdentities);
afPerf_Test = zeros(1,iNumIdentities);

if 1
    afPerf_Train(iIdentityIter) = sum(a2fFeatures(aiTrainPos,:) * W > fThres) / length(aiTrainPos); % TP
    if ~isempty(aiTestingSet)
        afPerf_Test(iIdentityIter) = sum(a2fFeatures(aiTestPos,:) * W > fThres) / length(aiTestPos); % TP
    else
        afPerf_Test(iIdentityIter) = 0;
    end;
    
else
    %     afPerf_Train(iIdentityIter) = sum(fndllMultInd(a2fFeatures, W, aiTrainPos) > fThres) / length(aiTrainPos); % TP
    %     afPerf_Test(iIdentityIter) = sum(fndllMultInd(a2fFeatures, W, aiTestPos) > fThres) / length(aiTestPos); % TP
end;

% Decompose aiTestNeg to its individual identities components
aiOtherID = setdiff(1:iNumIdentities, iIdentityIter);
for iOtherIDIter = aiOtherID
    if 1
        aiTrainInd = find(aiTrainingSet == iOtherIDIter);
        afPerf_Train(iOtherIDIter) = sum(a2fFeatures(aiTrainInd,:) * W > fThres) / length(aiTrainInd); % FP
        if ~isempty(aiTestingSet)
            aiTestInd = find(aiTestingSet == iOtherIDIter);
            afPerf_Test(iOtherIDIter) = sum(a2fFeatures(aiTestInd,:) * W > fThres) / length(aiTestInd); % FP
        else
            afPerf_Test(iOtherIDIter) = 0;
        end
    else
        aiTrainInd = find(aiTrainingSet == iOtherIDIter);
        afPerf_Train(iOtherIDIter) = sum(fndllMultInd(a2fFeatures, W, aiTrainInd ) > fThres) / length(aiTrainInd); % FP
        aiTestInd = find(aiTestingSet == iOtherIDIter);
        afPerf_Test(iOtherIDIter) = sum(fndllMultInd(a2fFeatures, W, aiTestInd ) > fThres) / length(aiTestInd); % FP
    end;
end

afProjPos = a2fFeatures(aiTrainPos,:) * W;
afProjNeg = a2fFeatures(aiTrainNeg,:) * W;
[afX, afHistPos, afHistNeg, afProb] = ...
      fnEstimateDistribution(afProjPos, afProjNeg,iPDFQuantizer, 1e-3,iNumIdentities); %1e-4
return;
