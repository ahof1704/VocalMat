load('D:\Data\Janelia Farm\Results\MergedExperiments\Experiment1.mat');
% N = 1000;
% a2fHeatMap = fndllHeatMap(a2fX(:,1:N),a2fY(:,1:N),a2fA(:,1:N),a2fB(:,1:N),a2fTheta(:,1:N), 4, 20);
% [X,Y]=meshgrid(1:1024,1:768);
%
% figure;imshow(a2fHeatMap,[]);

strctParams.m_fVelocityThresholdPix = 10;
strctParams.m_fSameOrientationAngleThresDeg = 90;
strctParams.m_fDistanceThresholdPix = 250;
strctParams.m_iMergeIntervalsFrames = 30;

astrctIntervalsFollowing = cell(4,4);
for iMouseA = 1:4
    for iMouseB = 1:4
        if iMouseA == iMouseB
            continue;
        else
            abDetected = fndllDetectBehavior('Following',a2fX,a2fY,a2fA,a2fB,a2fTheta, iMouseB,iMouseA, strctParams);
            astrctIntervalsFollowing{iMouseA,iMouseB} = fnMergeIntervals(fnGetIntervals(abDetected),strctParams.m_iMergeIntervalsFrames);
        end
    end
end;

save('astrctIntervalsFollowing','astrctIntervalsFollowing');

A = cat(1,astrctIntervalsFollowing{1,2}.m_iLength);
sum(A(A>1))
