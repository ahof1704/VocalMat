function fnSetSingleMouseClips(hFig, clipSMFNAbs)
% Makes the clip names in the cell array of strings clipSMFNAbs to be the
% single-mouse clip names for the experiment, updates the main window as
% needed.

% get userdata
u=get(hFig,'userdata');
expDirName=u.expDirName;

% make clipSMFN a col vector
if size(clipSMFNAbs,1)==1 && size(clipSMFNAbs,2)>1
    clipSMFNAbs=clipSMFNAbs';
end

% set current SM clip
iClipSMCurr=1;

% figure out the new training status
trainStatus=determineTrainStatus(expDirName,clipSMFNAbs);

% write stuff to the userdata
u.clipSMFNAbs=clipSMFNAbs;
u.iClipSMCurr=iClipSMCurr;
u.trainStatus=trainStatus;
set(hFig,'userdata',u);

% update the clipFN.mat
saveClipFN(expDirName,u.clipFNAbs,clipSMFNAbs)

% now update the GUI to reflect the status
fnUpdateGUIStatus(hFig);

end
