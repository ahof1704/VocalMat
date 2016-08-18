function varargout = MouseHouse(varargin)
% MOUSEHOUSE M-file for MouseHouse.fig
%      MOUSEHOUSE, by itself, creates a new MOUSEHOUSE or raises the existing
%      singleton*.
%
%      H = MOUSEHOUSE returns the handle to a new MOUSEHOUSE or the handle to
%      the existing singleton*.
%
%      MOUSEHOUSE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MOUSEHOUSE.M with the given input arguments.
%
%      MOUSEHOUSE('Property','Value',...) creates a new MOUSEHOUSE or
%      raises the
%      existing singleton*.  Starting from the left, property value pairs
%      applied to the GUI before MouseHouse_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MouseHouse_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MouseHouse

% Last Modified by GUIDE v2.5 25-Jul-2013 18:13:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MouseHouse_OpeningFcn, ...
                   'gui_OutputFcn',  @MouseHouse_OutputFcn, ...
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


% --- Executes just before MouseHouse is made visible.
function MouseHouse_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MouseHouse (see VARARGIN)

global g_strctGlobalParam g_bMouseHouse g_bVERBOSE g_iLogLevel;
g_bMouseHouse = true;
g_bVERBOSE = false;
g_iLogLevel = 0;
% SO Feb 08 2012 : Adam, I prefer not to change the current directory during a matlab session. But in any case, please keep the variable convensions. If you use global variables, add a "g_" prefix to them.
% Want to store a global that contains the root directory for
% all the Ohayons code---this allows us to be independent of what
% the current working directory is.
global g_strMouseStuffRootDirName;
mouseHouseFileName=mfilename('fullpath');
mouseHouseDirName=fileparts(mouseHouseFileName);
mouseHouseDirParts=split_on_filesep(mouseHouseDirName);
  % a cell array with each dir an element
mouseStuffRootParts=mouseHouseDirParts(1:end-2);
g_strMouseStuffRootDirName=combine_with_filesep(mouseStuffRootParts);

if g_iLogLevel > 0
   global g_CaptainsLogDir g_logImIndex;
   g_logImIndex = 0;
   ts = num2str(fix(clock)); ts(findstr(ts,' ')) = [];
   g_CaptainsLogDir = ['Logs/Log' ts];
   mkdir(g_CaptainsLogDir);
   sLogFile = fullfile(g_CaptainsLogDir, 'logFile.txt');
   fid = fopen(sLogFile, 'w');
   fclose(fid);
else
   clear global g_CaptainsLogDir g_logImIndex;
end

%dbstop if error;

% Choose default command line output for MouseHouse
handles.output = hObject;

% set handles.expDirName, handles.iExpCurr, handles.expCurr,
% handles.iSingleMouseClipCurr, handles.trainingStatusCodeExpCurr,
% handles.iClipCurr, handles.trackingStatusCodeExpCurr, as
% appropriate
%initGUIExpInfo(hObject,handles);
initUserData(hObject);

%fnUpdateStatus(handles);
%fnUpdateStatusMinimal(handles);
fnUpdateGUIStatus(hObject);
updateLocalClusterRadiobuttons(hObject);
updateEnablementOfLocalClusterRadiobuttons(hObject);

% Load various algorithm parameters from the XML file
g_strctGlobalParam = ...
    fnLoadAlgorithmsConfigXML(fullfile(g_strMouseStuffRootDirName, ...
                                       'Config','Algorithms.xml'));
% g_strctGlobalParam=fnLoadAlgorithmsConfigNative();
%   % eliminate dependence on XML file.  Checked that these assign the same
%   % value to g_strctGlobalParam.  ALT, 2012-01-09

if exist('MouseTrackProj.prj','file')
   rmpath(genpath(fullfile(g_strMouseStuffRootDirName,'Deploy')));
end

cmenu1 = uicontextmenu;
item1 = uimenu(cmenu1, 'Label', 'View Movie', 'Callback', {@fnViewExperiment,handles});
set(handles.hExperimentClipsListbox,'uicontextmenu',cmenu1);

cmenu2 = uicontextmenu;
item2 = uimenu(cmenu2, ...
               'Label', 'View Movie', ...
               'Callback', {@fnViewSingleMouse,handles});
set(handles.hSingleMouseListbox,'uicontextmenu',cmenu2);

% Update handles structure
guidata(hObject, handles);





% --- Outputs from this function are returned to the command line.
function varargout = MouseHouse_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;





