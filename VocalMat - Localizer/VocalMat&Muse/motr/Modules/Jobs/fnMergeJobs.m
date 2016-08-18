function astrctTrackers = fnMergeJobs(strctMovieInfo, acstrJobFiles, astrctTrackers)
%
aiBigJumps = 1 + (find(strctMovieInfo.m_afTimestamp(2:end)-strctMovieInfo.m_afTimestamp(1:end-1) > 1/strctMovieInfo.m_fFPS * 10));
[aiJobInd, a2iAssignment] = fnChooseJobsToMergeDijkstra(acstrJobFiles, aiBigJumps);

iMaxInterval = 8;

for iInterval=1:length(aiJobInd)
   iJobIter = aiJobInd(iInterval);
   fprintf('Merging job %d out of %d\n',iInterval,length(aiJobInd));
   strctJob = load(acstrJobFiles{iJobIter});
   if  iInterval == 1
      iNumMice = length(strctJob.astrctTrackersJob);
   end
   if isempty(astrctTrackers)
      astrctTrackers = fnCreateEmptyTrackStruct(iNumMice, strctMovieInfo.m_iNumFrames);
   end
   aiFrames = strctJob.strctJobInfo.m_aiFrameInterval;
   bFrameDrop = sum(aiBigJumps == aiFrames(1)) > 0;
   
   % Match mouse position...
   for iMouseIter=1:iNumMice
%       iTracker = aiAssignment(1,iMouseIter);
      iMatchedTracker = a2iAssignment(iInterval,iMouseIter);
      astrctTrackers(iMouseIter).m_afX(aiFrames) = ...
         strctJob.astrctTrackersJob(iMatchedTracker).m_afX(1:length(aiFrames));
      astrctTrackers(iMouseIter).m_afY(aiFrames) = ...
         strctJob.astrctTrackersJob(iMatchedTracker).m_afY(1:length(aiFrames));
      astrctTrackers(iMouseIter).m_afA(aiFrames) = ...
         strctJob.astrctTrackersJob(iMatchedTracker).m_afA(1:length(aiFrames));
      astrctTrackers(iMouseIter).m_afB(aiFrames) = ...
         strctJob.astrctTrackersJob(iMatchedTracker).m_afB(1:length(aiFrames));
      astrctTrackers(iMouseIter).m_afTheta(aiFrames) = ...
         strctJob.astrctTrackersJob(iMatchedTracker).m_afTheta(1:length(aiFrames));
      astrctTrackers(iMouseIter).m_a2fClassifer(aiFrames,:) = ...
         strctJob.astrctTrackersJob(iMatchedTracker).m_a2fClassifer(1:length(aiFrames),:);
   end;
end;

for iMouseIter=1:iNumMice
    astrctIntervals = fnGetIntervals( isnan(astrctTrackers(iMouseIter).m_afX));
    for iIntervalIter=1:length(astrctIntervals)
        if astrctIntervals(iIntervalIter).m_iLength < iMaxInterval
            iLeftFrame = max(1,astrctIntervals(iIntervalIter).m_iStart-1);
            iRightFrame = min(strctMovieInfo.m_iNumFrames,astrctIntervals(iIntervalIter).m_iEnd+1);
            astrctTrackers = fnInterpolateBetweenFrames(astrctTrackers, iMouseIter, iLeftFrame, iRightFrame, false);
        end;
    end;

end;
    