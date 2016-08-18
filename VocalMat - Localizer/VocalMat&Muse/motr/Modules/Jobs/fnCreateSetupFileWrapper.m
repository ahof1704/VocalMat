function strAdditionalInfoFileName = ...
  fnCreateSetupFileWrapper(strJobsFolderName, ...
                           strIdentitiesFileName, ...
                           strClipBackgroundFN, ...
                           strClipFloorFN, ...
                           strGTEllipsesFN, ...
                           strTunedSegmentationParamsFN, ...
                           strAdditionalInfoFileName)

% This function submits clip segments for processing, in a way more
% suitable to batch processing than fnSubmitMovieToProcessing().  iNumJobs
% returns the number of jobs _submitted_, in either case.
%
% strAppRootFolder is the folder with subdirectories such as Applications, 
% Config, Deploy, Modules, etc.  I.e. the root folder that contains all the
% source code.

% Copyright (c) 2008 Shay Ohayon, California Institute of Technology. This
% file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by the
% Free Software Foundation (see GPL.txt)

% Make sure the jobs folder exists.
if ~exist(strJobsFolderName,'dir')
  mkdir(strJobsFolderName)
end;

% Load the background, floor mask, GT ellipses, and 
% segmentation parameters, and store them all in a single variable, 
% strctBackground.
%strctBackground=fnLoadBGFloorSegParamsFile(strDetectionFileName);
a2fBackground=fnLoadAnonymous(strClipBackgroundFN);
a2bFloor=fnLoadAnonymous(strClipFloorFN);
[a2strctTuningGTEllipses,iTuningGTFrames]= ...
  fnLoadSegmentationGT(strGTEllipsesFN);
strctSegParams=fnLoadAnonymous(strTunedSegmentationParamsFN);
strctBackground= ...
  fnStrctBackgroundFromParts(a2fBackground, ...
                             a2bFloor, ...
                             a2strctTuningGTEllipses, ...
                             iTuningGTFrames, ...
                             strctSegParams);

% Load the classifiers file.
strctID = load(strIdentitiesFileName);

% Make the "setup" file, which contains a bunch of information, like the
% classifiers, background, floor mask, and segmentation parameters.  Most
% of that information is also packaged up and returned in 
% strctAdditionalInfo.
[~, strAdditionalInfoFileName] = ...
  fnCreateSetupFile(strctID,strctBackground,strJobsFolderName,strAdditionalInfoFileName);
                
end
