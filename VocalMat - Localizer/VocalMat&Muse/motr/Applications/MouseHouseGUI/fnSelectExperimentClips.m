function fnSelectExperimentClips(hFig, bAppend)
% Allow the user to choose clips to track.  If bAppend is true, then append
% the newly-selected clips to the existing clips.  If bAppend is false, then
% replace the existing clips with the newly-selected clips.

% get things we'll need out of the figure
u=get(hFig,'userdata');
expDirName=u.expDirName;

% Throw up the dialog box.
[acstrFileName, strDirName] = ...
  uigetfile({'*.avi', 'Microsoft AVI Videos (*.avi)'; ...
             '*.mj2', 'Motion JPEG 2000 Videos (*.mj2)'; ...
             '*.seq', 'Norpix Sequence Videos (*.seq)'; ...
             '*.*', 'All Files' }, ...
            'Select clips to be tracked...', ...
            expDirName, ...
            'MultiSelect', 'on');
            
% if user pressed cancel, do nothing and return          
if strDirName == 0
    return;
end;

% make sure acstrFile is a cell array of strings
if ~iscell(acstrFileName)
    acstrFileName = {acstrFileName};
end;

% convert the file names to absolute file names
nClip=length(acstrFileName);
acstrFileNameAbs=cell(nClip,1);
for i=1:nClip
   acstrFileNameAbs{i} = fullfile(strDirName,acstrFileName{i});
end

% % make a structure array with the filenames and the tracking status of each 
% % clip, which is 2 (== file selected)
% acExperimentClipsToAdd = struct('sName',acstrFile,'iStatus',2);

% add the the new clips, with their statuses, to the list of clips
%fnUpdateStatus(handles, 'acExperimentClips', acExperimentClips, bAppend);
fnAddClips(hFig, acstrFileNameAbs, bAppend);
