function strctSegParams = ...
  fnOptimizeSegmentationParams(strctAdditionalInfo, ...
                               astrctEllipsesGTEtc)
% Function to produce an optimized set of segmentation parameters, starting
% from the default segmentation parameters, and given some ground-truth
% data provided in astrctEllipsesGTEtc.
%
% astrctEllipsesGTEtc is a 1 x iNumFrames structure array, with fields:
%   m_iFrame
%   m_bValid
%   m_astrctEllipse
%
% m_iFrame gives the frame number, m_bValid says whether is was valid or
% not, and m_astrctEllipse is a 1 x iNumMice structure array with fields
% for each of the ellipse parameters (X,Y,A,B,Theta), with "appropriate"
% prefixes.
%
% strctAdditionalInfo has a lot of stuff in it.  This function uses only
% the following fields:
%   strctAdditionalInfo.strctBackground.m_a2fMedian
%   strctAdditionalInfo.strctBackground.m_a2bFloor
%   strctAdditionalInfo.strctMovieInfo
%
% The first two contain the background image and the floor mask,
% respectively.  The last contains enough info about the clip that we
% can get the sample frames out of it.  m_a2fMedian is a double image with
% pels on [0,1]

% Load the default segmentation parameters
global g_strMouseStuffRootDirName;
segParamsFN= ...
  fullfile(g_strMouseStuffRootDirName, ...
           'Config', ...
           'defaultSegmentationParams.mat');
strctSegParams0=fnLoadAnonymous(segParamsFN);
clear g_strMouseStuffRootDirName;

% unpack astrctEllipsesGTEtc
iNumFrames=length(astrctEllipsesGTEtc);
if iNumFrames==0
  warning(['No frames for optimizing segmentations---' ...
           'Will use default segmentation parameters.']);
  strctSegParams=strctSegParams0;
  return;
end
iNumMice=length(astrctEllipsesGTEtc(1).m_astrctEllipse);
iFrame=[astrctEllipsesGTEtc.m_iFrame]';
bValid=[astrctEllipsesGTEtc.m_bValid]';
iNumFrames=length(astrctEllipsesGTEtc);
a2strctEllipseGT=reshape([astrctEllipsesGTEtc.m_astrctEllipse], ...
                         [iNumMice iNumFrames]);                                              
clear astrctEllipsesGTEtc;
                    
% Delete the invalid frames
iFrame=iFrame(bValid);
a2strctEllipseGT=a2strctEllipseGT(:,bValid);
clear bValid;
clear iNumFrames;

% Extract things we'll need from strctAdditionalInfo
a2fMedian=strctAdditionalInfo.strctBackground.m_a2fMedian;
a2bFloor=strctAdditionalInfo.strctBackground.m_a2bFloor;

% Read all the frames we'll need from the video  
[iH,iW]=size(a2fMedian);
iNumValidFrames=size(a2strctEllipseGT,2);
a3iSampleFrames= ...
  zeros(iH,iW,iNumValidFrames,'uint8');
for i=1:iNumValidFrames
  a3iSampleFrames(:,:,i)= ...
    fnReadFrameFromVideo(strctAdditionalInfo.strctMovieInfo, ...
                         iFrame(i));
end

% Get the time stamp bounding box out of the global params
global g_strctGlobalParam; 
a2fTimeStampBB= ...
  [g_strctGlobalParam.m_strctSetupParameters.m_afTimeStampX ; ...
   g_strctGlobalParam.m_strctSetupParameters.m_afTimeStampY ];
  % 2x2, [x1 x2; y1 y2]
clear g_strctGlobalParam;     
 
% Run the core routine
strctSegParams = ...
  fnOptimizeSegmentationParamsCore(strctSegParams0, ...
                                   a2fMedian, ...
                                   a2bFloor, ...
                                   a3iSampleFrames, ...
                                   a2strctEllipseGT, ...
                                   a2fTimeStampBB);

end                                 
