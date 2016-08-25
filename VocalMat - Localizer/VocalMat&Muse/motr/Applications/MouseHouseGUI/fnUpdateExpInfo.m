function iTrackStatus = fnUpdateExpInfo(iVal, acExperimentClips)
%
load('Applications/MouseHouseGUI/ExpInfo.mat');
if nargin > 0 && ~isempty(acExperimentClips)
   acExp{iCurrExpInd}.acExperimentClips = acExperimentClips;
   iTrackStatus = max([acExp{iCurrExpInd}.acExperimentClips.iStatus]);
   acExp{iCurrExpInd}.aiStatus(2) = iTrackStatus;
   acExp{iCurrExpInd}.iCurrExpClip = iVal;
else
   if isfield(acExp{iCurrExpInd}, 'acExperimentClips')
      rmfield(acExp{iCurrExpInd}, 'acExperimentClips');
   end
   if isfield(acExp{iCurrExpInd}, 'iCurrExpClip')
      rmfield(acExp{iCurrExpInd}, 'iCurrExpClip');
   end
   iTrackStatus = 1;
end
save('Applications/MouseHouseGUI/ExpInfo.mat', 'iCurrExpInd', 'acExp');


