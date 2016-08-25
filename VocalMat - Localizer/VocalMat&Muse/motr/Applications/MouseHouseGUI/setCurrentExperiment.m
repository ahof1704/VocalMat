function setCurrentExperiment(hFig, expDirName)

% get userdata
u=get(hFig,'UserData');

% % Get relevant info out of the handles structure
% exp=handles.exp;
% iExpCurr=handles.iExpCurr;
% iClipCurr=handles.iClipCurr;
% iClipSMCurr=handles.iClipSMCurr;
% trainStatus=handles.trainStatus;
% trackStatus=handles.trackStatus;

% is there a clipFN.mat file?  If so, try to load it.
fileName=fullfile(expDirName,'clipFN.mat');
if exist(fileName,'file')
    % if clipFN.mat exists, try to load it
    try
        [clipFNAbs,clipSMFNAbs]=loadClipFN(fileName,expDirName);
        loadedClipFN=true;
    catch excp
        if strcmp(excp.identifier,'loadClipFN:wrongFormat')
            loadedClipFN=false;
            buttonLabel=...
                questdlg(['There is a clipFN.mat file in the directory, but ' ...
                          'it is in an unknown format.  ' ...
                          'Overwrite it and proceed?'], ...
                         'Unknown format', ...
                         'Overwrite and proceed','Cancel', ...
                         'Overwrite and proceed');
            if strcmp(buttonLabel,'Overwrite and proceed')
                % Delete the clipFN.mat file---a new one will likely be
                % written soon.
                delete(fileName);
            else
                return;
            end
        else
            rethrow(excp);
        end
    end
else
    loadedClipFN=false;
end

% If we loaded clipFN.mat successfully, determine statuses
if loadedClipFN    
    % init iClipCurr
    nClip=length(clipFNAbs);
    if nClip>0
        iClipCurr=1;
    else
        iClipCurr=-1;
    end
    % init iClipSMCurr
    nClipSM=length(clipSMFNAbs);
    if nClipSM>0
        iClipSMCurr=1;
    else
        iClipSMCurr=-1;
    end
    trainStatus=determineTrainStatus(expDirName,clipSMFNAbs);
    nClip=length(clipFNAbs);
    trackStatus=zeros(nClip,1);
    for j=1:nClip
        trackStatus(j)=determineTrackStatus(expDirName,clipFNAbs{j});
    end    
else
    % if no clipFN.mat, init to defaults
    clipFNAbs=cell(0,1);
    clipSMFNAbs=cell(0,1);
    iClipCurr=-1;
    iClipSMCurr=-1;
    trainStatus=1;
    trackStatus=zeros(0,1);
end

% save to the userdata
u.expSelected=true;
u.expDirName=expDirName;
u.clipFNAbs=clipFNAbs;
u.clipSMFNAbs=clipSMFNAbs;
u.iClipCurr=iClipCurr;
u.iClipSMCurr=iClipSMCurr;
u.trainStatus=trainStatus; 
u.trackStatus=trackStatus; 
set(hFig,'userdata',u);

% now update the GUI to reflect the status
fnUpdateGUIStatus(hFig);

end
