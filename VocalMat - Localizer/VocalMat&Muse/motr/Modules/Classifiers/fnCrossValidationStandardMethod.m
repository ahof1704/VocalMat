function [a2fConfusionMatrixTrainingSet_Avg, a2fConfusionMatrixTestingSet_Avg] = fnCrossValidationStandardMethod(a2fFeatures, aiStart,aiEnd, K)
global g_strctGlobalParam

if strcmpi(g_strctGlobalParam.m_strctClassifiers.m_strType,'LDA_Logistic')
[a2fConfusionMatrixTrainingSet_Avg, a2fConfusionMatrixTestingSet_Avg] = ...
    fnCrossValidationStandardMethodUsingLogisticRegression(a2fFeatures, aiStart,aiEnd, K);

else
[a2fConfusionMatrixTrainingSet_Avg, a2fConfusionMatrixTestingSet_Avg] = ...
    fnCrossValidationStandardMethodUsingLDA2(a2fFeatures, aiStart,aiEnd, K);
end
return;


function [a2fConfusionMatrixTrainingSet_Avg, a2fConfusionMatrixTestingSet_Avg] = ...
    fnCrossValidationStandardMethodUsingLogisticRegression(a2fFeatures, aiStart,aiEnd, K)
iNumIdentities = length(aiStart);

a2fConfusionMatrixTrainingSet_Avg = zeros(iNumIdentities,iNumIdentities);
a2fConfusionMatrixTestingSet_Avg = zeros(iNumIdentities,iNumIdentities);

for iSetIter = 1 : K
    fprintf('Cross Validation Set %d out of %d \n',iSetIter,K);
    drawnow update
    
    for iIdentityIter= 1 : iNumIdentities
        [aiTrainingPos,  aiTraininNeg] = fnComputeSetsIndices(aiStart,aiEnd, iIdentityIter, iSetIter, K);
        astrctClassifier(iIdentityIter) = fnLDALogistic(...
            a2fFeatures(aiTrainingPos,:),a2fFeatures(aiTraininNeg,:));
    end;
    
    % Evaluation on test and training sets...
    a2iConfusionMatrixTrainingSet = zeros(iNumIdentities,iNumIdentities);
    a2iConfusionMatrixTestingSet = zeros(iNumIdentities,iNumIdentities);

    a2iNumSamplesTraining = zeros(iNumIdentities,iNumIdentities);
    a2iNumSamplesTesting = zeros(iNumIdentities,iNumIdentities);
    
    for iTrueID = 1:iNumIdentities
        [aiTrainingPos,  aiTraininNeg, aiTestingPos] = fnComputeSetsIndices(aiStart,aiEnd, iTrueID, iSetIter, K);
        for iPredID = 1:iNumIdentities
            
            afProbTrainingPos = fnApplyLDALogistic(astrctClassifier(iPredID),a2fFeatures(aiTrainingPos,:));
            afProbTestingPos = fnApplyLDALogistic(astrctClassifier(iPredID),a2fFeatures(aiTestingPos,:));
            
            a2iConfusionMatrixTrainingSet(iTrueID,iPredID) = sum(afProbTrainingPos>0.5); 
            a2iConfusionMatrixTestingSet(iTrueID,iPredID) = sum(afProbTestingPos>0.5) ;
            
            a2iNumSamplesTraining(iTrueID,iPredID) = length(aiTrainingPos);
            a2iNumSamplesTesting(iTrueID,iPredID) = length(aiTestingPos);
            
        end
    end
    
    % normalize each row 

    a2fConfusionMatrixTrainingSet = a2iConfusionMatrixTrainingSet ./ a2iNumSamplesTraining;
    a2fConfusionMatrixTestingSet = a2iConfusionMatrixTestingSet ./ a2iNumSamplesTesting;

    a2fConfusionMatrixTrainingSet_Avg = a2fConfusionMatrixTrainingSet_Avg + a2fConfusionMatrixTrainingSet;
    a2fConfusionMatrixTestingSet_Avg =a2fConfusionMatrixTestingSet_Avg + a2fConfusionMatrixTestingSet ;
    
