function strctIdentityClassifier = fnTrainTdistIdentities(a2fFeatures, aiStart, aiEnd,iHOG_Dim)
iNumMice = length(aiStart);
% figure;
% clf;
for iClassifierIter=1:iNumMice
    aiPosInd = aiStart(iClassifierIter):aiEnd(iClassifierIter);
    aiNegInd = setdiff(1:size(a2fFeatures,1),aiPosInd);
    
    
    fprintf('Training %d \n',iClassifierIter);
    
    [strctIdentityClassifier.m_astrctClassifiers(iClassifierIter),strctPlot,...
        strctIdentityClassifier.m_astrctClassifiersNegClass(iClassifierIter)] = ...
        fnTrainTdistClassifier(a2fFeatures(aiPosInd,:),...
        a2fFeatures(aiNegInd,:));
    
%     subplot(2,2,iClassifierIter);
%     bar(strctPlot.m_afCent,strctPlot.m_afHist);hold on;
%     plot(strctPlot.m_afCent,strctPlot.m_Y,'r',strctPlot.m_afCent,strctPlot.m_Yn,'g','LineWidth',2);
%     legend('Data','T-dist','Normal','location','northeastoutside');
    
end;


return;