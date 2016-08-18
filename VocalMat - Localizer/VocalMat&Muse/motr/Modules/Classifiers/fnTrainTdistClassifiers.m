function fnTrainTdistClassifiers(acMovies, ...
                                 strInputsRootFolderName,...
                                 strOutputFolderName)

% This function loads the single-mouse clip tracks (including HOG vectors),
% computes the identity classifiers, the head-tail classifier, and some
% other stuff, and saves them to an output file.
%
% Let iNumSMClip be the number of single-mouse clips.
% acMovies is a iNumSMClip x 1 cell array.  Each element contains a scalar
%   structure, which is a "file pointer" to a clip.  (I.e. it's a structure
%   containing a bunch of metadata about a clip file, including an index.)
% strInputsRootFolderName should contain one folder per single-mouse clip, 
%                         with the folder named the same as the clip file
%                         name, but with no extension.  In each folder
%                         should be a file called "Identities.mat"
%                         containing the single-mouse track for that clip.
% strOutputFolderName contains the name of the folder where the output .mat
%                     file is placed.  This file is also called
%                     "Identities.mat".  (Although if this function is
%                     called from somewhere other than MouseHouse, the user
%                     is prompted to supply a new file name.)

% Unpack globals we need.
% The location where the output file is stored depends on whether
% this function is called from MouseHouse or not (e.g. from Repository).
global g_bMouseHouse
bMouseHouse=g_bMouseHouse;
clear g_bMouseHouse
                                  
% Figure out the names of all the SM clip track files.
iNumMice=length(acMovies);
acstrSMClipTrackFileNameAbs=cell(iNumMice,1);
for i=1:iNumMice
  [dummy, strClipFileName] = fileparts(acMovies{i}.m_strFileName);  %#ok
  acstrSMClipTrackFileNameAbs{i} = ...
    fullfile(strInputsRootFolderName, strClipFileName, 'Identities.mat');
end
                                  
% Get a file name for storing the classifiers, which depends on whether
% this function was called from MouseHouse or not.
if bMouseHouse
  strOutputFileName = fullfile(strOutputFolderName,'Identities.mat');
else
  [strClipFileName, strPath] = ...
    uiputfile(fullfile(strOutputFolderName,'Identities.mat'));
  if strClipFileName(1) == 0
    return;
  end
  strOutputFileName = [strPath,strClipFileName];
end

% Make sure that directory exists
if ~exist(strOutputFolderName,'dir')
  mkdir(strOutputFolderName);
end

% Now that we've sorted out the file names, call the routine that actually
% does the work.
fnTrainTdistClassifiersRind(acstrSMClipTrackFileNameAbs, ...
                            strOutputFileName);
   
end
