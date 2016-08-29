function  strctIdentity = fnLearnMouseIdentity(strMovieFileName, ...
                                               strctBootstrap, ...
                                               strOutputFile)

% Process a single single-mouse clip, and produce a set of registered mouse
% images with the head to the right, and store these in a file.
%
% strMovieFileName contains the name of the input video file.
% strctBootstrap contains a floor mask, if available.  This is in
%   strctBootstrap.m_a2bMask.  If not available, strctBootstrap should be
%   empty.
% strOutputFile contains the name of the .mat file to which output is 
%   written.  This file contains two variables:
%
%     strMovieFileName: The input file name
%     strctIdentity:    Structure containing the actual output (described
%                         below)
%
% On return, strctIdentity is a scalar struct with the following fields:
%     
%                 m_a2fMedian: background image, pels on [0,1]
%            m_a3fHOGFeatures: [iNumFrames x iNumHogFeatures single]
%                                HOG vector for each patch, with head to
%                                the right.  (Assuming everything worked
%                                correctly.)
%     m_a3fHOGFeaturesFlipped: [iNumFrames x iNumHogFeatures single]
%                                HOG vector for each patch when rotated 180 
%                                degrees. 
%                m_a3iPatches: [iHPatch x iWPatch x iNumFrames uint8]
%                                Registered mouse images, of a
%                                pre-determined size (iHPatch x iWPatch).
%                       m_afX: [1 x iNumFrames double]
%                                This and the rest are the ellipse
%                                parameters for each frame.
%                       m_afY: [1 x iNumFrames double]
%                       m_afA: [1 x iNumFrames double]
%                       m_afB: [1 x iNumFrames double]
%                   m_afTheta: [1 x iNumFrames double]

% Get the input file "file pointer"
strctMovInfo = fnReadVideoInfo(strMovieFileName);

% Learn background.
iVerbosity=1;  % Print stuff during background calculation.
a2fBackground = fnBackgroundFromSMClip(strctMovInfo, ...
                                       iVerbosity);

% Either load the floor mask or generate one, as needed.
if isempty(strctBootstrap)
  % Automatically identify floor and crop reflections on walls.
  a2bMask=fnHeuristicMaskFromBackground(a2fBackground);
else
  % If strctBootstrap is non-empty, it should have the mask inside it.
  a2bMask = strctBootstrap.m_a2bMask;
end  
                                 
% Find the mouse and calculate the HOG vectors for each frame of the 
% movie.
[a2fHOGFeatures,a2fHOGFeaturesFlipped,a3iPatches, ...
 afX,afY,afA,afB,afTheta]= ...
  fnHOGFeaturesFromSMClip(strctMovInfo,a2bMask,a2fBackground);

% Store everything in a single structure.
strctIdentity=struct('m_a2fMedian',a2fBackground, ...
                     'm_a3fHOGFeatures',a2fHOGFeatures, ...
                     'm_a3fHOGFeaturesFlipped',a2fHOGFeaturesFlipped, ...
                     'm_a3iPatches',a3iPatches, ...
                     'm_afX',afX, ...
                     'm_afY',afY, ...
                     'm_afA',afA, ...
                     'm_afB',afB, ...
                     'm_afTheta',afTheta);

% Write output to a file.
strPath = fileparts(strOutputFile);
if ~isempty(strPath) && ~exist(strPath,'dir')
  mkdir(strPath);
end;
save(strOutputFile,'strctIdentity','strMovieFileName');

end
