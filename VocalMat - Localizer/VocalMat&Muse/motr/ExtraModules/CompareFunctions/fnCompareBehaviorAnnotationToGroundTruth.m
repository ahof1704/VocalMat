function fnCompareBehaviorAnnotationToGroundTruth(strAutomaticBehaviors, strGroundTruth, strSelectedBehavior, iNumFrames)

%strAutomaticBehaviorsFile = 'D:\Data\Janelia Farm\Results\10.04.19.390_cropped_120-175\Annotation, Blue 10K, Red, 4.6K.mat';
%strGroundTruthFile = 'D:\Data\Janelia Farm\Results\10.04.19.390_cropped_120-175\AnnotationGT_Test.mat';

if nargin < 4
    iNumFrames = 0;
end
if isstr(strGroundTruth)
    strctGT = load(strGroundTruth);
elseif iscell(strGroundTruth)
    strctGT.astrctBehaviors = strGroundTruth;
end
if isstr(strAutomaticBehaviors)
    strctAlg = load(strAutomaticBehaviors);
elseif iscell(strAutomaticBehaviors)
    strctAlg.astrctBehaviors = strAutomaticBehaviors;
end

if exist('strctMovie', 'var')
    strctMovie = fnReadVideoInfo(strctGT.strMovieFileName);
    iNumFrames = strctMovie.m_iNumFrames;
end
if iNumFrames==0
    display(['Number of frames undefined']);
end
iNumMice = length(strctGT.astrctBehaviors);
% Do the analysis per mouse, and per behavior

for iMouseIter=1:iNumMice
    
    [abBehaviorGT, aiOtherMouseGT] = fnConvertBehaviorStructToVector(strctGT.astrctBehaviors, iMouseIter, strSelectedBehavior,iNumFrames);
    [abBehaviorAlg, aiOtherMouseAlg] = fnConvertBehaviorStructToVector(strctAlg.astrctBehaviors, iMouseIter, strSelectedBehavior,iNumFrames);
    
    iShift = 0;
    ifirstTestFrame = 1;
    iLastTestFrame = 15000;

    abBehaviorGT = abBehaviorGT(1:iLastTestFrame);
    aiOtherMouseGT = aiOtherMouseGT(1:iLastTestFrame);
    abBehaviorAlg = [zeros(1,iShift) abBehaviorAlg(1:(iLastTestFrame-iShift))];
    aiOtherMouseAlg = [zeros(1,iShift) aiOtherMouseAlg(1:(iLastTestFrame-iShift))];
    iMaxFalsePositiveIntervalIndex = [];
    iMaxFalseNegativeIntervalIndex = [];
    
    astrctGTIntervals = fnGetIntervals(abBehaviorGT);
    astrctAlgIntervals = fnGetIntervals(abBehaviorAlg);
    if ~isempty(astrctAlgIntervals)
        aiAlgStart = cat(1,astrctAlgIntervals.m_iStart);
        aiAlgEnd = cat(1,astrctAlgIntervals.m_iEnd);
    else
        aiAlgStart = [];
        aiAlgEnd = [];
    end
    
    iNumAlgIntervals = length(astrctAlgIntervals);
    iNumGTIntervals = length(astrctGTIntervals);
    %% False Positive
    % No ground truth behavior in the given interval
    abFalseAlarms = zeros(1,iNumAlgIntervals) > 0;
    aiFalseAlarmsLen = zeros(1,iNumAlgIntervals);
    for k = 1:iNumAlgIntervals
        abFalseAlarms(k) = all(abBehaviorGT(astrctAlgIntervals(k).m_iStart:astrctAlgIntervals(k).m_iEnd) == 0);
%         aiFalseAlarmsLen(k) = astrctAlgIntervals(k).m_iLength;
        aiFalseAlarmsLen(k) = astrctAlgIntervals(k).m_iEnd - astrctAlgIntervals(k).m_iStart + 1;
    end
    aiFalsePositiveIntervals = find(abFalseAlarms);
    [iMaxFalsePositiveLength, iMaxFalsePositiveIntervalIndexIndex] = max(aiFalseAlarmsLen(aiFalsePositiveIntervals));
    iMaxFalsePositiveIntervalIndex = aiFalsePositiveIntervals(iMaxFalsePositiveIntervalIndexIndex);
    
    if ~isempty(iMaxFalsePositiveIntervalIndex)
        iStartMaxFPInt = astrctAlgIntervals(iMaxFalsePositiveIntervalIndex).m_iStart;
        iEndMaxFPInt = astrctAlgIntervals(iMaxFalsePositiveIntervalIndex).m_iEnd;
    else
        iStartMaxFPInt = [];
        iEndMaxFPInt  = [];
    end
    
    %% False Negative
    % i.e. : miss
    abFalseNegative = zeros(1,iNumGTIntervals) > 0;
    aiFalseNegativeLen = zeros(1,iNumGTIntervals);
    for k = 1:iNumGTIntervals
        abFalseNegative(k) = all(abBehaviorAlg(astrctGTIntervals(k).m_iStart:astrctGTIntervals(k).m_iEnd) == 0);
