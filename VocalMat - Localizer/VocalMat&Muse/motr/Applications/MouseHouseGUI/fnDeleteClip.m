function fnDeleteClip(hFig, iClip)

% Get the experiment info out of the figure.
u=get(hFig,'userdata');
expDirName=u.expDirName;
clipFNAbs=u.clipFNAbs;
iClipCurr=u.iClipCurr;
trackStatus=u.trackStatus;

% Want to know how many clips before deletion
nClipBefore=length(clipFNAbs);

% get rid of the inidicated clip in clipFN, trackStatus
clipFNAbs(iClip)=[];
trackStatus(iClip)=[];

% update iClipCurr
if nClipBefore==1
  iClipCurr=-1;  % no clips left
elseif iClipCurr==nClipBefore
  iClipCurr=iClipCurr-1;
end

% Save the new info into the userdata.
u.clipFNAbs=clipFNAbs;
u.trackStatus=trackStatus;
u.iClipCurr=iClipCurr;
set(hFig,'userdata',u);

% Save the new info into the clipFN file
saveClipFN(expDirName,clipFNAbs,u.clipSMFNAbs)

% now update the GUI to reflect the status
fnUpdateGUIStatus(hFig);

end
