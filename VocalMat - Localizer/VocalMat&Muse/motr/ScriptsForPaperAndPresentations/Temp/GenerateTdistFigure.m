% Data is obtained from cage14.
load('DataForFigure_Tdist');
iNumMice = 4;


for iClassifierIter=1:iNumMice
    aiPosInd = aiStart(iClassifierIter):aiEnd(iClassifierIter);
    aiNegInd = setdiff(1:size(a2fFeatures,1),aiPosInd);
    
    fprintf('Training %d \n',iClassifierIter);
    
    [strctIdentityClassifier.m_astrctClassifiers(iClassifierIter),strctPlot,...
        strctIdentityClassifier.m_astrctClassifiersNegClass(iClassifierIter),strctPlotNeg] = ...
        fnTrainTdistClassifier(a2fFeatures(aiPosInd,:),...
        a2fFeatures(aiNegInd,:));
    
   figure(iClassifierIter);clf;subplot(2,1,1);
    l1=bar(strctPlot.m_afCent,strctPlot.m_afHist);hold on;
    set(l1,'FaceColor',[74,126,187]/255,'EdgeColor','none');
    
    l4=bar(strctPlotNeg.m_afCent,strctPlotNeg.m_afHist);hold on;
    set(l4,'FaceColor',0.9*[190,75,72]/255,'EdgeColor','none');
    
    l2=plot(strctPlot.m_afCent,strctPlot.m_Y,'b','LineWidth',2);
    l3=plot(strctPlot.m_afCent,strctPlot.m_Yn,'b--','LineWidth',2);
    
    
    l5=plot(strctPlotNeg.m_afCent,strctPlotNeg.m_Y,'r','LineWidth',2);
    l6=plot(strctPlotNeg.m_afCent,strctPlotNeg.m_Yn,'r--','LineWidth',2);
    legend([l1,l2,l3,l4,l5,l6],{'Pos exemplars','Pos T-dist fit','Pos Normal fit','Neg exemplars','Neg T-dist fit','Neg Normal fit'},'Location','NorthEastOutside');
    hLeftAxes = tightsubplot(2,2,3,'Spacing',0.2);
    
    afPosCDF = cumsum(strctPlot.m_afHist / sum(strctPlot.m_afHist));
    afPosT_distCDF = cumsum(strctPlot.m_Y / sum(strctPlot.m_Y));
    afPosN_distCDF = cumsum(strctPlot.m_Yn / sum(strctPlot.m_Yn));
    
    plot(hLeftAxes,strctPlot.m_afCent,afPosCDF,'LineWidth',2,'color',[74,126,187]/255);hold on;
    plot(hLeftAxes,strctPlot.m_afCent,afPosT_distCDF,'b','LineWidth',2);
    plot(hLeftAxes,strctPlot.m_afCent,afPosN_distCDF,'b--','LineWidth',2);
     axis([-1 2.5 0 1.1])
     
    hRightAxes = tightsubplot(2,2,4,'Spacing',0.2);
    
    afNegCDF = cumsum(strctPlotNeg.m_afHist / sum(strctPlotNeg.m_afHist));
    afNegT_distCDF = cumsum(strctPlotNeg.m_Y / sum(strctPlotNeg.m_Y));
    afNegN_distCDF = cumsum(strctPlotNeg.m_Yn / sum(strctPlotNeg.m_Yn));
    
    plot(hRightAxes,strctPlotNeg.m_afCent,afNegCDF,'LineWidth',2,'color',0.9*[190,75,72]/255);hold on;
    plot(hRightAxes,strctPlotNeg.m_afCent,afNegT_distCDF,'r','LineWidth',2);
    plot(hRightAxes,strctPlotNeg.m_afCent,afNegN_distCDF,'r--','LineWidth',2);
     axis([-1.5 0.5 0 1.1])
     
%     
end;



[strctClassifier,strctPlot,strctClassifierNeg,strctPlotNeg]=fnTrainTdistClassifier(DataPos, DataNeg);
