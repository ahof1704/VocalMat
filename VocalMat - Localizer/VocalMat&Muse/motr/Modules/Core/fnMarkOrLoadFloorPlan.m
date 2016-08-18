function a2bMask = fnMarkOrLoadFloorPlan(strOutputPath,strSeqID,strMovieFileName)
a2bMask = [];
strctMov = fnReadVideoInfo(strMovieFileName);
a2fFrame = double(fnReadFrameFromVideo(strctMov,1))/255;
if ~exist([strOutputPath,strSeqID],'dir')
    mkdir([strOutputPath,strSeqID]);
end;
strFloorFile = fullfile(strOutputPath,strSeqID,'Floor.mat');
% Test whether floor has been marked
if ~exist(strFloorFile,'file')
    answer = questdlg('Floor plan is missing.','Question','Load file','Mark','Cancel','Mark');
    switch lower(answer)
        case 'load file'
            [strFileFloor,strPathFloor] = uigetfile(strFloorFile);
            if strFileFloor(1) == 0
                return;
            end;
            strFloorFile = fullfile(strPathFloor,strFileFloor);
            strctTmp = load(strFloorFile);
            if ~isfield(strctTmp,'a2bMask')
                fprintf('Not a valid floor file\n');
                return;
            end;
            strFloorFile = fullfile(strOutputPath,strSeqID,'Floor.mat');
            save(strFloorFile,'a2bMask');
            a2bMask = strctTmp.a2bMask;
        case 'mark'
            hFig = figure;
            a2bMask=roipoly(a2fFrame);
            delete(hFig);
            if isempty(a2bMask)
                return;
            end;
            save(strFloorFile,'a2bMask');
        case 'cancel'
            return;
    end;
    
    
else
    % load the existing mask
    strctTmp = load(strFloorFile);
    a2bMask = strctTmp.a2bMask;
    if isempty(a2bMask)
        % if the mask is empty, pretend they said they wanted to mark one
        answer = 'No (Mark)';
    else
        % if the mask is nonempty, ask if they want to use it
        answer = questdlg('Use exiting floor plan?','Question','Yes','No (Mark)','Cancel','Yes');
    end
    switch lower(answer)
        case 'yes'
            strctTmp = load(strFloorFile);
            a2bMask = strctTmp.a2bMask;
        case 'no (mark)'
            hFig = figure;
            a2bMask=roipoly(a2fFrame);
            delete(hFig);
            if isempty(a2bMask)
                return;
            end;
            save(strFloorFile,'a2bMask');
        case 'cancel'
            return;
    end
end

return;
