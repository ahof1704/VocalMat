function strDetectionFileName= ...
  fnDetermineBGFloorSegParamsFileName(bMouseHouse, ...
                                      strIdentitiesFileName, ...
                                      strOutputFolderName)

% Figures out the name of the background-floor-segmentation-params file, 
% based of the inputs, poking around the filesystem, and possibly querying
% the user.  Returns an empty string if it can't figure it out.
                                    
if bMouseHouse
  strPath = fileparts(strIdentitiesFileName);
  strDetectionFileName = fullfile(strPath, 'Detection.mat');
else
  if exist(fullfile(strOutputFolderName,'Background.mat'),'file')
    fprintf('Loading background file %s\n', ...
            fullfile(strOutputFolder,'Background.mat'));
    strDetectionFileName=fullfile(strOutputFolder,'Background.mat');
  else
    fprintf(['Background file - %s does not exist or empty, please ' ...
             'choose another file (a copy will be created) or go ' ...
             'back to  "Pre Processing -> Tune Background" \n'], ...
            fullfile(strOutputFolder,'Background.mat'));
    [strFile, strPath] = ...
      uigetfile({[strOutputFolder,'*.mat']}, ...
                'select an alternative Background file', ...
                'Background.mat');
    if strPath==0  % user pressed cancel
      strDetectionFileName='';
      return;
    end
    strDetectionFileName=fullfile(strOutputFolder,'Background.mat');
    copyfile(fullfile(strPath,strFile), ...
             strDetectionFileName);
  end
end

end
