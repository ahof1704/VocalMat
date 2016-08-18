function fnFindReliableFramesWrapper(strMovieFileName, ...
                                     strIdentitiesFileName, ...
                                     strAdditionalInfoFileName, ...
                                     strReliableFramesFileName)

% Copyright (c) 2008 Shay Ohayon, California Institute of Technology. This
% file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by the
% Free Software Foundation (see GPL.txt)

% Load the classifiers file.
strctID = load(strIdentitiesFileName);

% Determine iNumMice
iNumMice = length(strctID.strctIdentityClassifier.m_astrctClassifiers);

% Get the clip metadata
strctMovieInfo = fnReadVideoInfo(strMovieFileName);

% Unpack the index of the first and last frames of the clip.
iNumFrames=strctMovieInfo.m_iNumFrames;
iStartFrame = 1;
iEndFrame = iNumFrames;

% Read the addition info file
strctAdditionalInfo=fnLoadAnonymous(strAdditionalInfoFileName);

% Determine what the intervals will be for the clip, and which frame within
% each interval will be the key frame.
if iNumFrames>5000
  iMinInterval=5000;
else
  iMinInterval=round(iNumFrames/5);
end
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
if isempty(astrctReliableFrames)
  error('Unable to find a single interval with a reliable key frame.');
end

% save astrctReliableFrames to a file
fnSaveAnonymous(strReliableFramesFileName,astrctReliableFrames);
                
end
