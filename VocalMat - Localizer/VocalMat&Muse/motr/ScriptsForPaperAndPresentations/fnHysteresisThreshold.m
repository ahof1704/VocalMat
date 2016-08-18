function astrctIntervals = fnHysteresisThreshold(afData, fLowThres, fHighThres, iMinimumLength)
% segmentation using thresholding with hysteresis.
% Data is first thresholded with a high threshold to find reliable points.
% Low threshold data that is near by is added to the reliable points. 
% Intervals smaller than iMinimumLength are discarded as "noise"
aiLabelsHigh = bwlabeln(afData > fHighThres);
[aiLabelsLow,iNumCC] = bwlabeln(afData > fLowThres);
aiCCsize = histc(aiLabelsLow,1:iNumCC);
aiSelectedLabels = setdiff(unique(aiLabelsLow(aiLabelsLow > 0 &  aiLabelsHigh > 0)), find(aiCCsize <= iMinimumLength));
astrctIntervals = fnGetIntervals(ismember(aiLabelsLow, aiSelectedLabels));
return;
