function fnPlotIntervals(acIntervals, acLegend)
iNumIntervals = length(acIntervals);
a2fColors =lines(iNumIntervals);
clf;
fHeight=0.2;
hTimeLine=cla;
hold on;
set(gcf,'color',[1 1 1])
ahIntervalPatch= zeros(1, iNumIntervals);
ahIntervalText= zeros(1, iNumIntervals);
for k=1:iNumIntervals
    iNumInstances = length(acIntervals{k});
    for i=1:iNumInstances
        
        fXstart = acIntervals{k}(i).m_iStart;
        fXend = acIntervals{k}(i).m_iEnd;
        fY = k;
        ahIntervalPatch(k) = patch('xdata',[fXstart,fXstart,fXend,fXend],'ydata',...
            [fY-fHeight fY+fHeight,fY+fHeight,fY-fHeight],'facecolor',a2fColors(k,:),'parent',hTimeLine,'edgecolor','none');
    end
end
    xlabel('Time (sec)');
    ylabel('Channel');
    %%