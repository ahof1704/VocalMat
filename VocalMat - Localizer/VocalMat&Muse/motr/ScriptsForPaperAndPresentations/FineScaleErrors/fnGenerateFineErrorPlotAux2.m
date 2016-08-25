function fnGenerateFineErrorPlotAux2(afDiff12, afDiff13, afDiff23, afRange, fMaxY, strXTitle)
%;
a2fColors = fnGetFancyColors();

[afHist12, afCent] = hist(afDiff12(:), afRange);
[afHist13, afCent] = hist(afDiff13(:),afRange);
[afHist23, afCent] = hist(afDiff23(:),afRange);
afHist12norm = afHist12 / sum(afHist12);
afHist13norm = afHist13 / sum(afHist13);
afHist23norm = afHist23 / sum(afHist23);
hold on;
plot(afCent,afHist12norm,'color',a2fColors(1,:),'LineWidth',2);
plot(afCent,afHist13norm,'color',a2fColors(2,:),'LineWidth',2);
plot(afCent,afHist23norm,'color',a2fColors(3,:),'LineWidth',2);
set(gca,'xlim',[afRange(1) afRange(end)]);
set(gca,'ylim',[0 fMaxY]);
box on
xlabel(strXTitle);%'mouse X location (pixels)');
ylabel('probability');
