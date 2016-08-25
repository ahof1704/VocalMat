function fnUpdateExperimentClipsListbox(handles,acExp,iCurrExp)

% the clip list and the current clip out of the exp info
iCurrClip=acExp{iCurrExp}.iCurrExpClip;
clip = acExp{iCurrExp}.acExperimentClips;

% generate the clip listbox items by coloring the clip names
% appropriately
clipListString=colorizeClips(clip,iCurrClip);

% update the clip listbox
set(handles.hExperimentClipsListbox, 'String', clipListString);
if length(clip)>0  %#ok
    set(handles.hExperimentClipsListbox, 'Value', iCurrClip);
else
    set(handles.hExperimentClipsListbox, 'Value', []);
end    

% update the enablement of the Results button, since the info needed
% it near at hand
if length(clip)>0 && clip(iCurrClip).iStatus==4  %#ok
    set(handles.hResults, 'Enable', 'on');
else
    set(handles.hResults, 'Enable', 'off');
end

%iTrackStatus = acExp{iCurrExp}.aiStatus(2);
%fnUpdateExpInfo(iCurrExpClip, acExperimentClips);
%set(handles.hTrack, 'BackgroundColor', C(iTrackStatus,:));
