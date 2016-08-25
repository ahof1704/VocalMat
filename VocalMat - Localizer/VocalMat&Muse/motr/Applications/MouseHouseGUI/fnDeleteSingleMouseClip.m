function fnDeleteSingleMouseClip(hFig, iClipSM)

% Get the experiment info out of the figure.
u=get(hFig,'userdata');
expDirName=u.expDirName;
clipSMFNAbs=u.clipSMFNAbs;
iClipSMCurr=u.iClipSMCurr;
trainStatus=u.trainStatus;

% Want to know how many clips before deletion
nClipSMBefore=length(clipSMFNAbs);

% get rid of the inidicated clip in clipSMFN
clipSMFNAbs(iClipSM)=[];

% update iClipSMCurr
if nClipSMBefore==1
  iClipSMCurr=-1;  % no clips left
elseif iClipSMCurr==nClipSMBefore
  iClipSMCurr=iClipSMCurr-1;
end

% Change the training status, if needed
if nClipSMBefore==1
  trainStatus=1;
end

% Save the new info into the userdata.
u.clipSMFNAbs=clipSMFNAbs;
u.trainStatus=trainStatus;
u.iClipSMCurr=iClipSMCurr;
set(hFig,'userdata',u);

% Save the new info into the clipFN file
saveClipFN(expDirName,u.clipFNAbs,clipSMFNAbs);

% now update the GUI to reflect the status
fnUpdateGUIStatus(hFig);

end
