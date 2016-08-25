function fnSetClipTrackStatusCode(hFig, iClip, newStatus)

% Read the userdata
u=get(hFig,'userdata');
trackStatus=u.trackStatus;

% Set the tracking status of clip iClip, for the current experiment, to
% the new status code.
trackStatus(iClip)=newStatus;

% write it back to the fig
u.trackStatus=trackStatus;
set(hFig,'userdata',u);

% now update the GUI to reflect the status
fnUpdateGUIStatus(hFig);

end
