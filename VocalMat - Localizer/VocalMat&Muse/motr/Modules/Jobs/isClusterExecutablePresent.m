function result=isClusterExecutablePresent()

% figure out where the root of the Motr code is
thisScriptFileName=mfilename('fullpath');
thisScriptDirName=fileparts(thisScriptFileName);
thisScriptDirParts=split_on_filesep(thisScriptDirName);
  % a cell array with each dir an element
motrRootParts=thisScriptDirParts(1:end-2);
motrRootDirNameAbs=combine_with_filesep(motrRootParts);

% Construct the absolute file name of the executable
exeDirNameAbs= ...
  fullfile(motrRootDirNameAbs,'Deploy','MouseTrackProj','src');
                
exeFNAbs=fullfile(exeDirNameAbs,'MouseTrackProj');                
                
% Check whether the executable exists                
result=exist(exeFNAbs,'file');

end