end;

a2fConfusionMatrixTrainingSet_Avg = a2fConfusionMatrixTrainingSet_Avg / K;
a2fConfusionMatrixTestingSet_Avg = a2fConfusionMatrixTestingSet_Avg / K;


return



function [a2fConfusionMatrixTrainingSet_Avg, a2fConfusionMatrixTestingSet_Avg] = ...
    fnCrossValidationStandardMethodUsingLDA2(a2fFeatures, aiStart,aiEnd, K)
% Assume DataPos and DataNeg ave the same size
iNumIdentities = length(aiStart);

iPDFQuantifier = 100;
iHOGDim  = size(a2fFeatures,2);
a2fConfusionMatrixTrainingSet_Avg = zeros(iNumIdentities,iNumIdentities);
a2fConfusionMatrixTestingSet_Avg = zeros(iNumIdentities,iNumIdentities);
bUseIntervalsForTestSet = false;

for iSetIter = 1 : K
    fprintf('Cross Validation Set %d out of %d \n',iSetIter,K);
    drawnow update
    
    a2fX = zeros(iPDFQuantifier, iNumIdentities);
    a2fHistPos = zeros(iPDFQuantifier, iNumIdentities);    
    a2fW = zeros(iHOGDim, iNumIdentities);        
    afThres = zeros(1,iNumIdentities);
    for iIdentityIter= 1 : iNumIdentities
        [aiTrainingPos,  aiTraininNeg] = fnComputeSetsIndices(aiStart,aiEnd, iIdentityIter, iSetIter, K);
        [a2fX(:,iIdentityIter), a2fHistPos(:,iIdentityIter), a2fW(:,iIdentityIter), afThres(iIdentityIter)] = fnFisherDiscriminantTrainTestStandardMethod(a2fFeatures, ...
            aiTrainingPos,  aiTraininNeg, iPDFQuantifier);
    end;
    
    % Evaluation on test and training sets...
    a2iConfusionMatrixTrainingSet = zeros(iNumIdentities,iNumIdentities);
    a2iConfusionMatrixTestingSet = zeros(iNumIdentities,iNumIdentities);
    a2iNumSamplesTraining = zeros(iNumIdentities,iNumIdentities);
    a2iNumSamplesTesting = zeros(iNumIdentities,iNumIdentities);
    for iTrueID = 1: iNumIdentities
        [aiTrainingPos,  aiTraininNeg, aiTestingPos] = fnComputeSetsIndices(aiStart,aiEnd, iTrueID , iSetIter, K);
        for iPredID = 1:iNumIdentities
            afProjPosTrain = a2fFeatures(aiTrainingPos,:) * a2fW(:,iPredID); % Projection
            afProjPosTest = a2fFeatures(aiTestingPos,:) * a2fW(:,iPredID); % Projection
            a2iConfusionMatrixTrainingSet(iTrueID, iPredID) = sum(afProjPosTrain > afThres(iPredID));
            a2iConfusionMatrixTestingSet(iTrueID, iPredID) =  sum(afProjPosTest > afThres(iPredID));
            a2iNumSamplesTraining(iTrueID,iPredID) = length(afProjPosTrain);
            a2iNumSamplesTesting(iTrueID,iPredID) = length(afProjPosTest);
        end
    end;
    a2fConfusionMatrixTrainingSet = a2iConfusionMatrixTrainingSet ./ a2iNumSamplesTraining;
    a2fConfusionMatrixTestingSet = a2iConfusionMatrixTestingSet ./ a2iNumSamplesTesting;

    a2fConfusionMatrixTrainingSet_Avg = a2fConfusionMatrixTrainingSet_Avg + a2fConfusionMatrixTrainingSet;
    a2fConfusionMatrixTestingSet_Avg =a2fConfusionMatrixTestingSet_Avg + a2fConfusionMatrixTestingSet ;
    
