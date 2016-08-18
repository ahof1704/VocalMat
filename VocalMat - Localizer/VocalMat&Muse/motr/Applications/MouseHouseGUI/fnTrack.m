function fnTrack(hFig)

global g_strctGlobalParam g_iLogLevel g_CaptainsLogDir;  %#ok

% get the model info
u=get(hFig,'userdata');
expDirName=u.expDirName;
clipFNAbs=u.clipFNAbs;
trackStatus=u.trackStatus;
clusterMode=u.clusterMode;

% % get the info about this experiment --ALT
% [iStatus, sExpName, aiNumJobs, acExperimentClips] = fnGetExpInfo();
%      % iStatus: Status of what, exactly?
%      % sExpName: Absolute path to experiment directory
%      % aiNumJobs: The number of jobs for clip, maybe?
%      % acExperimentClips: Provides the absolute path of each clip, and its
%      %                    processing status
%      % --ALT

% get all the directory and file names we'll need
tuningDirName = fullfile(expDirName, 'Tuning');
jobsRootDirName = fullfile(expDirName, 'Jobs');
resultsDirName = fullfile(expDirName, 'Results');
tracksDirName = fullfile(resultsDirName, 'Tracks');
%startupDirName = [pwd() filesep];
global g_strMouseStuffRootDirName
startupDirName = [g_strMouseStuffRootDirName filesep];
%detectionFN = fullfile(tuningDirName, 'Detection.mat');
classifiersFN = fullfile(tuningDirName, 'Identities.mat');

% make sure the tracks file exists
if ~exist(tracksDirName,'dir')  % avoid warning if dir exists already --ALT
  mkdir(tracksDirName);
end

% For each clip, see if processing has started on it by looking at 
% trackStatus.  If processing has started, determine how many
% jobs there are for that clip by counting these files.
nClip=length(clipFNAbs);
aiNumJobs=repmat(-1,[nClip 1]);
for i=1:nClip
  % Check for the per-job Jobargin files
  if trackStatus(i)>=3  % means "in process" or "done"
    clipFNAbsThis=clipFNAbs{i};
    [dummy,baseName]=fileparts(clipFNAbsThis);  %#ok
      % the seq file name, w/o .seq
    dirName=fullfile(expDirName,'Jobs',baseName);
    filter='Jobargin*.mat';
    pattern=fullfile(dirName,filter);
    d=dir(pattern);
    filterRerun='JobarginRerun*.mat';
    patternRerun=fullfile(dirName,filterRerun);
    dRerun=dir(patternRerun);
    nJobarginFileThis=length(d)-length(dRerun);
    aiNumJobs(i)=nJobarginFileThis;
  end
end

% Figure out what all to run for each clip
submitSegs=true(nClip,1);
submitPost=true(nClip,1);
aiNumCurrJobs=repmat(-1,[nClip 1]);
aiMissing=cell(nClip,1);
for i=1:nClip
  clipFNAbsThis = clipFNAbs{i};  % file name of this clip --ALT
  %clipFNThisAbs=fullfile(expDirName,clipFNThis);
  [dummy, clipBaseName] = fileparts(clipFNAbsThis);  %#ok
  %sTrackFile = fullfile(tracksDirName, [clipBaseName '.mat']);
  sTrackFile = fullfile(tracksDirName, [clipBaseName '_tracks.mat']);
  %bMissing = false;  % == ~isempty(aiMissing) --ALT
  if trackStatus(i) == 2  % haven't started processing the clip
    % nothing to do
  elseif trackStatus(i) == 3   % if the clip is already in process
    %[bJobsFinished, aiMissing] = fnHaveAllJobsFinished(acstrJobFiles,i);
    answer = ...
      questdlg(['Clip ' clipFNAbs{i} ...
                ' is already being tracked! Do you want to rerun ' ...
                'missing segments?'],...
               'Question',...
               'Yes','No',...
               'Yes');
    if isempty(answer)
      % user hit Cancel
      return;
    elseif strcmpi(answer,'no')
      % user said: "no, don't rerun missing segments"
      %aiSubmit(i,:) = false;
      submitSegs(i) = false;
      submitPost(i) = false;
    else
      % user said: "yes, rerun missing segments" 
      jobFN=getJobFileNames(resultsDirName,clipFNAbsThis,aiNumJobs(i));
      aiMissing{i} = findUnfinishedJobsOneClip(jobFN);
      allJobsFinished=isempty(aiMissing{i});
      if allJobsFinished
        % no jobs are missing
        %aiSubmit(i,1) = false;
        submitSegs(i)=false;
        submitPost(i)=true;
      else
        % at least one job is missing
        %bMissing = true;
        submitSegs(i)=true;
        submitPost(i)=true;
      end
    end
  elseif trackStatus(i) == 4
    % track file already exists
    answer = ...
      questdlg(['Track-file ' sTrackFile ' already exists. Do you ' ...
                'want to track clip ' clipBaseName ' anyway?'],...
               'Question',...
               'Yes','Yes, but only postprocessing','No',...
               'No');
    if isempty(answer)
      % user hit Cancel
      return;
    elseif strcmpi(answer,'No')
      % user doesn't want to track this clip
      %aiSubmit(i,:) = false;
      submitSegs(i)=false;
      submitPost(i)=false;
    elseif ~strcmpi(answer,'Yes')
      % if we get here, they said 'Yes, but only postprocessing'
      %aiSubmit(i,1) = false;
      submitSegs(i)=false;
      submitPost(i)=true;
    end
  else
    error('Internal error: trackStatus for file %s is not 2, 3, or 4.', ...
          clipFNAbs{i});
  end
