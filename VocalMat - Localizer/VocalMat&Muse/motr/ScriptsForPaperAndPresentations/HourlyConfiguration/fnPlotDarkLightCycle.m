function fnPlotDarkLightCycle(h)
hold on;
% Draw Days (dark, light)
Scale = 1;
for iDayIter=0:4
    % Dark Period
    x = iDayIter * 24 * Scale;
    y = 0;
    w = 12 * Scale;
    rectangle('Position',[x,y,w,h],'facecolor',[0.3 0.3 0.3]);
    % Dark Period
    x = iDayIter * 24 * Scale + 12*Scale;
    y = 0;
    w = 12 * Scale;
    rectangle('Position',[x,y,w,h],'facecolor',[0.9 0.9 0.9]);
end
set(gca,'xtick',0:12:24*5,'xlim',[0 24*5],'ylim',[0 h]);