% --- Executes on button press in hResults.
function hResults_Callback(hObject, eventdata, handles)
% hObject    handle to hResults (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%[iStatus, sExpName, aiNumJobs, acExperimentClips] = fnGetExpInfo();
u=get(gcbf,'userdata');
expDirName=u.expDirName;
clipFNAbs=u.clipFNAbs;
iClipCurr=u.iClipCurr;
clipFNAbsThis=clipFNAbs{iClipCurr};
%clipInfo = fnReadVideoInfo(clipFNThis);
[dummy, clipBaseName] = fileparts(clipFNAbsThis);  %#ok
tuningDirName = fullfile(expDirName, 'Tuning');
jobsDirName = fullfile(expDirName, 'Jobs');
resultsDirName = fullfile(expDirName, 'Results');
tracksDirName = fullfile(resultsDirName, 'Tracks');
trackFN = fullfile(tracksDirName, [clipBaseName '_tracks.mat']);
if ~exist(trackFN,'file')
  % try the old-school output file name
  trackFN = fullfile(tracksDirName, [clipBaseName '.mat']);
end
classifiersFN = fullfile(tuningDirName, 'Identities.mat');
launchResultsEditor(jobsDirName, ...
                    resultsDirName, ...
                    tuningDirName, ...
                    classifiersFN, ...
                    clipFNAbsThis, ...
                    trackFN);






% % --- Executes during object creation, after setting all properties.
% function hChooseExp_CreateFcn(hObject, eventdata, handles)
% % hObject    handle to hChooseExp (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    empty - handles not created until after all CreateFcns called
% 
% % Hint: popupmenu controls usually have a white background on Windows.
% %       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end
% 
% 
% 
% 
% 
% 
% % --- Executes on selection change in hChooseExp.
% function hChooseExp_Callback(hObject, eventdata, handles)
% % hObject    handle to hChooseExp (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hints: contents = cellstr(get(hObject,'String')) returns hChooseExp contents as cell array
% %        contents{get(hObject,'Value')} returns selected item from hChooseExp
% 
% fnChooseExperiment(gcbf);
% clear global g_a2fDistToWall; % make fnSegmentForeground2 re-compute g_a2fDistToWall








% --- Executes on key press with focus on hChooseExp and none of its controls.
function hChooseExp_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to hChooseExp (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

if strcmp(eventdata.Key, 'delete')
   val = get(hObject, 'Value');
   if val > 1
      %fnUpdateStatus(handles, -val);
      fnDeleteExp(handles,val);
   end
end






% --- Executes on selection change in hSingleMouseListbox.
function hSingleMouseListbox_Callback(hObject, eventdata, handles)
% hObject    handle to hSingleMouseListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns hSingleMouseListbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from hSingleMouseListbox

iVal = get(hObject,'Value');
fnSetCurrentSingleMouseClip(gcbf,iVal);







% --- Executes during object creation, after setting all properties.
function hSingleMouseListbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hSingleMouseListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end







function hSingleMouseListbox_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to hSingleMouseListbox (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

val = get(hObject, 'Value');
if strcmp(eventdata.Key, 'delete')
   %acClipName = cellstr(get(hObject, 'String'));
   %fnUpdateStatus(handles, 'acSingleMouseClips', val);
   fnDeleteSingleMouseClip(gcbf, val)
elseif strcmp(eventdata.Key, 'return')
   fnVerifyTracking(handles, val);
end









% --- Executes on selection change in hExperimentClipsListbox.
function hExperimentClipsListbox_Callback(hObject, eventdata, handles)
% hObject    handle to hExperimentClipsListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns hExperimentClipsListbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from hExperimentClipsListbox
   
iVal = get(hObject,'Value');
fnSetCurrentExpClip(gcbf,iVal);










% --- Executes during object creation, after setting all properties.
function hExperimentClipsListbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hExperimentClipsListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end








% --- Executes on key press with focus on hExperimentClipsListbox and none of its controls.
function hExperimentClipsListbox_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to hExperimentClipsListbox (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

if strcmp(eventdata.Key, 'delete')
   %acClipName = cellstr(get(hObject, 'String'));
   val = get(hObject, 'Value');
   %fnUpdateStatus(handles, 'acExperimentClips', val);
   fnDeleteClip(gcbf,val);
end







% --- Executes on button press in hLocalMode.
function hLocalMode_Callback(hObject, eventdata, handles)
% hObject    handle to hLocalMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hLocalMode







% --- Executes on button press in hClusterMode.
function hClusterMode_Callback(hObject, eventdata, handles)
% hObject    handle to hClusterMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hClusterMode








% --- Executes when selected object is changed in hProcessingModeGroup.
function hProcessingModeGroup_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in hProcessingModeGroup 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

tag=get(eventdata.NewValue,'Tag');
if strcmp(tag,'hLocalMode')
    clusterMode = 0;
else
    clusterMode = 1;
end
u=get(gcbf,'userdata');
u.clusterMode=clusterMode;
set(gcbf,'userdata',u);


% --- Executes on button press in chooseExperimentButton.
function chooseExperimentButton_Callback(hObject, eventdata, handles)
% hObject    handle to chooseExperimentButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fnChooseExperiment(gcbf);
clear global g_a2fDistToWall; % make fnSegmentForeground2 re-compute g_a2fDistToWall

return
