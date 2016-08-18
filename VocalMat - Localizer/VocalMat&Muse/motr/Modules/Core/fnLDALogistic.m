function [strctClassifier, iTP,iTN,iFP,iFN, afDataProjPos, afDataProjNeg]=fnLDALogistic(DataPos, DataNeg)
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

afDataProjPos = DataPos * W - fThres;
afDataProjNeg = DataNeg * W - fThres;

%
%

% [afHistPos, afCentPos] = hist(afDataProjPos);
% [afHistNeg, afCentNeg] = hist(afDataProjNeg);
% figure(10);
% clf;
% hold on;
% bar(afCentPos,afHistPos);
% bar(afCentNeg,afHistNeg,'faceColor','r');
% 


% Divide by a scale factor to obtain a better numerical stability for the
% glm. This will not change anything since the decision rule is
% X*W-Thres>0. It will bring the two classes roughly to -1 and 1
fScaleFactor = mean([abs(afDataProjPos);abs(afDataProjNeg)]);
W = W / fScaleFactor;
fThres = fThres/ fScaleFactor;

afDataProjPos = DataPos * W - fThres;
afDataProjNeg = DataNeg * W - fThres;


n1 = size(DataPos,1);
n2 = size(DataNeg,1);

Yglm = [ones(n1,1);zeros(n2,1)];


% Turn off the warnings about perfect separation and iteration limits reached 
% so they don't scare the user
originalState=warning('query','stats:glmfit:PerfectSeparation');
originalState=originalState.state;
warning('off','stats:glmfit:PerfectSeparation');

originalState2=warning('query','stats:glmfit:IterationLimit');
originalState2=originalState2.state;
warning('off','stats:glmfit:IterationLimit');

% Do the logisitic regression
afBCoeff = glmfit([afDataProjPos;afDataProjNeg], Yglm,'binomial');

% Turn the warnings back on
warning(originalState2,'stats:glmfit:IterationLimit');
warning(originalState,'stats:glmfit:PerfectSeparation');


% 
% [afHistPos, afCentPos] = hist(afDataProjPos);
% [afHistNeg, afCentNeg] = hist(afDataProjNeg);
% figure(1);
% clf;
% hold on;
% bar(afCentPos,afHistPos);
% bar(afCentNeg,afHistNeg,'faceColor','r');
% afRange = linspace(min(afCentNeg), max(afCentPos),1000);
% plot(afRange, max([afHistPos,afHistNeg])* sigmoid(afBCoeff(1) * 1 + afBCoeff(2) * afRange))



strctClassifier.m_afW = W;
strctClassifier.m_fThres = fThres;
strctClassifier.m_afBCoeff = afBCoeff;

% sigmoid = @(a) 1./(1+exp(-a));
% afProbPos = sigmoid([ones(n1,1), afDataProjPos] * afBCoeff);
% afProbNeg = sigmoid([ones(n2,1), afDataProjNeg] * afBCoeff);
% 
% figure(2);
% clf;
% hold on;
% [afHistPosLog, afCentPosLog] = hist(afProbPos,linspace(0,1,1000));
% [afHistNegLog, afCentNegLog] = hist(afProbNeg,linspace(0,1,1000));
% bar(afCentPosLog,afHistPosLog);
% bar(afCentNegLog,afHistNegLog,'facecolor','r');


iFP = sum(afDataProjPos < 0);
iFN = sum(afDataProjNeg > 0);
iTP = sum(afDataProjPos >= 0);
iTN = sum(afDataProjNeg <= 0);


return;
