function fnPlotIntervals(acIntervals, acLegend)
   fZero = min(a2fAllIntervals(:,1));
    a2fColors =fnGetDefaultUnitColors();
    hIntervalFigure = figure;
    set(hIntervalFigure,'name',strSession);
    clf;
    iNumIntervals = size(a2fAllIntervals,1);
    fHeight=0.2;
    hTimeLine=cla;
    hold on;
    set(gcf,'color',[1 1 1])
    ahIntervalPatch= zeros(1, iNumIntervals);
    ahIntervalText= zeros(1, iNumIntervals);
    for k=1:iNumIntervals
        fXstart = a2fAllIntervals(k,1)-fZero;
        fXend = a2fAllIntervals(k,2)-fZero;
        fY = a2fAllIntervals(k,3);
        ahIntervalPatch(k) = patch('xdata',[fXstart,fXstart,fXend,fXend],'ydata',...
            [fY-fHeight fY+fHeight,fY+fHeight,fY-fHeight],'facecolor',a2fColors(k,:),'parent',hTimeLine);
        ahIntervalText(k) = text((fXstart+fXend)/2,fY,sprintf('%d',a2fAllIntervals(k,6)),'parent',hTimeLine,'fontweight','bold');
    end
    iMaxY = length(aiYToChannel);
    fMaxX = max(a2fAllIntervals(:,2))-fZero;
    for k=1:length(aiOffsets)
       plot([0 fMaxX],[aiOffsets(k)+0.5,aiOffsets(k)+0.5],'k--');
    end
    
    set(hTimeLine,'ytick',1:iMaxY,'yticklabel',aiYToChannel);
    axis ij
    xlabel('Time (sec)');
    ylabel('Channel');
    %%