end

% At this point, current values of submitSegs, submitPost, and aiMissing
% will determine what segments of what clips we run, and for which clips we
% do post-processing.

% Run what segs we will.
if ~clusterMode
  set(hFig,'pointer','watch');
  drawnow('expose');
  drawnow('update');
end   
for i=1:nClip
  clipFNAbsThis = clipFNAbs{i};  % file name of this clip --ALT
  %[dummy, clipBaseName] = fileparts(clipFNThis);
  %sTrackFile = fullfile(tracksDirName, [clipBaseName '.mat']);
  % check if the current clip should be processed, and if so, submit the
  % jobs
  if submitSegs(i)
    if trackStatus(i)==2 || trackStatus(i)==4
      % do all jobs for the clip
      aiNumJobs(i) = ...
        fnSubmitMovieToProcessing(clipFNAbsThis, ...
                                  jobsRootDirName, ...
                                  resultsDirName, ...
                                  classifiersFN, ...
                                  startupDirName, ...
                                  ~clusterMode, ...
                                  false);
      aiNumCurrJobs(i)=aiNumJobs(i);
    elseif trackStatus(i)==3
      % just do the missing ones
      aiNumCurrJobs(i) = ...
        fnSubmitMovieToProcessing(clipFNAbsThis, ...
                                  jobsRootDirName, ...
                                  resultsDirName, ...
                                  classifiersFN, ...
                                  startupDirName, ...
                                  ~clusterMode, ...
                                  false, ...
                                  aiMissing{i});
    elseif trackStatus(i)==4
      % do all jobs for the clip
      aiNumCurrJobs(i) = ...
        fnSubmitMovieToProcessing(clipFNAbsThis, ...
                                  jobsRootDirName, ...
                                  resultsDirName, ...
                                  classifiersFN, ...
                                  startupDirName, ...
                                  ~clusterMode, ...
                                  false);      
    else
      error('Internal error: trackStatus for file %s is not 2, 3, or 4.', ...
            clipFNAbs{i});
    end
    % update the GUI to reflect that this clip is in process
    fnSetClipTrackStatusCode(hFig, i, 3);
  else
    aiNumCurrJobs(i)=0;
  end
end

% All the clip jobs have now been submitted, but not yet any 
% post-processing jobs.

% Submit the post-processing jobs
if ~clusterMode
  % local mode
  for i=1:nClip
    %if aiSubmit(i,2)
    if submitPost(i)
      clipFNAbsThis = clipFNAbs{i};
      jobFN=getJobFileNames(resultsDirName,clipFNAbsThis,aiNumJobs(i));
      fnWaitForAllJobsToFinish(jobFN);
      strctMovieInfo = fnReadVideoInfo(clipFNAbsThis);
      [dummy, clipBaseName] = fileparts(clipFNAbsThis);  %#ok
      astrctTrackers = fnMergeJobs(strctMovieInfo, jobFN, []);
      strMovieFileName=strctMovieInfo.m_strFileName;  %#ok
      sRawTrackFile = fullfile(resultsDirName, ...
                               clipBaseName, ...
                               'SequenceRAW');
      save(sRawTrackFile, 'astrctTrackers', 'strMovieFileName');
      astrctTrackers = ...
        fnHouseIdentities(astrctTrackers, ...
                          strctMovieInfo, ...
                          classifiersFN);  %#ok
      sTrackFile = fullfile(tracksDirName, [clipBaseName '_tracks.mat']);
      save(sTrackFile, 'astrctTrackers', 'strMovieFileName');
      %fnUpdateStatus(handles, 'expClipStatus', i, 4);
      %fnSetClipStatusCode(handles, i, 4);
      fnSetClipTrackStatusCode(hFig, i, 4);
    end
  end
  set(hFig,'pointer','arrow');
  drawnow('expose');
  drawnow('update');
