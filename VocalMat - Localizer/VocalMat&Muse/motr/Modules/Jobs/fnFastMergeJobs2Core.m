function strFileName=fnFastMergeJobs2Core(strMovieFileName, acstrJobOutputFileNames, strIdentitiesFile, strResultFolder)

% Merge single jobs tracks into tracks for the whole video.  The returned
% string is the filename the tracks were saved to, within the folder
% indicated by strResultFolder.

%% Fast Merge jobs
strctID = load(strIdentitiesFile);

strctMovInfo = fnReadVideoInfo(strMovieFileName);
afTimeStamp = strctMovInfo.m_afTimestamp;

iNumFrames = length(afTimeStamp);

iNumMice = length(strctID.strctIdentityClassifier.m_astrctClassifiers);

a2iAllStates = fliplr(perms(1:iNumMice));
iNumStates = size(a2iAllStates,1);
iNumClassifiers = iNumMice;
% Allocate info
fprintf('Allocating memory...');
afNaN = NaN*ones(1,iNumFrames,'single');
a2fNaN= NaN*ones(iNumFrames,iNumClassifiers,'single');
afProcessingTime = NaN*ones(1,iNumFrames,'single');
for k=1:iNumMice
    astrctTrackers(k).m_afX = afNaN;
    astrctTrackers(k).m_afY = afNaN;
    astrctTrackers(k).m_afA = afNaN;
    astrctTrackers(k).m_afB = afNaN;
    astrctTrackers(k).m_afTheta = afNaN;
    astrctTrackers(k).m_a2fClassifer = a2fNaN;
end;
fprintf('Done!\n');
clear a2fNaN afNaN

% Read Job info
iNumJobs = length(acstrJobOutputFileNames);
acstrJobFiles = cell(1, iNumJobs);
fprintf('Loading jobs, first pass, please wait...');
a2iFrameRange = zeros(iNumJobs,2);
for iJobIter=1:iNumJobs
    try
    strctJob = load(acstrJobOutputFileNames{iJobIter});
    a2iFrameRange(iJobIter,:) = ...
        [strctJob.strctJobInfo.m_aiFrameInterval(1), strctJob.strctJobInfo.m_aiFrameInterval(end)];
    catch
    end
end;
fprintf('Done!\n');

% Sort jobs according to start frame
% process jobs according to their initial frame...

[afDummy, aiSortedIndices] = sort(a2iFrameRange(:,1));
a2iFrameRange = a2iFrameRange(aiSortedIndices,:);
acstrJobOutputFileNames = acstrJobOutputFileNames(aiSortedIndices);

abResultsFound = zeros(1,a2iFrameRange(end))>0;
for k=1:iNumJobs
    abResultsFound(a2iFrameRange(k,1):a2iFrameRange(k,2))=1;
end;
[astrctMissingIntervals,aiStart,aiEnd] = fnGetIntervals(~abResultsFound);
if ~isempty(astrctMissingIntervals)
    fprintf('Warning. The following job results were not found. \n');
    setdiff(1:iNumJobs,aiJobNumbers)
    fprintf('Cannot proceed with fast merging this video\n');
    return;
end;

