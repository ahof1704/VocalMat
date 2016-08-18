function trainStatus=determineTrainStatus(expDirName,clipSMFNAbs)
% Figures out what the training status is, by looking for files in the
% right places.  expDirName should be an absolute path, clipSMFN should
% contain relative paths.
%
% The code:
%   1: not started
%   2: files chosen
%   3: in process
%   4: done

% Check for the final results file
finalTrainingFN=fullfile(expDirName,'Tuning','Identities.mat');
if exist(finalTrainingFN,'file')
  trainStatus=4;
  return;
end

% Check for per-animal SM ident files
nClipSM=length(clipSMFNAbs);
for i=1:nClipSM
  [dummy,baseNameThis]=fileparts(clipSMFNAbs{i});  %#ok
  fileName=fullfile(expDirName,'Tuning',baseNameThis,'Identities.mat');
  if exist(fileName,'file')
    trainStatus=3;
    return;
  end
end

% Check for background segmentation file
fileName=fullfile(expDirName,'Tuning','Detection.mat');
if exist(fileName,'file')
  trainStatus=3;  % is this right?  Or should it be 2?
  return;
end

% have the files even been chosen?
if nClipSM>0
  trainStatus=2;
  return;
end

% if we get here, the files haven't even been chosen
trainStatus=1;

end