%         aiFalseNegativeLen(k) = astrctGTIntervals(k).m_iLength;
        aiFalseNegativeLen(k) = astrctGTIntervals(k).m_iEnd - astrctGTIntervals(k).m_iStart + 1;
    end
    aiFalseNegativeIntervals = find(abFalseNegative);
    [iMaxFalseNegativeLength, iMaxFalseNegativeIntervalIndexIndex] = max(aiFalseNegativeLen(aiFalseNegativeIntervals));
    iMaxFalseNegativeIntervalIndex = aiFalseNegativeIntervals(iMaxFalseNegativeIntervalIndexIndex);
    if ~isempty(iMaxFalseNegativeIntervalIndex)
        iStartMaxFNInt = astrctGTIntervals(iMaxFalseNegativeIntervalIndex).m_iStart;
        iEndMaxFNInt = astrctGTIntervals(iMaxFalseNegativeIntervalIndex).m_iEnd;
    else
        iStartMaxFNInt = [];
        iEndMaxFNInt  = [];
    end
    
    %% True Negative
    % not interesting...
    
    %% True Positive
    % Check for coverage and extra false positives, and accuracy in other
    % mouse
    abTruePositive = zeros(1,iNumGTIntervals) > 0;
    afTruePositiveCoverage = zeros(1,iNumGTIntervals);
    aiExtraCoverage = zeros(1,iNumGTIntervals);
    for k = 1:iNumGTIntervals
        iNumFramesOfGroundTruthCovered = sum(abBehaviorAlg(astrctGTIntervals(k).m_iStart:astrctGTIntervals(k).m_iEnd) > 0);
        abTruePositive(k) = sum(iNumFramesOfGroundTruthCovered) > 0;
        afTruePositiveCoverage(k) = iNumFramesOfGroundTruthCovered/astrctGTIntervals(k).m_iLength *100;
        
        aiIntersectingIntervals = find(aiAlgStart<=astrctGTIntervals(k).m_iEnd & aiAlgEnd >= astrctGTIntervals(k).m_iStart);
        for j=1:length(aiIntersectingIntervals)
            aiExtraCoverage(k) = aiExtraCoverage(k) + ...
            sum(astrctAlgIntervals(aiIntersectingIntervals(j)).m_iStart:astrctAlgIntervals(aiIntersectingIntervals(j)).m_iEnd < astrctGTIntervals(k).m_iStart) + ...
            sum(astrctAlgIntervals(aiIntersectingIntervals(j)).m_iStart:astrctAlgIntervals(aiIntersectingIntervals(j)).m_iEnd > astrctGTIntervals(k).m_iEnd);
        end
    end
    aiTruePositives = find(abTruePositive);
    [fMinCoverage, iMinCoverageIndex] = min(afTruePositiveCoverage(aiTruePositives));
    if ~isempty(iMinCoverageIndex)
        iStartMinCovInt = astrctGTIntervals(aiTruePositives(iMinCoverageIndex)).m_iStart;
        iEndMinCovInt = astrctGTIntervals(aiTruePositives(iMinCoverageIndex)).m_iEnd;
    else
        iStartMinCovInt = [];
        iEndMinCovInt = [];
    end
    
    %% Print Statistics
    fprintf('Mouse %d\n',iMouseIter);
   fprintf('True Positives : %d Intervals (%.2f%%), Avg Coverage = %.2f +- %.1f [min = %.1f at frames %d - %d]\n',...
        sum(abTruePositive), sum(abTruePositive)/iNumGTIntervals*100, mean(afTruePositiveCoverage(abTruePositive)), std(afTruePositiveCoverage(abTruePositive)),...
        fMinCoverage,iStartMinCovInt,iEndMinCovInt);
    
   fprintf('False Negatives: %d Intervals (%.2f%%), %d Frames (in total). Largest interval = %d frames (%d - %d)\n',...
        sum(abFalseNegative), sum(abFalseNegative)/iNumGTIntervals*100, sum(aiFalseNegativeLen(abFalseNegative)), iMaxFalseNegativeLength, ...
        iStartMaxFNInt,iEndMaxFNInt);
  
    fprintf('False Positives: %d Intervals, %d Frames in total (%.2f %% of seq). Largest interval = %d frames (%d - %d)\n',...
        sum(abFalseAlarms), sum(aiFalseAlarmsLen(abFalseAlarms)), sum(aiFalseAlarmsLen(abFalseAlarms))/iNumFrames, iMaxFalsePositiveLength, ...
        iStartMaxFPInt, iEndMaxFPInt);
    
end
