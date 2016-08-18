function varargout = Repository(varargin)
%Copyright (c) 2008 Shay Ohayon, California Institute of Technology. 
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

% Last Modified by GUIDE v2.5 27-Jan-2011 17:09:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Repository_OpeningFcn, ...
                   'gui_OutputFcn',  @Repository_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Repository is made visible.
function Repository_OpeningFcn(hObject, eventdata, handles, varargin)
global g_strctGlobalParam 
global g_bMouseHouse
g_bMouseHouse = false;

% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Repository (see VARARGIN)
%dbstop if error
handles.output = hObject;
warning off
setappdata(handles.figure1,'iCurrFrame',1);
setappdata(handles.figure1,'iCurrVideo',1);
setappdata(handles.figure1,'iCurrID',1);

% make sure g_strMouseStuffRootDirName is set properly
global g_strMouseStuffRootDirName
if isempty(g_strMouseStuffRootDirName)
  thisScriptFileName=mfilename('fullpath');
  thisScriptDirName=fileparts(thisScriptFileName);
  mouseHouseDirParts=split_on_filesep(thisScriptDirName);
    % a cell array with each dir an element
  mouseStuffRootParts=mouseHouseDirParts(1:end-2);
  g_strMouseStuffRootDirName=combine_with_filesep(mouseStuffRootParts);
end

g_strctGlobalParam=fnLoadAlgorithmsConfigNative();
% old code:
if isunix && ~ismac
    strctAppParams = ...
      fnLoadConfigXML(fullfile(g_strMouseStuffRootDirName, ...
                               'Config', ...
                               'RepositoryUnix.xml'));
elseif ismac
    strctAppParams = ...
      fnLoadConfigXML(fullfile(g_strMouseStuffRootDirName, ...
                               'Config', ...
                               'RepositoryMac.xml'));
else
    strctAppParams = ...
      fnLoadConfigXML(fullfile(g_strMouseStuffRootDirName, ...
                               'Config', ...
                               'Repository.xml'));
end;
% % putative new code:
% if isunix || ismac
%     repoFilename='Config/RepositoryUnix.mat';
%     if exist(repoFilename,'file')
%         strctAppParams=fnLoadConfigMat(repoFilename);
%     else
%         strctAppParams=fnLoadRepositoryUnixDefaultConfigNative();
%     end
% else
%     repoFilename='Config/RepositoryWindows.mat';
%     if exist(repoFilename,'file')
%         strctAppParams=fnLoadConfigMat(repoFilename);
%     else
%         strctAppParams=fnLoadRepositoryWindowsDefaultConfigNative();
%     end
% end

