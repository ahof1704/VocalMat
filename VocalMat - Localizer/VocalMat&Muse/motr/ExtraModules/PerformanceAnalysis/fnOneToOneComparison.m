function fnOneToOneComparison(a3fDataRes,a3fDataGT)
% First, compare 1-1, assume identeties are correct.
% Show error in ellipse parameters for each mouse as a function of time.
iNumFrames = size(a3fDataRes,2);
iNumMice =  size(a3fDataRes,3);
a3fDiff = (a3fDataRes-a3fDataGT);

fPositionalErrorPix = 10;
fAngleErrorDeg = 10;
fSizeErrorPix = 5;

fprintf('Total number of frames: %d (%.2f Min)\n',iNumFrames, iNumFrames/3600);
fprintf('--------------------------------------------------------------------------------------------\n');
for iMouseIter=1:iNumMice
    afPositionalError = sqrt(a3fDiff(1,:,iMouseIter).^2+a3fDiff(2,:,iMouseIter).^2 );
    afSizeError = sqrt(a3fDiff(3,:,iMouseIter).^2+a3fDiff(4,:,iMouseIter).^2 );
    afAngleError = abs(a3fDiff(5,:,iMouseIter))/pi*180;
    afAngleError = min(afAngleError, abs(180-afAngleError));

    fprintf('------------------------------\n');
    fprintf('Report statistics for mouse %d\n',iMouseIter);
    fnPrintIntervalStatistics(afPositionalError > fPositionalErrorPix, 'Positional error ')
    fnPrintIntervalStatistics(afSizeError > fSizeErrorPix, 'size error ')
    fnPrintIntervalStatistics(afAngleError > fAngleErrorDeg, 'angular error ')
end
return;

