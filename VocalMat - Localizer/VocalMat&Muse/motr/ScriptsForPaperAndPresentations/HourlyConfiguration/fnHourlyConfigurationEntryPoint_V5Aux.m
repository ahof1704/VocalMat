function fnHourlyConfigurationEntryPoint_V5Aux(strctData,aiInterval, afScale,fSmooth)
for iMouseIter=1:4
    X =  strctData.X(aiInterval,iMouseIter);
    Y =  strctData.Y(aiInterval,iMouseIter);
    abValid = ~isnan(X) & ~isnan(Y);
    a2fCenter=hist2(X(abValid),Y(abValid),1:1024,1:768);
    a2fPercentTime= conv2(a2fCenter,fspecial('gaussian',[50 50],fSmooth),'same')/sum(a2fCenter(:))*1e2;
    a2fLog = log10(a2fPercentTime);
    figure(iMouseIter);
    clf;
    imagesc(a2fLog,afScale);
       axis([50 800 50 750]);
    axis off
          P=get(gcf,'Position');
     P(3:4) = [116 86];
     P(1) = iMouseIter*200;
     set(gcf,'Position',P);
     colormap jet
end
   X =  strctData.X(aiInterval,:);
    Y =  strctData.Y(aiInterval,:);
    abValid = ~isnan(X) & ~isnan(Y);
    a2fCenter=hist2(X(abValid),Y(abValid),1:1024,1:768);
    a2fPercentTime= conv2(a2fCenter,fspecial('gaussian',[50 50],fSmooth),'same')/sum(a2fCenter(:))*1e2;
    a2fLog = log10(a2fPercentTime);
    
    figure(5);
    clf;
    imagesc(a2fLog, afScale);
       axis([50 800 50 750]);
    axis off
       P=get(gcf,'Position');
     P(3:4) = [116 86];
     P(1) = 5*200;
     set(gcf,'Position',P);
