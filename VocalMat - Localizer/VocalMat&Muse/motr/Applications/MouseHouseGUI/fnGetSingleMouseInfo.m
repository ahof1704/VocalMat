function [strClipName, strctIdentity] = fnGetSingleMouseInfo(iClip)
%
strClipName = [];
strctIdentity = [];
load 'Applications/MouseHouseGUI/ExpInfo';
sExpName = acExp{iCurrExpInd}.sName;
if isfield(acExp{iCurrExpInd}, 'acSingleMouseClips')
   if ~isstruct(acExp{iCurrExpInd}.acSingleMouseClips)
      strFile = acExp{iCurrExpInd}.acSingleMouseClips{iClip};
      if exist(strFile,'file')
         strClipName = strFile;
         sTuningDir = fullfile(sExpName, 'Tuning');
         [strPath,strFile] = fileparts(strClipName);
         strIdentityFileName = fullfile(sTuningDir, strFile, 'Identities.mat');
         load(strIdentityFileName);
      end
   end
end