end;

a2fConfusionMatrixTrainingSet_Avg = a2fConfusionMatrixTrainingSet_Avg / K;
a2fConfusionMatrixTestingSet_Avg = a2fConfusionMatrixTestingSet_Avg / K;
return;




function [a2fConfusionMatrixTrainingSet_Avg, a2fConfusionMatrixTestingSet_Avg] = ...
    fnCrossValidationStandardMethodUsingLDA(a2fFeatures, aiStart,aiEnd, K)
% Assume DataPos and DataNeg ave the same size
iNumIdentities = length(aiStart);

iPDFQuantifier = 100;
iHOGDim  = size(a2fFeatures,2);
a2fConfusionMatrixTrainingSet_Avg = zeros(iNumIdentities,iNumIdentities);
a2fConfusionMatrixTestingSet_Avg = zeros(iNumIdentities,iNumIdentities);
bUseIntervalsForTestSet = false;

for iSetIter = 1 : K
    fprintf('Cross Validation Set %d out of %d \n',iSetIter,K);
    drawnow update
    
    a2fX = zeros(iPDFQuantifier, iNumIdentities);
    a2fHistPos = zeros(iPDFQuantifier, iNumIdentities);    
    a2fW = zeros(iHOGDim, iNumIdentities);        
    for iIdentityIter= 1 : iNumIdentities
        [aiTrainingPos,  aiTraininNeg] = fnComputeSetsIndices(aiStart,aiEnd, iIdentityIter, iSetIter, K);
        [a2fX(:,iIdentityIter), a2fHistPos(:,iIdentityIter), a2fW(:,iIdentityIter)] = fnFisherDiscriminantTrainTestStandardMethod(a2fFeatures, ...
            aiTrainingPos,  aiTraininNeg, iPDFQuantifier);
    end;
    
    % Evaluation on test and training sets...
    a2fConfusionMatrixTrainingSet = zeros(iNumIdentities,iNumIdentities);
    a2fConfusionMatrixTestingSet = zeros(iNumIdentities,iNumIdentities);
    
    for iIdentityIter= 1 : iNumIdentities
        [aiTrainingPos,  aiTraininNeg, aiTestingPos] = fnComputeSetsIndices(aiStart,aiEnd, iIdentityIter, iSetIter, K);
        
        a2fProjPosTrain = a2fFeatures(aiTrainingPos,:) * a2fW; % Projection
        a2fProjPosTest = a2fFeatures(aiTestingPos,:) * a2fW; % Projection
         
        a2fProbTrain = zeros(size(a2fProjPosTrain));
        a2fProbTest = zeros(size(a2fProjPosTest));
        for iIter = 1:iNumIdentities
            a2fProbTrain(:,iIter) = interp1( a2fX(:,iIter), a2fHistPos(:,iIter), a2fProjPosTrain(:,iIter),'linear','extrap');
            a2fProbTest(:,iIter) = interp1( a2fX(:,iIter), a2fHistPos(:,iIter), a2fProjPosTest(:,iIter),'linear','extrap');
        end;
        
        % using intervals and not individual frames for classificaion
        if bUseIntervalsForTestSet
            iIntervalLength = 30;
            aiIntervals = 1:iIntervalLength:size(a2fProbTest,1);
            iNumIntervals = length(aiIntervals)-1;
            a2fSumProb = zeros(iNumIntervals, iNumIdentities);
            for k=1:length(aiIntervals)-1
                aiInterval = aiIntervals(k):aiIntervals(k+1);
                a2fSumProb(k,:) = sum(a2fProbTest(aiInterval,:),1);
            end;
            a2fProbTest = a2fSumProb;
        end;
        
        [afDummy,aiIndicesTrain] = max(a2fProbTrain,[],2);
        [afDummy,aiIndicesTest] = max(a2fProbTest,[],2);
        a2fConfusionMatrixTrainingSet(iIdentityIter,:) = hist( aiIndicesTrain, 1:iNumIdentities);
        a2fConfusionMatrixTestingSet(iIdentityIter,:) = hist( aiIndicesTest, 1:iNumIdentities);
    end;
    % normalize each row 
    a2fConfusionMatrixTrainingSet = a2fConfusionMatrixTrainingSet ./ repmat(sum(a2fConfusionMatrixTrainingSet,2), 1, iNumIdentities);
    a2fConfusionMatrixTestingSet = a2fConfusionMatrixTestingSet ./ repmat(sum(a2fConfusionMatrixTestingSet,2), 1, iNumIdentities);    

    a2fConfusionMatrixTrainingSet_Avg = a2fConfusionMatrixTrainingSet_Avg + a2fConfusionMatrixTrainingSet;
    a2fConfusionMatrixTestingSet_Avg =a2fConfusionMatrixTestingSet_Avg + a2fConfusionMatrixTestingSet ;
    
