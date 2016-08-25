function hHandle = fnFancyPlot2(afX, afY, afS, afColor1,afColor2)
aiNonNaN = ~isnan(afY);
afX = afX(aiNonNaN);
afY = afY(aiNonNaN);
afS = afS(aiNonNaN);

hHandle=fill([afX, afX(end:-1:1)],[afY+afS, afY(end:-1:1)-afS(end:-1:1)], afColor1,'facealpha',0.8);
plot(afX,afY, 'color', afColor2,'LineWidth',2);
return;