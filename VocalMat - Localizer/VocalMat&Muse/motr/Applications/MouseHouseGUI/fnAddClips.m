function fnAddClips(hFig, clipFNAbsNew, bAppend)

% Get the experiment info out of the figure.
u=get(hFig,'userdata');
expDirName=u.expDirName;
clipFNAbs=u.clipFNAbs;
iClipCurr=u.iClipCurr;
trackStatus=u.trackStatus;

% figure out the tracking status of the new clips
nClipNew=length(clipFNAbsNew);
trackStatusNew=zeros(nClipNew,1);
for i=1:nClipNew
  trackStatusNew(i)=determineTrackStatus(expDirName,clipFNAbsNew{i});
end

% update the clips, depending on bAppend
if bAppend
  clipFNAbs = [clipFNAbs;clipFNAbsNew];
  trackStatus=[trackStatus;trackStatusNew];
else
  clipFNAbs = clipFNAbsNew;
  trackStatus=trackStatusNew;
  iClipCurr=1;
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
