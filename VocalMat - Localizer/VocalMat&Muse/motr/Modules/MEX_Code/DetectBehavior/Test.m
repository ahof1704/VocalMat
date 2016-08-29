addpath('D:\Code\Janelia Farm\CurrentVersion\MEX\x64');

strctFollowingParams.m_fVelocityThresholdPix = 10;
strctFollowingParams.m_fSameOrientationAngleThresDeg=90;
strctFollowingParams.m_fDistanceThresholdPix= 250;
strctFollowingParams.m_iMergeIntervalsFrames= 30;
strctFollowingParams.m_iDiscardInterval=2;

g_strctExperiment = load('D:\Data\Janelia Farm\Results\MergedExperiments\Experiment1');
iMouseA = 4;
iMouseB = 3;

abDetected = fndllDetectBehavior('Following',...
    g_strctExperiment.a2fX,...
    g_strctExperiment.a2fY,...
    g_strctExperiment.a2fA,...
    g_strctExperiment.a2fB,...
    g_strctExperiment.a2fTheta, iMouseA,iMouseB, strctFollowingParams);
astrctIntervals = fnDiscardSmallIntervals(fnMergeIntervals(fnGetIntervals(abDetected),strctFollowingParams.m_iMergeIntervalsFrames), strctFollowingParams.m_iDiscardInterval);
