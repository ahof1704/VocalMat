function fnJobAlgorithm(strJobargin)

% Copyright (c) 2008 Shay Ohayon, California Institute of Technology. This
% file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by the
% Free Software Foundation (see GPL.txt)

%global g_strctRandBuffer g_strctGlobalParam g_iLogLevel;
global g_strctGlobalParam g_iLogLevel;
global g_CaptainsLogDir;
global g_logImIndex;
global g_bMouseHouse;

if ~exist('strJobargin','var')
  fprintf('No parameter passed\n');
  return;
end;

if ~exist(strJobargin,'file')
  error('Critial Error - Could not find file at %s',strJobargin);
end;

fnMyRandN(1,1); % Initialize my random values.

[strPath, strFile,strExt]=fileparts(strJobargin);
if strcmpi(strExt,'.seq')
  % Assume this was called to generate the .mat index file.
  %strctMov=fnReadSeqInfo(strJobargin);
  fnReadSeqInfo(strJobargin);  % generates index file as side-effect
  return;
end

% Load variables from the job .mat file.
strctTmp = load(strJobargin);

% Unpack variables from strctTmp
g_strctGlobalParam = strctTmp.g_strctGlobalParam;
g_iLogLevel = strctTmp.g_iLogLevel;
if isfield(strctTmp,'g_bMouseHouse')
   g_bMouseHouse = strctTmp.g_bMouseHouse;
else
   g_bMouseHouse = false;
end
strctJob = strctTmp.strctJob;

% Set up logging, if called for
if g_iLogLevel > 0
  if ~isfield(strctJob,'m_iUID')
    strctJob.m_iUID = 0;
  end
  g_CaptainsLogDir = strctTmp.g_CaptainsLogDir;
  g_logImIndex = 0;
  g_CaptainsLogDir = ...
    fullfile(g_CaptainsLogDir, ...
             [strctJob.m_sFunction '_' num2str(strctJob.m_iUID)]);
  mkdir(g_CaptainsLogDir);
  sLogFile = fullfile(g_CaptainsLogDir, 'logFile.txt');
  fid = fopen(sLogFile, 'w');
  fclose(fid);
end

% The big switch
switch strctJob.m_sFunction
  case 'fnPostTracking',
    fnPostTracking(strctJob.m_acExperimentClips, ...
                   strctJob.m_sExpName, ...
                   strctJob.m_iClip, ...
                   strctJob.m_aiNumJobs);
  case 'fnLearnMouseIdentity',
    % This is just a piggy back on fnJobAlgorithm to anaylze sequences with
    % just one mouse to learn identeties....
    fprintf('Analyzing %s. \nResults will be stored in %s \n', ...
            strctJob.m_strMovieFileName,strctJob.m_strOutputFile);
    fnLearnMouseIdentity(strctJob.m_strMovieFileName, ...
                         strctJob.m_strctBootstrap, ...
                         strctJob.m_strOutputFile);
  case 'TrainIdentities',
    fprintf('Training identities using single tracked videos results\n');
    fnTrainTdistClassifiers(strctJob.m_acVideoInfos, ...
                            strctJob.m_sTuningDir, ...
                            strctJob.m_sTuningDir);
    
  case 'fnMainFrameLoop',
    % This is the serious tracking on multiple mice...
    strctJob.m_strctMovieInfo = ...
      fnReadVideoInfo(strctJob.m_strMovieFileName);
    % Some constants...
    iLocalMachineBufferSizeInFrames = ...
      g_strctGlobalParam.m_strctJobs.m_fLocalMachineBufferSizeInFrames;
    fprintf('Starting Job %d from frame %d to frame %d\n', ...
            strctJob.m_iUID, ...
            strctJob.m_aiFrameInterval(1), ...
            strctJob.m_aiFrameInterval(end));
    [astrctTrackersJob,afProcessingTime,aiRandIndex,a2bLostMice] = ...
      fnMainFrameLoop(strctJob,iLocalMachineBufferSizeInFrames);
    fnSaveResultsAtSubmittingMachine(strctJob, ...
                                     astrctTrackersJob, ...
                                     afProcessingTime, ...
                                     aiRandIndex, ...
                                     a2bLostMice);
end  % switch

if isfield(strctJob,'m_iUID')
  fprintf('Job %d Finished \n',strctJob.m_iUID);
else
  fprintf('Job Finished \n');
end

if isdeployed
  quit
end;

end




function fnSaveResultsAtSubmittingMachine(strctJob, ...
                                          astrctTrackersJob, ...
                                          afProcessingTime, ...
                                          aiRandIndex, ...
                                          a2bLostMice)  %#ok
                                        
global g_strctRandBuffer;  %#ok

strctJobInfo.m_iUID = strctJob.m_iUID;
if strctJob.m_aiFrameInterval(end) < strctJob.m_aiFrameInterval(1)
  strctJob.m_aiFrameInterval = strctJob.m_aiFrameInterval(end:-1:1);
end;
strctJobInfo.m_iVersion = 3;
strctJobInfo.m_aiFrameInterval = strctJob.m_aiFrameInterval;
strctJobInfo.m_strMovieFileName = strctJob.m_strMovieFileName;
strctJobInfo.m_strAdditionalInfoFile = strctJob.m_strAdditionalInfoFile;
% make sure destination folder exists!
strPath = fileparts(strctJob.m_strOutputFile);
if ~exist(strPath,'dir')
  mkdir(strPath);
end;

save(strctJob.m_strOutputFile, ...
  'astrctTrackersJob', ...
  'strctJobInfo', ...
  'afProcessingTime', ...
  'g_strctRandBuffer', ...
  'aiRandIndex', ...
  'a2bLostMice');

end
