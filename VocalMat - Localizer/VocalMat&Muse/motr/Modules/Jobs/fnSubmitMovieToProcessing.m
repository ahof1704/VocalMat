function iNumJobs = fnSubmitMovieToProcessing(strMovieFileName, ...
                                              strJobsRootFolder, ...
                                              strResultsRootFolder,...
                                              strIdentitiesFile, ...
                                              strAppRootFolder, ...
                                              bRunLocal, ...
                                              bAutoSearchFiles, ...
                                              aiMissing)

% This function submits clip segments for processing.  If aiMissing is
% non-empty, it will submit jobs only for the segment indices listed in
% aiMissing.  Otherwise, it submit jobs for all segments, after determining
% how many segments there will be.  iNumJobs returns the number of jobs
% _submitted_, in either case.  bAutoSearchFiles, if true, means to read
% the reliable frame information from an already-generated file.
%
% strAppRootFolder is the folder with subdirectories such as Applications, 
% Config, Deploy, Modules, etc.  I.e. the root folder that contains all the
% source code.

% Copyright (c) 2008 Shay Ohayon, California Institute of Technology. This
% file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by the
% Free Software Foundation (see GPL.txt)

global g_strctGlobalParam g_bMouseHouse;

% Deal with args.
if nargin<8 
  aiMissing=[];  % Means to find reliable frames, and run all jobs
end

% If aiMissing is non-empty, it means to only run the jobs given in
% aiMissing, and to skip finding of reliable frames, which presumably was
% already done.
bOnlyRunMissing = ~isempty(aiMissing);

% Determine the names of the output folder and the jobs folder, and make
% sure they exist.
[dummy, strMovieBaseName] = fileparts(strMovieFileName);  %#ok
strOutputFolder = [fullfile(strResultsRootFolder, strMovieBaseName) filesep];
strJobFolder = [fullfile(strJobsRootFolder, strMovieBaseName) filesep];
if ~exist(strOutputFolder,'dir')
  mkdir(strOutputFolder)
end;
if ~exist(strJobFolder,'dir')
  mkdir(strJobFolder)
end;

% Figure out the name of the background file, and load it.
strDetectionFileName= ...
  fnDetermineBGFloorSegParamsFileName(g_bMouseHouse, ...
                                      strIdentitiesFile, ...
                                      strOutputFolder);
if isempty(strDetectionFileName)
  iNumJobs = 0;
  return;
end
strctBackground=fnLoadBGFloorSegParamsFile(strDetectionFileName);

% Load the classifiers file.
strctID = load(strIdentitiesFile);

% Determine iNumMice
strType=g_strctGlobalParam.m_strctClassifiers.m_strType;
if strcmpi(strType,'LDA_Logistic')  || strcmpi(strType,'RobustLDA') || ...
   strcmpi(strType,'Tdist')
  iNumMice = length(strctID.strctIdentityClassifier.m_astrctClassifiers);
else
  iNumMice = size(strctID.strctIdentityClassifier.m_a2fW,2);
end

% Get the clip metadata
strctMovieInfo = fnReadVideoInfo(strMovieFileName);

% Unpack the index of the first and last frames of the clip.
iStartFrame = 1;
iEndFrame = strctMovieInfo.m_iNumFrames;

% Make the "setup" file, which contains a bunch of information, like the
% classifiers, background, floor mask, and segmentation parameters.  Most
% of that information is also packaged up and returned in 
% strctAdditionalInfo.
[strctAdditionalInfo, strAdditionalInfoFile] = ...
  fnCreateSetupFile(strctID,strctBackground,strJobFolder);

% Create the jobargin files.  If bOnlyRunMissing is true, skip this step.
% Creating these files requires us to know the intervals and the key frame
% for each.  We figure this out either by reading them
% from disk, firing up a GUI, or doing it automatically, depending on
% various things.
if ~bOnlyRunMissing
  if bAutoSearchFiles
    strReliableFramesFileNameAbs= ...
      fullfile(strOutputFolder,'ReliableKeyFrames.mat');
    if exist(strReliableFramesFileNameAbs,'file')
      fprintf('Automatically loading previous key frames\n');
      astrctReliableFrames= ...
        fnLoadReliableFrames(strReliableFramesFileNameAbs);
    else
      astrctReliableFrames = ...
        ReliableFramesGUI(strctMovieInfo, ...
                          strctAdditionalInfo, ...
                          strOutputFolder, ...
                          iNumMice, ...
                          iStartFrame, ...
                          iEndFrame);
    end
  else
    if g_bMouseHouse
      iMinInterval=5000;
      %iMinInterval=50;
      iSkip=5000;
      iNumReinitializations=5;
      iMaxJobSize=5000;
      iNumFramesMissing=10;
      handles=[];
      astrctReliableFrames = ...
        fnFindReliable(strctMovieInfo,...
                       strctAdditionalInfo,...
                       iNumMice,...
                       iStartFrame,...
                       iEndFrame,...
                       iMinInterval,...
                       iSkip,...
                       iNumReinitializations,...
                       iMaxJobSize,...
                       iNumFramesMissing,...
                       handles);
    else
      astrctReliableFrames = ...
        ReliableFramesGUI(strctMovieInfo, ...
                          strctAdditionalInfo, ...
                          strOutputFolder, ...
                          iNumMice, ...
                          iStartFrame, ...
                          iEndFrame);
    end
  end
  if isempty(astrctReliableFrames)
    iNumJobs=0;
    %    errordlg('Critical error, could not find even a single');
    return;
  end;  
  % Create all the jobs, including Jobargin<>.mat files in the job folder.
  acstrJobOutFileNames=fnCreateJobs(strMovieFileName,...
                                    astrctReliableFrames,...
                                    strAdditionalInfoFile, ...
                                    strOutputFolder, ...
                                    strJobFolder);
  iNumJobs=length(acstrJobOutFileNames);                    
end;

% Sort out which jobs we're going to run
if bOnlyRunMissing
  aiJobsToRun=aiMissing;
  strJobarginBaseName='JobarginRerun';
  iNumJobs=length(aiMissing);
else
  aiJobsToRun=(1:iNumJobs);
  strJobarginBaseName='Jobargin';
end

% If we're just running missing jobs, and we're going to do it on the
% cluster, copy original Jobargin .mat files over to identical
% JobarginRerun .mat files with sequential numbering, so that we can still
% submit  jobs as an SGE task array.
if ~bRunLocal && bOnlyRunMissing
  for iMissing=1:length(aiMissing)
    strJobarginFileName = ...
      fullfile(strJobFolder, ...
               ['Jobargin' num2str(aiMissing(iMissing)) '.mat']);
    strJobarginRerunFileName = ...
      fullfile(strJobFolder,['JobarginRerun' num2str(iMissing) '.mat']);
    copyfile(strJobarginFileName, strJobarginRerunFileName);
  end
end

% Run the individual jobs, either locally or on the cluster.
% This will block if running local, but will return more-or-less
% immediately if running on the cluster.
fnRunJobs(bRunLocal, ...
          aiJobsToRun, ...
          strJobFolder, ...
          strAppRootFolder, ...
          strJobarginBaseName);

return;

