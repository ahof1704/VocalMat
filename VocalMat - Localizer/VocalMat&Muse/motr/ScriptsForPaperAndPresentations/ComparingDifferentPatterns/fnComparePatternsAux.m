function [a2fConfusionMatrixTestingSet_Avg, fMeanScore,afStdScore] = fnComparePatternsAux(aiStart,aiEnd,a2fFeatures)
K = 4;
iNumMice = length(aiStart);
iNumIdentities = iNumMice;

a2fConfusionMatrixTrainingSet_Avg = zeros(iNumIdentities,iNumIdentities);
a2fConfusionMatrixTestingSet_Avg = zeros(iNumIdentities,iNumIdentities);

for iSetIter = 1 : K
    fprintf('Cross Validation Set %d out of %d \n',iSetIter,K);
    drawnow update
    
    for iIdentityIter= 1 : iNumIdentities
        fprintf('CV %d, Training %d out of %d\n', iSetIter,iIdentityIter,iNumIdentities);
        [aiTrainingPos,  aiTraininNeg] = fnComputeSetsIndices(aiStart,aiEnd, iIdentityIter, iSetIter, K);
        [astrctClassifierPos(iIdentityIter),astrctTrainingPlots(iIdentityIter),...
            astrctClassifierNeg(iIdentityIter)] = fnTrainTdistClassifier(a2fFeatures(aiTrainingPos,:),...
            a2fFeatures(aiTraininNeg,:));
    end
    % Evaluation on test and training sets...
    a2fConfusionMatrixTrainingSet = zeros(iNumIdentities,iNumIdentities);
    a2fConfusionMatrixTestingSet = zeros(iNumIdentities,iNumIdentities);
    
    for iTrueID = 1:iNumIdentities
       [aiTrainingPos,  aiTraininNeg, aiTestingPos] = fnComputeSetsIndices(aiStart,aiEnd, iTrueID, iSetIter, K);
        for iPredID = 1:iNumIdentities
            
            afProbTrainingPos = fnApplyTDist(astrctClassifierPos(iPredID),a2fFeatures(aiTrainingPos,:));
            afProbTestingPos = fnApplyTDist(astrctClassifierPos(iPredID),a2fFeatures(aiTestingPos,:));
            afProbTrainingNeg = fnApplyTDist(astrctClassifierNeg(iPredID),a2fFeatures(aiTrainingPos,:));
            afProbTestingNeg = fnApplyTDist(astrctClassifierNeg(iPredID),a2fFeatures(aiTestingPos,:));

%             aiBadPos = aiStartBad(iPredID):aiEndBad(iPredID);
%             afProbTestingBadPos = fnApplyTDist(astrctClassifierPos(iPredID),a2fFeaturesBad(aiBadPos,:));
%             afProbTestingBadNeg = fnApplyTDist(astrctClassifierNeg(iPredID),a2fFeaturesBad(aiBadPos,:));
%             
            % Decision...
            % We want to test that Pr(Mouse A|x), vs. Pr( ~MouseA | x)
            % Pr(Mouse A | x) = Pr(x|A)*Pr(A)/Pr(x)
            % Pr(~Mouse A | x) = Pr(x|~A)*Pr(~A)/Pr(x)
            % To mak the decision, we can discard Pr(x). It will be equal            % in both
            % The Apply T dist will give us Prob(x|A) or prob(x|~A)
            % so we still need to multiple by Pr(A) = 1/iNumMice
            % and Pr(~A) = (iNumMice-1)/iNumMice
            iCorrectDecisionTraining = sum(afProbTrainingPos*(1/iNumMice) > afProbTrainingNeg * (iNumMice-1)/iNumMice);
            iCorrectDecisionTesting = sum(afProbTestingPos*(1/iNumMice) > afProbTestingNeg * (iNumMice-1)/iNumMice);
            
%             iCorrectDecisionTestingBad = sum(afProbTestingBadPos*(1/iNumMice) > afProbTestingBadNeg * (iNumMice-1)/iNumMice);
%                         
            a2fConfusionMatrixTrainingSet(iTrueID,iPredID) = iCorrectDecisionTraining/length(aiTrainingPos);
            a2fConfusionMatrixTestingSet(iTrueID,iPredID) =  iCorrectDecisionTesting/length(aiTestingPos);
%             a2fConfusionMatrixTestingSetBad(iTrueID,iPredID) =  iCorrectDecisionTestingBad/length(aiBadPos);
%             
        end
    end
    % normalize each row 
    a2fConfusionMatrixTrainingSet_Avg = a2fConfusionMatrixTrainingSet_Avg + a2fConfusionMatrixTrainingSet;
    a2fConfusionMatrixTestingSet_Avg =a2fConfusionMatrixTestingSet_Avg + a2fConfusionMatrixTestingSet ;
%     a2fConfusionMatrixTestingSetBad_Avg= a2fConfusionMatrixTestingSetBad_Avg+a2fConfusionMatrixTestingSetBad;
end;
a2fConfusionMatrixTrainingSet_Avg = a2fConfusionMatrixTrainingSet_Avg / K;
a2fConfusionMatrixTestingSet_Avg = a2fConfusionMatrixTestingSet_Avg / K;
N = size(a2fConfusionMatrixTrainingSet_Avg,1);
% a2fConfusionMatrixTestingSetBad_Avg=a2fConfusionMatrixTestingSetBad_Avg/K;
afValues = [a2fConfusionMatrixTestingSet_Avg(eye(N)==0);1-a2fConfusionMatrixTestingSet_Avg(eye(N)==1)];
fMeanScore = mean(afValues);
afStdScore = std(afValues);
return;
