function fnCreateJob(strMovieFileName, strctMovieInfo, ...
                     aiFrameInterval, strctBootstrap, strAdditionalInfoFile,...
                     strOutputFile, iUID, ...
                     strJobInputFileName,bLearnIdentity)

global g_strctGlobalParam
   
if exist('bLearnIdentity','var') && bLearnIdentity==true
   strctJob.m_sFunction = 'fnLearnMouseIdentity';
else
   bLearnIdentity = false;
   strctJob.m_sFunction = 'fnMainFrameLoop';
end;

strctJob.m_strMovieFileName = strMovieFileName;
strctJob.m_aiFrameInterval = aiFrameInterval;
strctJob.m_strctBootstrap = strctBootstrap;
strctJob.m_strAdditionalInfoFile = strAdditionalInfoFile;
strctJob.m_strOutputFile = strOutputFile;
strctJob.m_iUID = iUID;
strctJob.m_bLearnIdentity = bLearnIdentity;
[strPath,strFile]=fileparts(strJobInputFileName);
if ~exist(strPath,'dir')
    mkdir(strPath);
end;
if ~fnGetLogMode(1)
   global g_iLogLevel;
   g_iLogLevel = 0;
   save(strJobInputFileName, 'strctJob','g_strctGlobalParam','g_iLogLevel');
else
   global g_iLogLevel g_CaptainsLogDir;
   save(strJobInputFileName, 'strctJob','g_strctGlobalParam','g_iLogLevel','g_CaptainsLogDir');
end
return;