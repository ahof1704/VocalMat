function result=isParsejpg8MexFilePresent()

% figure out where the root of the Ohayon code is
thisScriptFileName=mfilename('fullpath');
thisScriptDirName=fileparts(thisScriptFileName);
thisScriptDirParts=split_on_filesep(thisScriptDirName);
  % a cell array with each dir an element
mouseStuffRootParts=thisScriptDirParts(1:end-2);
g_strMouseStuffRootDirName=combine_with_filesep(mouseStuffRootParts);

% Construct the absolute file name of the parsejpg8 dll
archStr=computer('arch');                
dllFN=['parsejpg8' '.' mexext()];
%fprintf('\n\n\n%s:\n',dllFN);
%sourceDirName= ...
%  fullfile(g_strMouseStuffRootDirName,'Modules','MEX_Code','parsejpg8');
dllFNAbs=fullfile(g_strMouseStuffRootDirName,'Modules','MEX',archStr, ...
                  dllFN);

% Check whether the DLL exists                
result=exist(dllFNAbs,'file');

end
