function [strctClassifier,strctPlot,strctClassifierNeg,strctPlotNeg]=fnTrainTdistClassifier(DataPos, DataNeg)

% Using 1D LDA 

iRank = 200;

iNumPos = size(DataPos,1);
iNumNeg = size(DataNeg,1);
%iNumJunk = size(DataJunk,1);

y = zeros(iNumPos+iNumNeg,1);
y(1:iNumPos) = 1;
y(iNumPos+1:end) = 0;
a2fFeatures = [DataPos;DataNeg];
[LDs, Xm ] = fisherLD ( a2fFeatures', y, iRank);
% Zero mean the features
a2fZeroMeanFeatures = a2fFeatures-repmat(Xm',iNumPos+iNumNeg,1); %% zero-mean the data
afProjected = LDs(:,1)' * a2fZeroMeanFeatures';
afDataProjPos = afProjected(y == 1);

Tmp=tlsfit(double(afDataProjPos(:)),0.05);

strctClassifier.m_afMean = Xm;
strctClassifier.m_afLDA = LDs(:,1);
strctClassifier.m_fMu = Tmp(1);
strctClassifier.m_fSigma = Tmp(2);
strctClassifier.m_fNu = Tmp(3);


% Show fits
N=100;
[afHist,afCent]=hist(afDataProjPos,N);
Y=tlspdf(afCent, Tmp(1), Tmp(2), Tmp(3));
Yn = normpdf(afCent, mean(afDataProjPos), std(afDataProjPos));
afHist = afHist / (length(afDataProjPos)*(afCent(2)-afCent(1)));

strctPlot.m_afCent = afCent;
strctPlot.m_afHist = afHist;
strctPlot.m_Y = Y;
strctPlot.m_Yn = Yn;

%% Shay added this for testing cross validation (May 21 2011)
afDataProjNeg = afProjected(y ~= 1);

Tmp=tlsfit(double(afDataProjNeg(:)),0.05);

strctClassifierNeg.m_afMean = Xm;
strctClassifierNeg.m_afLDA = LDs(:,1);
strctClassifierNeg.m_fMu = Tmp(1);
strctClassifierNeg.m_fSigma = Tmp(2);
strctClassifierNeg.m_fNu = Tmp(3);


[afHistNeg,afCentNeg]=hist(afDataProjNeg,N);
afHistNeg = afHistNeg / (length(afDataProjNeg)*(afCentNeg(2)-afCentNeg(1)));
Y=tlspdf(afCentNeg, Tmp(1), Tmp(2), Tmp(3));
Yn = normpdf(afCentNeg, mean(afDataProjNeg), std(afDataProjNeg));

strctPlotNeg.m_afCent = afCentNeg;
strctPlotNeg.m_afHist = afHistNeg;
strctPlotNeg.m_Y = Y;
strctPlotNeg.m_Yn = Yn;

return;
% 
% figure(10);
% clf;hold on;
% plot(strctPlot.m_afCent,strctPlot.m_afHist,'b--');
% plot(strctPlot.m_afCent,strctPlot.m_Y,'b','LineWidth',2)
% 
% plot(strctPlotNeg.m_afCent,strctPlotNeg.m_afHist,'r--');
% plot(strctPlotNeg.m_afCent,strctPlotNeg.m_Y,'r','LineWidth',2)
% set(10,'Color',[1 1 1])