% if isunix || ismac
%     strCurrFolder = [pwd(),'/'];
% else
%     strCurrFolder = [pwd(),'\'];
% end;
strCurrFolder = [g_strMouseStuffRootDirName filesep];
strctAppParams.m_strStartupFolder = strCurrFolder;
setappdata(handles.figure1,'strctAppParams',strctAppParams);


% Remove the deploy folders
% if isunix || ismac
%     rmpath(genpath([pwd(),'\Deploy']));
% else
%     rmpath(genpath([pwd(),'/Deploy']));
% end;
rmpath(genpath(fullfile(g_strMouseStuffRootDirName,'Deploy')));

fnRefreshIdentitiesList(handles);

fnUpdateVideoList(handles);
if isfield(strctAppParams,'m_acstrctVideoFiles') && ~isempty(strctAppParams.m_acstrctVideoFiles)
    fnSetActiveVideo(handles);
else
    fnSetDefaultImages(handles);
end;

% Update handles structure
guidata(hObject, handles);
return;

function J=fn1To3Channel(I)
if size(I,3) == 3
    J=I;
    return;
end;
J(:,:,1)=double(I)/255;
J(:,:,2)=double(I)/255;
J(:,:,3)=double(I)/255;

return;
% 
% 

function [acIdentitiesFileNames, strList] = fnGetIdentitiesList(handles)
strctAppParams = getappdata(handles.figure1,'strctAppParams');
astrctFiles = dir([strctAppParams.m_strIdentitiesFolder,'*.mat']);
acIdentitiesFileNames = cell(1, length(astrctFiles));
strList = '';
for i=1:length(astrctFiles)
    acIdentitiesFileNames{i} = [strctAppParams.m_strIdentitiesFolder,astrctFiles(i).name];
    strList = [strList,'|',astrctFiles(i).name];
end;
if ~isempty(strList)
    strList = strList(2:end);
end;
return;



function fnSetActiveVideo(handles)
% Load some frames and display them...
iCurrVideo = getappdata(handles.figure1,'iCurrVideo');
strctAppParams = getappdata(handles.figure1,'strctAppParams');

setappdata(handles.figure1,'iCurrFrame',1);
strctInfo = strctAppParams.m_acstrctVideoFiles{iCurrVideo};
setappdata(handles.figure1,'strctInfo',strctInfo);
fnInvalidate(handles);
if ~isempty(strctInfo)
    set(handles.slider1,'min',1,'max',strctInfo.m_iNumFrames,'value',1);
end;

return;

function fnSetDefaultImages(handles)
I = im2double(imread('NoImage.jpg'));
image([], [], I, 'BusyAction', 'cancel', 'Parent', handles.axes1, 'Interruptible', 'off');
set(handles.axes1,'visible','off')
% hImage2 = image([], [], I, 'BusyAction', 'cancel', 'Parent', handles.axes2, 'Interruptible', 'off');
% set(handles.axes2,'visible','off')
return;

function fnInvalidate(handles)
iCurrFrame = getappdata(handles.figure1,'iCurrFrame');
strctAppParams = getappdata(handles.figure1,'strctAppParams');
iCurrVideo = getappdata(handles.figure1,'iCurrVideo');

try
    a2iFrame = fnReadFrameFromVideo(...
        strctAppParams.m_acstrctVideoFiles{iCurrVideo},iCurrFrame);
catch
    a2iFrame = 0;
end;

image([], [], fn1To3Channel(a2iFrame), 'BusyAction', 'cancel', 'Parent', handles.axes1, 'Interruptible', 'off');
set(handles.axes1,'visible','off')
%hImage2 = image([], [], fn1To3Channel(a2bMask*255), 'BusyAction', 'cancel', 'Parent', handles.axes2, 'Interruptible', 'off');
%set(handles.axes2,'visible','off')

strctID = getappdata(handles.figure1,'strctID');

acstrColors = {'Red','Green','Blue','Cyan','Magenta','Yellow'};
if ~isempty(strctID) && isfield(strctID.strctIdentityClassifier,'m_a3fRepImages') 
    delete( get(handles.hIdentityPanel,'Children'));
    iNumMice = size(strctID.strctIdentityClassifier.m_a3fRepImages,3);
    iNumSubPlotsX = ceil(sqrt(iNumMice));
    iNumSubPlotsY = ceil(iNumMice / iNumSubPlotsX);
    for k=1:iNumMice
         tightsubplot(iNumSubPlotsY,iNumSubPlotsX,k,'Spacing',0.15,'Parent',handles.hIdentityPanel);
         imshow(strctID.strctIdentityClassifier.m_a3fRepImages(:,:,k),[]);
         title([num2str(k),' ',acstrColors{k}]);
    end;
else
    delete(get(handles.hIdentityPanel,'Children'));
end
    
    
return;


function fnUpdateVideoList(handles)
strctAppParams = getappdata(handles.figure1,'strctAppParams');

if ~isfield(strctAppParams,'m_acstrctVideoFiles')
    strctAppParams.m_acstrctVideoFiles =  cell(0);
end;

iNumVideos = length(strctAppParams.m_acstrctVideoFiles);
acMovieNames = cell(1,iNumVideos);
for k=1:iNumVideos
    acMovieNames{k} =strctAppParams.m_acstrctVideoFiles{k}.m_strFileName;
    astrctInfo(k) = dir(acMovieNames{k});
end;

strOptions = '';
for k=1:length(acMovieNames)
strOptions  = [strOptions,'|',astrctInfo(k).date,' ',acMovieNames{k}];
end;
if ~isempty(strOptions)
    strOptions = strOptions(2:end);
end;
set(handles.hVideoFileList,'String',strOptions,'value',1,'Min',1,'Max',length(acMovieNames));
return;



% --- Outputs from this function are returned to the command line.
function varargout = Repository_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function hSubmitJobs_Callback(hObject, eventdata, handles)
answer = questdlg('Submit to cluster?','Question','Yes','No','Yes');
if isempty(answer)
    return;
end;

if strcmp(answer,'Yes')
    bRunLocal =  false;
else
    bRunLocal =  true;
end;

if ~bRunLocal 
     ButtonName = questdlg('Did you compile and package the application?', ...
                         'Important message!', ...
                         'Yes', 'No (but compile and continue)', 'No (exit)');
    if strcmpi(ButtonName,'No (exit)')
        return; 
    end;
    if strcmpi(ButtonName,'No (but compile and continue)')
        fnCompile();
    end;
end;

drawnow
strctAppParams = getappdata(handles.figure1,'strctAppParams');
acIdentitiesFileNames = getappdata(handles.figure1,'acIdentitiesFileNames');
iCurrID = getappdata(handles.figure1,'iCurrID');
strIdentitiesFile = acIdentitiesFileNames{iCurrID};
aiSelectedVideos = get(handles.hVideoFileList,'value');
for iVideoIter=1:length(aiSelectedVideos)
    fnSubmitMovieToProcessing(...
        strctAppParams.m_acstrctVideoFiles{aiSelectedVideos(iVideoIter)}.m_strFileName,...
        strctAppParams.m_strJobFolder,strctAppParams.m_strResultsRootFolder, ...
        strIdentitiesFile,...
         strctAppParams.m_strStartupFolder,bRunLocal,false);
end;
return;


    
% --------------------------------------------------------------------
function hAddVideoSeq_Callback(hObject, eventdata, handles)
strctAppParams = getappdata(handles.figure1,'strctAppParams');

% get file names from the user
[acstrFile, strPath] = uigetfile([strctAppParams.m_strDataRootFolder,'*.avi;*.seq'],'MultiSelect', 'on');
if strPath == 0
    % user pressed "cancel"
    return;
end;

% if acstrFile is a string, turn it into a singleton cell array of strings
if ~iscell(acstrFile)
    acstrFile = {acstrFile};
end;

% get the video info for the files
iNumFilesNew=length(acstrFile);
acstrctVideoFilesNew=cell(1,iNumFilesNew);
for i=1:length(acstrFile)
    strFileNameThis=fullfile(strPath,acstrFile{i});
    try
        acstrctVideoFilesNew{i} = fnReadVideoInfo(strFileNameThis);
    catch excp
        if strcmp(excp.identifier, ...
                  'MATLAB:audiovideo:mmreader:PluginRequirement')
            errordlg(sprintf('Unable to get info on file %s.', ...
                             acstrFile{i}), ...
                     'Error');
            return;
        else
            rethrow(excp);
        end
    end
end

% append the new files to the existing ones
if ~isfield(strctAppParams,'m_acstrctVideoFiles')
    strctAppParams.m_acstrctVideoFiles = acstrctVideoFilesNew;
else
    strctAppParams.m_acstrctVideoFiles = ...
        [strctAppParams.m_acstrctVideoFiles acstrctVideoFilesNew];
end

setappdata(handles.figure1,'strctAppParams',strctAppParams);
iCurrVideo = length(strctAppParams.m_acstrctVideoFiles);
setappdata(handles.figure1,'iCurrVideo',iCurrVideo);

fnUpdateVideoList(handles);
fnSetActiveVideo(handles);
set(handles.hVideoFileList,'Value',iCurrVideo);

return;

% --------------------------------------------------------------------
function hRemoveVideoSeq_Callback(hObject, eventdata, handles)
aiSelected = get(handles.hVideoFileList,'value');
strctAppParams = getappdata(handles.figure1,'strctAppParams');
if isempty(strctAppParams.m_acstrctVideoFiles)
    return;
end;
strctAppParams.m_acstrctVideoFiles(aiSelected) = [];
set(handles.hVideoFileList,'value',1);
setappdata(handles.figure1,'strctAppParams',strctAppParams);
fnUpdateVideoList(handles);
return;

% --------------------------------------------------------------------
function hSaveList_Callback(hObject, eventdata, handles)
global g_strMouseStuffRootDirName;
strctAppParams = getappdata(handles.figure1,'strctAppParams');
if isunix && ~ismac
    strConfigFileName=fullfile(g_strMouseStuffRootDirName, ...
                               'Config','RepositoryUnix.xml');
elseif ismac
    strConfigFileName=fullfile(g_strMouseStuffRootDirName, ...
                               'Config','RepositoryMac.xml');
else
    strConfigFileName=fullfile(g_strMouseStuffRootDirName, ...
                               'Config','Repository.xml');
end;
fnSaveConfigAsXML(strConfigFileName, strctAppParams);
msgbox('Repository List Saved');
return;


% --- Executes on selection change in hVideoFileList.
function hVideoFileList_Callback(hObject, eventdata, handles)
aiNewSeq = get(hObject,'Value');
iCurrVideo = aiNewSeq;
setappdata(handles.figure1,'iCurrVideo',iCurrVideo);
if length(aiNewSeq) == 1
    fnSetActiveVideo(handles);
else
    fnSetDefaultImages(handles);
end;

return;

% --- Executes during object creation, after setting all properties.
function hVideoFileList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hVideoFileList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function [strOutputFolder,bExist] = fnGetMovieResultFolder(handles,strMovieFileName)
if isunix || ismac
    aiSlash = find(strMovieFileName == '/',1,'last');
else
    aiSlash = find(strMovieFileName == '\',1,'last');
end;
strctAppParams = getappdata(handles.figure1,'strctAppParams');
strMovieFileNameNoExt = strMovieFileName(aiSlash+1:end-4);
if isunix || ismac
    strOutputFolder = [strctAppParams.m_strResultsRootFolder, strMovieFileNameNoExt,'/'];
else
    strOutputFolder = [strctAppParams.m_strResultsRootFolder, strMovieFileNameNoExt,'\'];
end;
bExist = exist(strOutputFolder,'dir');
return;

function [strOutputFolder,bExist] = fnGetMovieJobFolder(handles,strMovieFileName)
if isunix || ismac
    aiSlash = find(strMovieFileName == '/',1,'last');
else
    aiSlash = find(strMovieFileName == '\',1,'last');
end;
strctAppParams = getappdata(handles.figure1,'strctAppParams');

strMovieFileNameNoExt = strMovieFileName(aiSlash+1:end-4);
if isunix || ismac
    strOutputFolder = [strctAppParams.m_strJobFolder, strMovieFileNameNoExt,'/'];
else
    strOutputFolder = [strctAppParams.m_strJobFolder, strMovieFileNameNoExt,'\'];
end;
bExist = exist(strOutputFolder,'dir');
return;

% --------------------------------------------------------------------
function hCollectJobResults_Callback(hObject, eventdata, handles)
aiSelectedVideos = get(handles.hVideoFileList,'value');
if length(aiSelectedVideos) > 1
    errordlg('Only one sequence can be post processed.');
end;
strctAppParams = getappdata(handles.figure1,'strctAppParams');
[strResultsFolder,bExist] = fnGetMovieResultFolder(handles,...
    strctAppParams.m_acstrctVideoFiles{aiSelectedVideos}.m_strFileName);
if ~bExist
    errordlg('No results found');
end;
[strJobFolder] = fnGetMovieJobFolder(handles,...
    strctAppParams.m_acstrctVideoFiles{aiSelectedVideos}.m_strFileName);

iCurrID = getappdata(handles.figure1,'iCurrID');
acFileNames = getappdata(handles.figure1,'acIdentitiesFileNames');
if length(acFileNames) >= 1
	strIDFile = acFileNames{iCurrID};
else
	strIDFile = [];
end

strMovieFileName=...
    strctAppParams.m_acstrctVideoFiles{aiSelectedVideos}.m_strFileName;
launchResultsEditor(strJobFolder, ...
                    strResultsFolder, ...
                    strctAppParams.m_strIdentitiesFolder,...
                    strIDFile,...
                    strMovieFileName);
return;

% --- Executes on selection change in hSetupsList.
function hSetupsList_Callback(hObject, eventdata, handles)
iCurrID = get(hObject,'value');
setappdata(handles.figure1,'iCurrID',iCurrID);
fnSetCurrID(handles);
fnInvalidate(handles);
return;

% --- Executes during object creation, after setting all properties.
function hSetupsList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hSetupsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
iCurrFrame = round(get(hObject,'value'));
setappdata(handles.figure1,'iCurrFrame',iCurrFrame);
fprintf('Seeking to %d\n',round(iCurrFrame ));
fnInvalidate(handles);
%guidata(hObject,handles);
return;


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --------------------------------------------------------------------
function Untitled_9_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% 
% % --------------------------------------------------------------------
% function hEditSetup_Callback(hObject, eventdata, handles)
% acSetupFileNames = getappdata(handles.figure1,'acSetupFileNames');
% SetupEditor(handles.strctAppParams.m_acstrctVideoFiles{handles.iCurrVideo}.m_strFileName, ...
%     handles.strctAppParams.m_strSetupsFolder,...
%     acSetupFileNames{handles.iCurrSetup},...
%     handles.iCurrFrame);
% 
% [acSetupFileNames, strList] = fnGetSetupsList(handles);
% set(handles.hSetupsList, 'String',strList);
% handles.acSetupFileNames = acSetupFileNames;
% if ~isempty(acSetupFileNames)
%     handles.strctAdditionalInfo = fnGetActiveSetup(handles);
% end;
% fnInvalidate(handles);
% guidata(hObject, handles);
% 
% return;

function fnSetCurrID(handles)
iCurrID = getappdata(handles.figure1,'iCurrID');
acFileNames = getappdata(handles.figure1,'acIdentitiesFileNames');
if length(acFileNames) >= 1
    strctID = load(acFileNames{iCurrID});
    setappdata(handles.figure1,'strctID',strctID);
else
    setappdata(handles.figure1,'strctID',[]);    
end
return;


function fnRefreshIdentitiesList(handles)
[acFileNames, strList] = fnGetIdentitiesList(handles);
set(handles.hSetupsList, 'String',strList,'value',1);
setappdata(handles.figure1,'acIdentitiesFileNames',acFileNames);
fnSetCurrID(handles)
return;


function Untitled_1_Callback(hObject, eventdata, handles)
function Untitled_6_Callback(hObject, eventdata, handles)
function Untitled_8_Callback(hObject, eventdata, handles)


 
% --------------------------------------------------------------------
function hRunAnnotationGUI_Callback(hObject, eventdata, handles)
aiSelectedVideos = get(handles.hVideoFileList,'value');
if length(aiSelectedVideos) > 1
    errordlg('Can not run annotation gui for multiple videos');
    return;
end;
strctAppParams = getappdata(handles.figure1,'strctAppParams');
strMovieFileName = strctAppParams.m_acstrctVideoFiles{aiSelectedVideos(1)}.m_strFileName;
strOutputFolder = fnGetMovieResultFolder(handles,strMovieFileName);
strctID = getappdata(handles.figure1,'strctID');
NewAnnotationGUI(strMovieFileName, strOutputFolder,strctID);
return;


% --------------------------------------------------------------------
function hLearnSingleMouseIdentity_Callback(hObject, eventdata, handles)
global g_strctGlobalParam g_strMouseStuffRootDirName;
aiSelectedVideos = get(handles.hVideoFileList,'value');
strctAppParams = getappdata(handles.figure1,'strctAppParams');
strOutputPath = strctAppParams.m_strResultsRootFolder;

answer = questdlg('Submit to cluster?','Question','Yes','No','Yes');
if isempty(answer)
    return;
end;
if ~strcmpi(answer,'Yes')
    if isunix
        if strOutputPath(end) ~= '/'
            strOutputPath(end+1) = '/';
        end;
    else
        if strOutputPath(end) ~= '\'
            strOutputPath(end+1) = '\';
        end;
    end;

    strConfigFileName=fullfile(g_strMouseStuffRootDirName,'Config','Algorithms.xml');
    g_strctGlobalParam = fnLoadAlgorithmsConfigXML(strConfigFileName);
    %g_strctGlobalParam=fnLoadAlgorithmsConfigNative();
    for iVideoIter=1:length(aiSelectedVideos)
        strMovieFileName = strctAppParams.m_acstrctVideoFiles{aiSelectedVideos(iVideoIter)}.m_strFileName;
        [strPath,strFile]=fileparts(strMovieFileName);
        strOutputFileName = fullfile(strOutputPath,strFile,'Identities.mat');
        a2bMask = fnMarkOrLoadFloorPlan(strOutputPath,strFile,strMovieFileName);
        if isempty(a2bMask)
            return;
        end
        strctBootstrap.m_a2bMask = a2bMask;
        fnLearnMouseIdentity(strMovieFileName,strctBootstrap,strOutputFileName);
        
    end;
else
    
    
     ButtonName = questdlg('Did you compile and package the application?', ...
                         'Important message!', ...
                         'Yes', 'No (but compile and continue)', 'No (exit)');
    if strcmpi(ButtonName,'No (exit)')
        return; 
    end;
    if strcmpi(ButtonName,'No (but compile and continue)')
        fnCompile();
    end;
    
    %Make job files
   for iVideoIter=1:length(aiSelectedVideos)
       strMovieFileName = strctAppParams.m_acstrctVideoFiles{aiSelectedVideos(iVideoIter)}.m_strFileName;
       [strPath,strFile]=fileparts(strMovieFileName);
       strOutputFileName = [strOutputPath,strFile,'/Identities.mat'];
       strctMovieInfo= fnReadVideoInfo(strMovieFileName);

       a2bMask = fnMarkOrLoadFloorPlan(strOutputPath,strFile,strMovieFileName);
       if isempty(a2bMask)
           return;
       end;
       strctBootstrap.m_a2bMask = a2bMask; 
       
      strJobFolder = [strctAppParams.m_strJobFolder,strFile,'/'];
       if ~exist(strJobFolder,'dir')
           mkdir(strJobFolder);
       end;
       strJobName = sprintf('%sJobargin%d.mat',strJobFolder, 1);
       fnCreateJob(strMovieFileName, strctMovieInfo, ...
           1:strctMovieInfo.m_iNumFrames, strctBootstrap, [], strOutputFileName, iVideoIter,strJobName,true);
       strSubmitFile = [strJobFolder,'submitscript'];
       fprintf('Generating Submit file at %s\n', strSubmitFile);    
       hFileID = fopen(strSubmitFile,'w');
       fprintf(hFileID,'#!/bin/bash\n');
       fprintf(hFileID,'%sDeploy/MouseTrackProj/src/MouseTrackProj %sJobargin${SGE_TASK_ID}.mat\n',...
           strctAppParams.m_strStartupFolder, strJobFolder);
       fclose(hFileID);
       %fprintf('Changing Premission\n');
       system(['chmod 755 ',strSubmitFile]);
       fprintf('Submitting Jobs\n');
       strCmd = sprintf('qsub -t 1 -N MouseJob -e %s -o %s -b y -cwd -V ''%s''',strJobFolder(1:end-1), strJobFolder(1:end-1), strSubmitFile);
       strCmdFile = [strJobFolder,'resubmit'];
       hFileID = fopen(strCmdFile,'w');
       fprintf(hFileID,'%s\n',strCmd);
       fclose(hFileID);
       system(strCmd);
   end;      
   % Submit jobs
end;

return;


% --------------------------------------------------------------------
function hTrainClassifiers_Callback(hObject, eventdata, handles)
global g_strctGlobalParam
aiSelectedVideos = get(handles.hVideoFileList,'value');
strctAppParams = getappdata(handles.figure1,'strctAppParams');
strOutputPath = strctAppParams.m_strResultsRootFolder;
strIdentitiesFolder = strctAppParams.m_strIdentitiesFolder;
acSelectedMovies = strctAppParams.m_acstrctVideoFiles(aiSelectedVideos);
fnTrainTdistClassifiers(acSelectedMovies,strOutputPath,strIdentitiesFolder);
fnRefreshIdentitiesList(handles);
return;


% --------------------------------------------------------------------
function hVerifyTracking_Callback(hObject, eventdata, handles)
aiSelectedVideos = get(handles.hVideoFileList,'value');
strctAppParams = getappdata(handles.figure1,'strctAppParams');
acSelectedMovies = strctAppParams.m_acstrctVideoFiles(aiSelectedVideos);
strResultsRootFolder = strctAppParams.m_strResultsRootFolder;

for k=1:length(acSelectedMovies)
      
    [strPath, strFile] = fileparts(acSelectedMovies{k}.m_strFileName);
    if ispc
        strResultsFileName = [strResultsRootFolder,strFile,'\Identities.mat'];
    else
        strResultsFileName = [strResultsRootFolder,strFile,'/Identities.mat'];
    end;
    
    if ~exist(strResultsRootFolder,'file')
        msgbox(sprintf('Tracking results for %s were not found',strFile));
        continue;
    else
        if ~exist(strResultsFileName,'file')
            errordlg(sprintf('Results for single mouse tracking were not found for sequence %s',strResultsFileName));
            continue;
        end;
        strctTmp = load(strResultsFileName);
        
        hFig = figure;
        set(hFig,'Name',acSelectedMovies{k}.m_strFileName);
        hAxes = axes;
        setappdata(hFig,'hAxes',hAxes);
        setappdata(hFig,'strctMovInfo',acSelectedMovies{k});
        I=fnReadFrameFromVideo(acSelectedMovies{k},1);
        hImage = image([], [], I, 'BusyAction', 'cancel', 'Parent', hAxes, 'Interruptible', 'off','CDataMapping', 'scaled');
        setappdata(hFig,'hImage',hImage);
        colormap gray
        set(hAxes,'visible','off')
        setappdata(hFig,'strctIdentity',strctTmp.strctIdentity);
        set(hAxes,'units','pixels');
        A=get(hFig,'position');
        hSlider = uicontrol('style','slider','units','pixels','position',[100 10 A(3)-40 20],'parent',hFig,...
        'min',1,'max',acSelectedMovies{k}.m_iNumFrames,'sliderstep',[1/acSelectedMovies{k}.m_iNumFrames 10/acSelectedMovies{k}.m_iNumFrames], 'value',1,'callback',{@fnVerifyTrackingResults, hFig});

        hPlay = uicontrol('style','pushbutton','units','pixels','position',[10 10 70 20],'parent',hFig,...
        'String','Play','callback',{@fnVerifyTrackingResultsPlay, hFig});
    
        hold(hAxes,'on');
        setappdata(hFig,'hSlider',hSlider);
        fnVerifyTrackingResults(hSlider,[], hFig);
    end;
end;

function fnVerifyTrackingResultsPlay(a,b, hFig)
global g_bPlaying
if isempty(g_bPlaying)
    g_bPlaying = 0;
end
g_bPlaying = ~g_bPlaying;

strctMovInfo = getappdata(hFig,'strctMovInfo');
strctIdentity = getappdata(hFig,'strctIdentity');
hImage = getappdata(hFig,'hImage');

hSlider=getappdata(hFig,'hSlider');
iCurrSliderFrame = get(hSlider,'value');
for iNewFrame=round(iCurrSliderFrame:strctMovInfo.m_iNumFrames)
    if ~ishandle(hSlider)
        break;
    end
    
    set(hSlider,'value',iNewFrame);
    I=fnReadFrameFromVideo(strctMovInfo,iNewFrame);
    set(hImage,'cdata',I);
    ahDrawHandles = getappdata(hFig,'ahDrawHandles');
    delete(ahDrawHandles);
    hAxes = getappdata(hFig,'hAxes');
    strctTracker.m_fX = strctIdentity.m_afX(iNewFrame);
    strctTracker.m_fY = strctIdentity.m_afY(iNewFrame);
    strctTracker.m_fA = strctIdentity.m_afA(iNewFrame);
    strctTracker.m_fB = strctIdentity.m_afB(iNewFrame);
    strctTracker.m_fTheta = strctIdentity.m_afTheta(iNewFrame);
    ahDrawHandles = fnDrawTracker(hAxes,strctTracker, [0 1 0], 2, false);
    ahDrawHandles(end+1) = text(1,40,num2str(iNewFrame),'color',[1 0 0]);
    setappdata(hFig,'ahDrawHandles',ahDrawHandles);
    if ~g_bPlaying
        break;
    end
    drawnow 
    drawnow update 
end

return;

function fnVerifyTrackingResults(a,b, hFig)
iNewFrame = round(get(a,'value'));
strctMovInfo = getappdata(hFig,'strctMovInfo');
strctIdentity = getappdata(hFig,'strctIdentity');
hImage = getappdata(hFig,'hImage');
I=fnReadFrameFromVideo(strctMovInfo,iNewFrame);
set(hImage,'cdata',I);
ahDrawHandles = getappdata(hFig,'ahDrawHandles');
delete(ahDrawHandles);
hAxes = getappdata(hFig,'hAxes');

strctTracker.m_fX = strctIdentity.m_afX(iNewFrame);
strctTracker.m_fY = strctIdentity.m_afY(iNewFrame);
strctTracker.m_fA = strctIdentity.m_afA(iNewFrame);
strctTracker.m_fB = strctIdentity.m_afB(iNewFrame);
strctTracker.m_fTheta = strctIdentity.m_afTheta(iNewFrame);

ahDrawHandles = fnDrawTracker(hAxes,strctTracker, [0 1 0], 2, false);
ahDrawHandles(end+1) = text(1,40,num2str(iNewFrame),'color',[1 0 0]);
setappdata(hFig,'ahDrawHandles',ahDrawHandles);

return;


% --------------------------------------------------------------------
function hCreateSetup_Callback(hObject, eventdata, handles)
[strFile,strPath] = uigetfile('*.mat','Enter Classifiers File');
if strFile(1) == 0
    return;
end;
strctClass = load([strPath,strFile]);
[strFile1,strPath1] = uigetfile('*.mat','Enter Background File');
if strFile1(1) == 0
    return;
end;
strctBack = load([strPath1,strFile1]);


strctAdditionalInfo.strctBackground = strctBack.strctBackground;
strctAdditionalInfo.strctAppearance.m_iNumBins = 10;
strctAdditionalInfo.strctAppearance.m_a2fFeatures = strctClass.a2fAppearanceFeatures;



strctAdditionalInfo.m_a3fRepresentativeClassImages = strctClass.strctIdentityClassifier.m_a3fRepImages;

strctAdditionalInfo.m_strctHeadTailClassifier.iNumBins = 10;
strctAdditionalInfo.m_strctHeadTailClassifier.iNumFeatures = size(strctClass.strctHeadTailClassifier.m_a2fW,1);
strctAdditionalInfo.m_strctHeadTailClassifier.W = strctClass.strctHeadTailClassifier.m_a2fW;
strctAdditionalInfo.m_strctHeadTailClassifier.fThres = strctClass.strctHeadTailClassifier.m_afThres;
strctAdditionalInfo.m_strctHeadTailClassifier.afX = strctClass.strctHeadTailClassifier.m_a2fX;
strctAdditionalInfo.m_strctHeadTailClassifier.afHistPos = strctClass.strctHeadTailClassifier.m_a2fHistPos;
strctAdditionalInfo.m_strctHeadTailClassifier.afHistNeg = strctClass.strctHeadTailClassifier.m_a2fHistNeg;
strctAdditionalInfo.m_strctHeadTailClassifier.afProbPos = strctClass.strctHeadTailClassifier.m_a2fProb;
strctAdditionalInfo.m_strctMiceIdentityClassifier.iNumMice = size(strctClass.strctIdentityClassifier.m_a2fW,2);
strctAdditionalInfo.m_strctMiceIdentityClassifier.iNumBins = 10;
strctAdditionalInfo.m_strctMiceIdentityClassifier.iNumFeatures = size(strctClass.strctIdentityClassifier.m_a2fW,1);
strctAdditionalInfo.m_strctMiceIdentityClassifier.a2fW = strctClass.strctIdentityClassifier.m_a2fW;
strctAdditionalInfo.m_strctMiceIdentityClassifier.a2fX = strctClass.strctIdentityClassifier.m_a2fX;
strctAdditionalInfo.m_strctMiceIdentityClassifier.a2fProb = strctClass.strctIdentityClassifier.m_a2fProb;
strctAdditionalInfo.m_strctMiceIdentityClassifier.afThres = strctClass.strctIdentityClassifier.m_afThres;

[strFile,strPath] = uiputfile('Setup.mat');
if strFile(1) == 0
    return;
end;
save([strPath,strFile],'strctAdditionalInfo');
fnRefreshSetupList(handles);
return;


% --------------------------------------------------------------------
function hSortByTimestamp_Callback(hObject, eventdata, handles)
%aiSelectedVideos = get(handles.hVideoFileList,'value');
strctAppParams = getappdata(handles.figure1,'strctAppParams');
iNumVideos = length(strctAppParams.m_acstrctVideoFiles);
afFirstFrame = zeros(1,iNumVideos);
for iVideoIter=1:iNumVideos
    afFirstFrame(iVideoIter) = strctAppParams.m_acstrctVideoFiles{iVideoIter}.m_afTimestamp(1);
end;
[afDummy,aiIndices] = sort(afFirstFrame);
strctAppParams.m_acstrctVideoFiles = strctAppParams.m_acstrctVideoFiles(aiIndices);
setappdata(handles.figure1,'strctAppParams',strctAppParams);
fnUpdateVideoList(handles);

return;


% --------------------------------------------------------------------
function hGroundTruthEditor_Callback(hObject, eventdata, handles)
strctAppParams = getappdata(handles.figure1,'strctAppParams');
acIdentitiesFileNames = getappdata(handles.figure1,'acIdentitiesFileNames');
iCurrID = getappdata(handles.figure1,'iCurrID');
strIdentitiesFile = acIdentitiesFileNames{iCurrID};
aiSelectedVideos = get(handles.hVideoFileList,'value');
UnbiasedGroundTruthGUI(strIdentitiesFile,strctAppParams.m_acstrctVideoFiles{aiSelectedVideos(1)}.m_strFileName,...
    strctAppParams.m_strResultsRootFolder);

return;


% --------------------------------------------------------------------
function hCleanFolders_Callback(hObject, eventdata, handles)
strctAppParams = getappdata(handles.figure1,'strctAppParams');
aiSelectedVideos = get(handles.hVideoFileList,'value');
if ispc
    cSlash = '\';
else
    cSlash = '/';
end

for iVideoIter=1:length(aiSelectedVideos)
    [strTmp,strFile] = fileparts(strctAppParams.m_acstrctVideoFiles{aiSelectedVideos(iVideoIter)}.m_strFileName);
    if exist([strctAppParams.m_strJobFolder, strFile],'dir')
        if ispc
            strCmd = ['del "',strctAppParams.m_strJobFolder, strFile,cSlash,'*"'];
        else
            strCmd = ['rm ',strctAppParams.m_strJobFolder, strFile,cSlash,'*'];
        end
        strAns = questdlg(strCmd,'Check!','Yes','No','Yes');
        if strcmp(strAns,'Yes')
            system(strCmd);
        end;
    end
 
    if exist([strctAppParams.m_strResultsRootFolder, strFile],'dir')
        if ispc
            strCmd = ['del "',strctAppParams.m_strResultsRootFolder, strFile,cSlash,'*"'];
        else
            strCmd = ['rm ',strctAppParams.m_strResultsRootFolder, strFile,cSlash,'JobOut*'];
        end
        strAns = questdlg(strCmd,'Check!','Yes','No','Yes');
        if strcmp(strAns,'Yes')
            system(strCmd);
        end;
    end
    
end;


% --------------------------------------------------------------------
function hFastSubmit_Callback(hObject, eventdata, handles)
bRunLocal =  false;
strctAppParams = getappdata(handles.figure1,'strctAppParams');
acIdentitiesFileNames = getappdata(handles.figure1,'acIdentitiesFileNames');
iCurrID = getappdata(handles.figure1,'iCurrID');
strIdentitiesFile = acIdentitiesFileNames{iCurrID};
aiSelectedVideos = get(handles.hVideoFileList,'value');
for iVideoIter=1:length(aiSelectedVideos)
    fprintf('Auto Submitting %s\n',strctAppParams.m_acstrctVideoFiles{aiSelectedVideos(iVideoIter)}.m_strFileName);
    fnSubmitMovieToProcessing(...
        strctAppParams.m_acstrctVideoFiles{aiSelectedVideos(iVideoIter)}.m_strFileName,...
        strctAppParams.m_strJobFolder,strctAppParams.m_strResultsRootFolder, ...
        strIdentitiesFile,...
         strctAppParams.m_strStartupFolder,bRunLocal,true);
end;
return;


% --------------------------------------------------------------------
function hFastMerge_Callback(hObject, eventdata, handles)
bRunLocal =  false;
strctAppParams = getappdata(handles.figure1,'strctAppParams');
acIdentitiesFileNames = getappdata(handles.figure1,'acIdentitiesFileNames');
iCurrID = getappdata(handles.figure1,'iCurrID');
strIdentitiesFile = acIdentitiesFileNames{iCurrID};
aiSelectedVideos = get(handles.hVideoFileList,'value');
for iVideoIter=1:length(aiSelectedVideos)
    fnFastMergeJobs2(strctAppParams.m_acstrctVideoFiles{aiSelectedVideos(iVideoIter)}.m_strFileName,...
        strctAppParams.m_strResultsRootFolder, ...
        strIdentitiesFile);
end


% --------------------------------------------------------------------
function hRandomizeTrackingResults_Callback(hObject, eventdata, handles)
strctAppParams = getappdata(handles.figure1,'strctAppParams');
aiSelectedVideos = get(handles.hVideoFileList,'value');
strPath = uigetdir();
if strPath(1) == 0
    return;
end;

for iIter=1:length(aiSelectedVideos)
    
    [strTmp, strFile]=fileparts(strctAppParams.m_acstrctVideoFiles{aiSelectedVideos(iIter)}.m_strFileName);
    strResultsFile = [strPath, '/',strFile,'.mat'];
    if ~exist(strResultsFile,'file')
        fprintf('Result file (%s) is missing\n',strResultsFile);
        continue;
    end
    load(strResultsFile);
iNumMice = length(astrctTrackers);
iNumFrames = length(astrctTrackers(1).m_afX);
a2iRandPerm = zeros(iNumFrames,iNumMice);
fprintf('Generating random permutations. This might take some time...\n');
astrctTrackersRand = astrctTrackers;
aiRandPerm = randperm(iNumMice);  end

for iFrameIter=1:iNumFrames
    if mod(iFrameIter-1+75,150) == 0
        aiRandPerm = randperm(iNumMice);
    end
    a2iRandPerm(iFrameIter,:) = aiRandPerm;
    for iMouseIter=1:iNumMice
        astrctTrackersRand(iMouseIter).m_afX(iFrameIter) = astrctTrackers(aiRandPerm(iMouseIter)).m_afX(iFrameIter);
        astrctTrackersRand(iMouseIter).m_afY(iFrameIter) = astrctTrackers(aiRandPerm(iMouseIter)).m_afY(iFrameIter);
        astrctTrackersRand(iMouseIter).m_afA(iFrameIter) = astrctTrackers(aiRandPerm(iMouseIter)).m_afA(iFrameIter);
        astrctTrackersRand(iMouseIter).m_afB(iFrameIter) = astrctTrackers(aiRandPerm(iMouseIter)).m_afB(iFrameIter);
        astrctTrackersRand(iMouseIter).m_afTheta(iFrameIter) = astrctTrackers(aiRandPerm(iMouseIter)).m_afTheta(iFrameIter);
    end
end
astrctTrackers = astrctTrackersRand;
if exist('afTimeStamp','var')
    save([strPath, strFile(1:end-4),'_Randomized.mat'],'strMovieFileName','afTimeStamp','afProcessingTime','astrctTrackers','a2iRandPerm');
else
    if exist('strMovieFileName','var')
        save([strPath, strFile(1:end-4),'_Randomized.mat'],'strMovieFileName','astrctTrackers','a2iRandPerm');
    else
        save([strPath, strFile(1:end-4),'_Randomized.mat'],'astrctTrackers','a2iRandPerm');
    end
end

fprintf('Done. Randomized results saved to %s\n',[strPath, strFile(1:end-4),'_Randomized.mat']);


% --------------------------------------------------------------------
function hUnrandomizeGT_Callback(hObject, eventdata, handles)
strctAppParams = getappdata(handles.figure1,'strctAppParams');
[strFiles,strPath]=uigetfile([strctAppParams.m_strResultsRootFolder,'\*.mat'],'Select file to unrandomize','MultiSelect','on');
if ~iscell(strFiles)
    strFiles = {strFiles};
end

if strFiles{1}(1) == 0
    return;
end;
for iFileIter=1:length(strFiles)
    strFile = strFiles{iFileIter};
fprintf('Loading %s\n',[strPath, strFile]);

    load([strPath, strFile]);

iNumMice = length(astrctTrackers);

iNumKeyFrames = length(astrctGT);
for iKeyFrameIter=1:iNumKeyFrames
    %astrctGT(iKeyFrameIter).m_aiPerm = [4,1,3,2]
    % means that image A was assigned to identity 4
    % means that image B was assigned to identity 1
    % means that image C was assigned to identity 3
    % means that image D was assigned to identity 2
    % ...
    % But, since we permuted the trackers, we actually have:
    % aiPerm = [2,3,4,1] meaning
    % image A got the results of tracker 2
    % image B got the results of tracker 3
    % image C got the results of tracker 4
    % image D got the results of tracker 1
    % ....
    % Tracker  [2  
    % Identity [4 
    % Meaning... 
    % tracker 1 was actually assigned to identity 4
    % tracker 2 was actually assigned to identity 3
    % tracker 3 was actually assigned to identity 2
    % tracker 4 was actually assigned to identity 1
    % Which is equivalent to...
    aiTracker = a2iRandPerm(astrctGT(iKeyFrameIter).m_iFrame,:);
    aiIdentity = astrctGT(iKeyFrameIter).m_aiPerm;
    
    aiNewPerm = zeros(1,iNumMice);
    aiNewPerm(aiTracker) = aiIdentity;
    
    abTailSwap = zeros(1,iNumMice)>0;
    abTailSwap(aiTracker) = astrctGT(iKeyFrameIter).m_abHeadTailSwap;
    
    astrctGT(iKeyFrameIter).m_abHeadTailSwap = abTailSwap;
    astrctGT(iKeyFrameIter).m_aiPerm = aiNewPerm;
    
end


iNumMice = length(astrctTrackers);
iNumFrames = length(astrctTrackers(1).m_afX);
fprintf('Generating unrandomized permutations. This might take some time...\n');
astrctTrackersUnRand = astrctTrackers;

for iFrameIter=1:iNumFrames
    aiRandPerm = a2iRandPerm(iFrameIter,:);
    for iMouseIter=1:iNumMice
        astrctTrackersUnRand(aiRandPerm(iMouseIter)).m_afX(iFrameIter) = astrctTrackers(iMouseIter).m_afX(iFrameIter);
        astrctTrackersUnRand(aiRandPerm(iMouseIter)).m_afY(iFrameIter) = astrctTrackers((iMouseIter)).m_afY(iFrameIter);
        astrctTrackersUnRand(aiRandPerm(iMouseIter)).m_afA(iFrameIter) = astrctTrackers((iMouseIter)).m_afA(iFrameIter);
        astrctTrackersUnRand(aiRandPerm(iMouseIter)).m_afB(iFrameIter) = astrctTrackers((iMouseIter)).m_afB(iFrameIter);
        astrctTrackersUnRand(aiRandPerm(iMouseIter)).m_afTheta(iFrameIter) = astrctTrackers((iMouseIter)).m_afTheta(iFrameIter);
    end
end
astrctTrackers = astrctTrackersUnRand;


save([strPath, strFile(1:end-4),'_UnRandomized.mat'],'astrctTrackers','astrctGT');
fprintf('Saving result to %s\n',[strPath, strFile(1:end-4),'_UnRandomized.mat']);
end


% --------------------------------------------------------------------
function hGTEditor_Callback(hObject, eventdata, handles)
% hObject    handle to hGTEditor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
strctAppParams = getappdata(handles.figure1,'strctAppParams');
acIdentitiesFileNames = getappdata(handles.figure1,'acIdentitiesFileNames');
iCurrID = getappdata(handles.figure1,'iCurrID');
strIdentitiesFile = acIdentitiesFileNames{iCurrID};
aiSelectedVideos = get(handles.hVideoFileList,'value');
GroundTruthGUI(strIdentitiesFile,strctAppParams.m_acstrctVideoFiles{aiSelectedVideos(1)}.m_strFileName,...
    strctAppParams.m_strResultsRootFolder);


% --------------------------------------------------------------------
function hTuneBackgroundFromScratch_Callback(hObject, eventdata, handles)
%
strctInfo = getappdata(handles.figure1,'strctInfo');
strctID = getappdata(handles.figure1,'strctID');

strOutputFolder = 'TestTuneSegmentation';

% Sometimes, you can get to here with strctID empty.
% I put this code in as a patch---Obviously, the correct fix has to
% happen elsewhere, but I don't know where right now.  ALT, 2012/02/16
if isempty(strctID)
    errordlg(['Can''t tune background right now, becasue strctID ' ...
              'appdata is empty.'], ...
             'Internal error');
    return;
end

fnTuneBackgroundFromScratch(strctInfo, strctID, strOutputFolder);


% --------------------------------------------------------------------
function hRetuneBackground_Callback(hObject, eventdata, handles)
% hObject    handle to hRetuneBackground (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

strOutputFolder = 'TestTuneSegmentation';
strctID = getappdata(handles.figure1,'strctID');
iNumMice = length(strctID.strctIdentityClassifier.m_astrctClassifiers);
astrctSampleFrames = TuneSegmentstionGUI(strOutputFolder, iNumMice);