else
  % cluster mode
  for i=1:nClip
    if submitPost(i)
      %[iStatus, expDirName, aiNumJobs] = fnGetExpInfo();
      clipFNAbsThis = clipFNAbs{i};
      [dummy, clipBaseName] = fileparts(clipFNAbsThis);  %#ok
      sRawTrackFile = fullfile(resultsDirName, clipBaseName, 'SequenceRAW.mat');
      % sTrackFile = fullfile(tracksDirName, [clipBaseName '.mat']);
      sTrackFile = fullfile(tracksDirName, [clipBaseName '_tracks.mat']);
      strctJob.m_sFunction = 'fnPostTracking';
      strctJob.m_acExperimentClips = clipFNAbs;
      strctJob.m_sExpName = expDirName;
      strctJob.m_iClip = i;
      strctJob.m_aiNumJobs = aiNumJobs;
      strctJob.m_sRawTrackFile = sRawTrackFile;
      strctJob.m_sTrackFile = sTrackFile;
      strctJob.m_iUID = aiNumJobs(i) + 1;
      sJobsDir = fullfile(jobsRootDirName, clipBaseName);
      sJobFileName = fullfile(sJobsDir, 'PostProcessJobargin.mat');
      save(sJobFileName, 'strctJob','g_strctGlobalParam','g_iLogLevel','g_CaptainsLogDir');
      %       fnJobAlgorithm(sJobFileName);
      
      strSubmitFile = [sJobsDir,'/submitPostProcessScript'];
      fprintf('Generating submit file at %s\n', strSubmitFile);
      hFileID = fopen(strSubmitFile,'w');
      fprintf(hFileID,'#!/bin/bash\n');
      %fprintf(hFileID,'%s/Deploy/MouseTrackProj/src/MouseTrackProj %s/PostProcessJobargin.mat\n', pwd(), sJobsDir);
      fprintf(hFileID, ...
              ['%s/Deploy/MouseTrackProj/src/MouseTrackProj ' ...
               '%s/PostProcessJobargin.mat\n'], ...
              g_strMouseStuffRootDirName, ...
              sJobsDir);
      fclose(hFileID);
      %fprintf('Changing permissions\n');
      system(['chmod 755 ',strSubmitFile]);
      fprintf('Submitting jobs\n');
      if aiNumCurrJobs(i) > 0
        strHoldJid = '-hold_jid MouseJob';
      else
        strHoldJid = '';
      end
      strCmd = ...
        sprintf('qsub -N MousePostProcessJob %s -e %s -o %s -b y -cwd -V ''%s''', ...
                strHoldJid, ...
                sJobsDir, ...
                sJobsDir, ...
                strSubmitFile);
      strCmdFile = [sJobsDir,'/resubmitPostProcess'];
      hFileID = fopen(strCmdFile,'w');
      fprintf(hFileID,'%s\n',strCmd);
      fclose(hFileID);
      fprintf('%s\n',strCmd);
      system(strCmd);
      %fnUpdateStatus(handles, 'expClipStatus', i, 3);
      %fnSetClipStatusCode(handles, i, 3);
      % update the GUI to reflect that this clip is in process
      fnSetClipTrackStatusCode(hFig, i, 3);
    end
  end
  %if isempty(answer) || strcmpi(answer,'No, I want to use Matlab for something else after submitting jobs to cluster')
  set(hFig,'pointer','watch');
  drawnow('expose');  drawnow('update');
  fnWaitForAnyTrackFile(hFig, expDirName, clipFNAbs);
  set(hFig,'pointer','arrow');
  drawnow('expose');  drawnow('update');
  fnUpdateGUIStatus(hFig);
end