end;

a2fConfusionMatrixTrainingSet_Avg = a2fConfusionMatrixTrainingSet_Avg / K;
a2fConfusionMatrixTestingSet_Avg = a2fConfusionMatrixTestingSet_Avg / K;
return;







% 
%         [n1,c1]= hist(a2fProjPosTrain(:,1),a2fX(:,1));
%         [n2,c2]= hist(a2fProjPosTest(:,1),a2fX(:,1));        
%         n1=n1/sum(n1);
%         n2=n2/sum(n2);
%         
%         v1 = interp1( a2fX(:,1), a2fHistPos(:,1), a2fProjPosTrain(:,1),'linear','extrap');
%         v2 = interp1( a2fX(:,1), a2fHistPos(:,1), a2fProjPosTest(:,1),'linear','extrap');
%          
%         [n3,c3]= hist(v1,500);
%         [n4,c4]= hist(v2,500);
%         n3=n3/sum(n3);
%         n4=n4/sum(n4);
%            
%         figure(1);
%         clf;
%         plot(c1,n1,'b',c2,n2,'r', a2fX(:,1), a2fHistPos(:,1),'c');
%         figure(2);
%         plot(afProb,n3,'b',afProb,n4,'r');

function  [aiTrainingPos,  aiTraininNeg, aiTestingPos] = fnComputeSetsIndices(aiStart,aiEnd, iIdentityIter, iSetIter, K)
iNumIdentities = length(aiStart);
iNumSamples = aiEnd(end);
aiPos_AllSamples = aiStart(iIdentityIter):aiEnd(iIdentityIter);
iLeaveOutPosSetSize = floor(length(aiPos_AllSamples) / K);

aiTestingPos = aiPos_AllSamples((iSetIter-1) * iLeaveOutPosSetSize + 1 : min(length(aiPos_AllSamples),iSetIter * iLeaveOutPosSetSize));
aiTrainingPos = setdiff(aiPos_AllSamples,aiTestingPos);

% Now, take 1/K out of every other identity...
aiOtherIdentities = setdiff(1:iNumIdentities, iIdentityIter);
abTrainingNegativeSamples = zeros(1, iNumSamples) > 0;
for iOtherID = aiOtherIdentities
    aiNeg_Other_Ind =  aiStart(iOtherID):aiEnd(iOtherID);
    iNumNegative = length(aiNeg_Other_Ind);
    iLeaveOutNegSetSize = floor(iNumNegative / K);
    aiNegativeTestInd = aiNeg_Other_Ind((iSetIter-1) * iLeaveOutNegSetSize + 1 : min(iNumNegative,iSetIter * iLeaveOutNegSetSize));
    aiNegativeTrainingInd = setdiff(aiNeg_Other_Ind,aiNegativeTestInd);
    abTrainingNegativeSamples(aiNegativeTrainingInd) = 1;
end;
aiTraininNeg = find(abTrainingNegativeSamples);
return;
