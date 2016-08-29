function a2fBackground = fnBackgroundFromSMClip(strctInputFile, ...
                                                iVerbosity)

% Computes the background image from a single-mouse clip.  This is computed
% by taking a number of random frames from the clip and taking their
% median.
% strctInputFile is the input file "pointer".
% iVerbosity is optional.  If >0, various messages are printed to standard
%   output.
% On return, a2iBackground contains the background image.  It is of type
%   uint8.
          
% Deal with args.
if nargin<2 || isempty(iVerbosity)
  iVerbosity=0;
end

% Unpack global we'll need, the number of frames to sample.
global g_strctGlobalParam
iNumFramesToSample = ....
  g_strctGlobalParam.m_strctSingleMouseIdentityTracker.m_fNumImagesForBuffer;
clear g_strctGlobalParams

% Get number of frames in input clip.                    
iNumFrames=strctInputFile.m_iNumFrames;

% randomized (original) version
aiValidIntervals = (1:iNumFrames);
aiIndices = ...
  aiValidIntervals(round( rand(1,iNumFramesToSample) * ...
                          (length(aiValidIntervals)-1) ...
                   + 1));

% % Deterministic version:
% spacing=iNumFrames/iNumImagesForBuffer;
% aiIndices=1+round(spacing/2+spacing*(0:(iNumImagesForBuffer-1)));

% Get the sample frames from the clip.
iHeight=strctInputFile.m_iHeight;
iWidth=strctInputFile.m_iWidth;
a3iBuffer = zeros(iHeight,iWidth,iNumFramesToSample);
if iVerbosity>=1
  fprintf('Collecting random images, please wait...');
end
for k=1:iNumFramesToSample
  if iVerbosity>=1
    fprintf('*');
  end
  a3iBuffer(:,:,k) = fnReadFrameFromVideo(strctInputFile,aiIndices(k));
end
if iVerbosity>=1
  fprintf('\nDone!\n');
end

% Calculate the median.
if iVerbosity>=1
  fprintf('Computing Median, please wait...');
end
a2fBackground = double(median(a3iBuffer,3))/255;
if iVerbosity>=1
  fprintf('Done!\n');
end

% Write to the log.                                 
fnLog(['fnBackgroundFromSMClip: iNumFramesToSample = ' ...
       num2str(iNumFramesToSample) ...
       ', saving a2fBackground'], ...
      1, ...
      a2fBackground);

end