fprintf('Loading jobs, second pass, please wait...');
for iJobIter=1:iNumJobs
    
    strctJob = load(acstrJobOutputFileNames{iJobIter});
    iFirstFrame = strctJob.strctJobInfo.m_aiFrameInterval(1);
    
    if iFirstFrame ~= 1
        bNaNAtMerge = false;
        for iMouseIter=1:iNumMice
            bNaNAtMerge = bNaNAtMerge | isnan(astrctTrackers(iMouseIter).m_afX(iFirstFrame-1));
        end;
        if bNaNAtMerge && iFirstFrame ~= 1
            fprintf('\nCRITICAL WARNING in merge process, Check job : %d\n', iJobIter);
        end;
    end

    % Match mouse position...
    
    if iFirstFrame > 1
        astrctTrackersAtFrame = fnGetTrackersAtFrame(astrctTrackers, iFirstFrame-1);
        astrctTrackersJobAtFrame = fnGetTrackersAtFrame(strctJob.astrctTrackersJob, 1);
        aiAssignment = fnMatchJobToPrevFrame(astrctTrackersAtFrame, astrctTrackersJobAtFrame);
    else
        aiAssignment = [1:iNumMice;1:iNumMice];
        
    end
    
    aiFrames = strctJob.strctJobInfo.m_aiFrameInterval;
    afProcessingTime(aiFrames) = strctJob.afProcessingTime;
    
    for iMouseIter=1:iNumMice
        iTracker = aiAssignment(1,iMouseIter);
        iMatchedTracker = aiAssignment(2,iMouseIter);
        astrctTrackers(iTracker).m_afX(aiFrames) = ...
            strctJob.astrctTrackersJob(iMatchedTracker).m_afX(1:length(aiFrames));
        astrctTrackers(iTracker).m_afY(aiFrames) = ...
            strctJob.astrctTrackersJob(iMatchedTracker).m_afY(1:length(aiFrames));
        astrctTrackers(iTracker).m_afA(aiFrames) = ...
            strctJob.astrctTrackersJob(iMatchedTracker).m_afA(1:length(aiFrames));
        astrctTrackers(iTracker).m_afB(aiFrames) = ...
            strctJob.astrctTrackersJob(iMatchedTracker).m_afB(1:length(aiFrames));
        astrctTrackers(iTracker).m_afTheta(aiFrames) = ...
            strctJob.astrctTrackersJob(iMatchedTracker).m_afTheta(1:length(aiFrames));
        astrctTrackers(iTracker).m_a2fClassifer(aiFrames,:) = ...
            strctJob.astrctTrackersJob(iMatchedTracker).m_a2fClassifer(1:length(aiFrames),:);
    end;
end;
fprintf('Done!\n');

fprintf('Interpolating missing values...');
% Interpolate short intervals of missing frames
iNumFrames = length(astrctTrackers(1).m_afX);
for iMouseIter=1:iNumMice
    astrctIntervals = fnGetIntervals( isnan(astrctTrackers(iMouseIter).m_afX));
    for iIntervalIter=1:length(astrctIntervals)
        if astrctIntervals(iIntervalIter).m_iLength > 8
            fprintf('Warning, missing values (%d) for mouse %d between %d-%d\n',...
            astrctIntervals(iIntervalIter).m_iLength, iMouseIter, ...
                astrctIntervals(iIntervalIter).m_iStart,...
                astrctIntervals(iIntervalIter).m_iEnd);
        end;
        iLeftFrame = max(1,astrctIntervals(iIntervalIter).m_iStart-1);
        iRightFrame = min(iNumFrames,astrctIntervals(iIntervalIter).m_iEnd+1);
        astrctTrackers = fnInterpolateBetweenFrames(...
            astrctTrackers, iMouseIter, iLeftFrame, iRightFrame, false);
    end;
end;
fprintf('Done!\n');

fprintf('Saving RAW sequence...');
save(fullfile(strResultFolder,['SequenceRAW_',date,'.mat']), ...
     'astrctTrackers', ...
     'strMovieFileName', ...
     'afTimeStamp', ...
     'afProcessingTime');
fprintf('Done!\n');

% Now, run viterbi...

aiBigJumps = 1+ (find(strctMovInfo.m_afTimestamp(2:end)-strctMovInfo.m_afTimestamp(1:end-1) > 1/strctMovInfo.m_fFPS * 10));
abLargeTimeGap = zeros(1,iNumFrames)>0;
abLargeTimeGap(aiBigJumps) = 1;


fprintf('%d large time gaps were detected. \n', sum(abLargeTimeGap));
fSwapPenalty = -300;
astrctTrackers = fnCorrectIdentitiesOnTheFly(astrctTrackers, strctID.strctIdentityClassifier, abLargeTimeGap, false,fSwapPenalty);
strFileName=['SequenceViterbi_',date,'_Pen_',num2str(fSwapPenalty),'.mat'];
fprintf('Saving Viterbi sequence as %s\n',strFileName);
% fprintf('Saving Viterbi sequence as %s\n',['SequenceViterbi_',date,'.mat']);
save(fullfile(strResultFolder,strFileName), ...
     'astrctTrackers','strMovieFileName','afTimeStamp','afProcessingTime');

fprintf('Done!\n');

return
