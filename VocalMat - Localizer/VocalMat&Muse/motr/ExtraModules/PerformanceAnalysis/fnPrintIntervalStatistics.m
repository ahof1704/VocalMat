function fnPrintIntervalStatistics(abVector, strDesc)
iNumFrames = length(abVector);
astrctIntervals = fnGetIntervals(abVector);
if ~isempty(astrctIntervals)
    aiIntervalLengths = cat(1,astrctIntervals.m_iLength);
    fMeanIntervalLenFrames = mean(aiIntervalLengths);
    [fMaxIntervalLenFrames,iMaxIndex] = max(aiIntervalLengths);
    fTotalIntervalsTime = sum(aiIntervalLengths);
    fprintf('Number of %s intervals : %d\n', strDesc, length(astrctIntervals));
    fprintf('Mean  : %.2f Frames (%.2f Sec)\n',fMeanIntervalLenFrames, fMeanIntervalLenFrames/30);
    fprintf('Max   : %.2f Frames (%.2f Sec) [%d - %d]\n',fMaxIntervalLenFrames, fMaxIntervalLenFrames/30, ...
        astrctIntervals(iMaxIndex).m_iStart,astrctIntervals(iMaxIndex).m_iEnd);
    fprintf('Total : %.2f Frames (%.2f Sec, %.2f %% from seq)\n',fTotalIntervalsTime,fTotalIntervalsTime/30,...
        fTotalIntervalsTime/iNumFrames*100);
else
    fprintf('Number of %s intervals : 0\n', strDesc);
end;

return;
