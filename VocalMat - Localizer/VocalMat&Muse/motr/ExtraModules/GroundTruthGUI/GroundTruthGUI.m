function varargout = GroundTruthGUI(varargin)
% GROUNDTRUTHGUI M-file for GroundTruthGUI.fig
%      GROUNDTRUTHGUI, by itself, creates a new GROUNDTRUTHGUI or raises the existing
%      singleton*.
%
%      H = GROUNDTRUTHGUI returns the handle to a new GROUNDTRUTHGUI or the handle to
%      the existing singleton*.
%
%      GROUNDTRUTHGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GROUNDTRUTHGUI.M with the given input arguments.
%
%      GROUNDTRUTHGUI('Property','Value',...) creates a new GROUNDTRUTHGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GroundTruthGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GroundTruthGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GroundTruthGUI

% Last Modified by GUIDE v2.5 26-Dec-2009 12:15:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GroundTruthGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @GroundTruthGUI_OutputFcn, ...
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


% --- Executes just before GroundTruthGUI is made visible.
function GroundTruthGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GroundTruthGUI (see VARARGIN)

% Choose default command line output for GroundTruthGUI
handles.output = hObject;
strctTmp = load(varargin{1});
strctMovInfo = fnReadVideoInfo(varargin{2});
setappdata(handles.figure1,'strctMovInfo',strctMovInfo);

[strTmp, strFile]=fileparts(varargin{2});
setappdata(handles.figure1,'strResultsFolder',[varargin{3},strFile,'\']);

[strFile,strPath]=uigetfile([varargin{3},strFile,'\*.mat']);
if strFile(1) == 0
%    handles.output = 0;
    delete(handles.figure1);
    return;
end;
strctRes = load([strPath,strFile]);
setappdata(handles.figure1,'astrctTrackers',strctRes.astrctTrackers);
ahHandles = [handles.hMouse1True, handles.hMouse2True, handles.hMouse3True, handles.hMouse4True];

ahHandles2 = [handles.hMouse1, handles.hMouse2, handles.hMouse3, handles.hMouse4];
iNumMice = 4;
acColor = 'rgbcym';
ahPatches = zeros(1,iNumMice);
ahRect =  zeros(1,iNumMice);
for iMouseIter=1:iNumMice
    image([], [], fnDup3( strctTmp.strctIdentityClassifier.m_a3fRepImages(:,:,iMouseIter)), 'BusyAction', 'cancel', 'Parent', ...
        ahHandles(iMouseIter), 'Interruptible', 'off');
    set(ahHandles(iMouseIter),'visible','off')
    hold(ahHandles(iMouseIter),'on')
    rectangle('Position',[2 2 110 50],'edgecolor',acColor(iMouseIter),'facecolor','none','parent',ahHandles(iMouseIter),'LineWidth',2)

    ahPatches(iMouseIter) = image([], [], fnDup3( strctTmp.strctIdentityClassifier.m_a3fRepImages(:,:,iMouseIter)), 'BusyAction', 'cancel', 'Parent', ...
        ahHandles2(iMouseIter), 'Interruptible', 'off');
    set(ahHandles2(iMouseIter),'visible','off')
    hold(ahHandles2(iMouseIter),'on')
    ahRect(iMouseIter) = rectangle('Position',[2 2 110 50],'edgecolor',acColor(iMouseIter),'facecolor','none','parent',ahHandles2(iMouseIter),'LineWidth',2);
end
setappdata(handles.figure1,'ahRect',ahRect);
setappdata(handles.figure1,'ahPatches',ahPatches);
setappdata(handles.figure1,'iCurrFrame',1);
setappdata(handles.figure1,'iCurrKeyFrame',1);

a2iFrame = fnReadFrameFromVideo(strctMovInfo,1);
hImage = image([], [], fnDup3( a2iFrame), 'BusyAction', 'cancel', 'Parent', ...
    handles.hImage, 'Interruptible', 'off');
setappdata(handles.figure1,'hImage',hImage);
set(handles.hImage,'visible','off')
hold(handles.hImage,'on')

%set(handles.figure1,'visible','on')
fnSetDefaultGroundTruthInterval(handles);
fnInvalidate(handles);

set(handles.figure1,'KeyPressFcn',{@fnKeyDown,handles});
set(handles.figure1,'KeyReleaseFcn',{@fnKeyUp,handles});
setappdata(handles.figure1,'bMouseDown',0);
set(handles.figure1,'WindowButtonDownFcn',{@fnMouseDown,handles});
set(handles.figure1,'WindowButtonUpFcn',{@fnMouseUp,handles});
set(handles.figure1,'WindowButtonMotionFcn',{@fnMouseMove,handles});
set(handles.figure1,'WindowScrollWheelFcn',{@fnMouseScroll,handles});
set(handles.listbox1,'KeyPressFcn',{@fnKeyDown,handles,false});

% Update handles structure
guidata(hObject, handles);

function fnMouseDown(obj,eventdata,handles)
ahHandles = [handles.hMouse1, handles.hMouse2, handles.hMouse3, handles.hMouse4];
ahHandles2 = [handles.hMouse1True, handles.hMouse2True, handles.hMouse3True, handles.hMouse4True];

iSelectedMouseDown = -1;
for k=1:length(ahHandles)
    if (fnInsideImage(handles,ahHandles(k))) || (fnInsideImage(handles,ahHandles2(k)))
        iSelectedMouseDown = k;
    end
end
setappdata(handles.figure1,'iSelectedMouseDown',iSelectedMouseDown);
return;

function fnMouseUp(obj,eventdata,handles)
iSelectedMouseDown = getappdata(handles.figure1,'iSelectedMouseDown');
ahHandles = [handles.hMouse1, handles.hMouse2, handles.hMouse3, handles.hMouse4];
ahHandles2 = [handles.hMouse1True, handles.hMouse2True, handles.hMouse3True, handles.hMouse4True];

iSelectedMouseUp = -1;
for k=1:length(ahHandles)
    if (fnInsideImage(handles,ahHandles(k))) || (fnInsideImage(handles,ahHandles2(k)))
        iSelectedMouseUp = k;
    end
end
if ~isempty(iSelectedMouseDown) && (iSelectedMouseUp == iSelectedMouseDown || iSelectedMouseDown == -1 || iSelectedMouseUp == -1)
    return;
end;

% Swap
astrctGT = getappdata(handles.figure1,'astrctGT');
iCurrKeyFrame = getappdata(handles.figure1,'iCurrKeyFrame');
iTmp = astrctGT(iCurrKeyFrame).m_aiPerm(iSelectedMouseDown);
astrctGT(iCurrKeyFrame).m_aiPerm(iSelectedMouseDown) = astrctGT(iCurrKeyFrame).m_aiPerm(iSelectedMouseUp);
astrctGT(iCurrKeyFrame).m_aiPerm(iSelectedMouseUp) = iTmp;
astrctGT(iCurrKeyFrame).m_strDescr = 'Incorrect';
setappdata(handles.figure1,'astrctGT',astrctGT);
fnUpdateStatus(handles);
fnInvalidate(handles);
return;

function fnMouseMove(obj,eventdata,handles)
return;

function fnMouseScroll(obj,eventdata,handles)
strctMovInfo = getappdata(handles.figure1,'strctMovInfo');
iCurrFrame = getappdata(handles.figure1,'iCurrFrame');
iCurrFrame = max(1,min(strctMovInfo.m_iNumFrames, iCurrFrame + eventdata.VerticalScrollCount));
iCurrKeyFrame  = getappdata(handles.figure1,'iCurrKeyFrame');
% if iKeyFrame ~= iCurrKeyFrame
%     setappdata(handles.figure1,'iCurrKeyFrame',iKeyFrame);
%     fnUpdateStatus(handles);
%     set(handles.listbox1,'value',iKeyFrame);
% end
setappdata(handles.figure1,'iCurrFrame',iCurrFrame);
fnInvalidate(handles);

return;

function fnSetDefaultGroundTruthInterval(handles)
strctMovInfo = getappdata(handles.figure1,'strctMovInfo');
iTimeSkipSec = 5;
iSkipFrame = ceil(strctMovInfo.m_fFps	 * iTimeSkipSec);
aiInterval = 1:iSkipFrame:strctMovInfo.m_iNumFrames;
for k=1:length(aiInterval)
    astrctGT(k).m_iFrame = aiInterval(k);
    astrctGT(k).m_aiPerm = 1:4; % Tracker to Ground truth
    astrctGT(k).m_strDescr = 'Not Checked';
end
setappdata(handles.figure1,'astrctGT',astrctGT);
fnRefreshList(handles);
return;

function fnRefreshList(handles)
astrctGT = getappdata(handles.figure1,'astrctGT');
iNumIntervals = length(astrctGT);
strOpt = '';
for k=1:iNumIntervals
    strOpt = [strOpt,'|', sprintf('[%10d] %10d',k,astrctGT(k).m_iFrame)];
end
set(handles.listbox1,'string',strOpt(2:end));
return;


function fnKeyUp(a,b,handles)

if isempty(b.Modifier)
    strMod = '';
else
    strMod = b.Modifier{1};
end;
fnInvalidate(handles);
fnUpdateStatus(handles);

return;

function fnKeyDown(a,b,handles, bUpdateList)
if ~exist('bUpdateList','var')
    bUpdateList = true;
end;
strctMovInfo = getappdata(handles.figure1,'strctMovInfo');
iCurrFrame = getappdata(handles.figure1,'iCurrFrame');

if strcmp(b.Key,'rightarrow')
    iCurrFrame = min(strctMovInfo.m_iNumFrames, iCurrFrame + 2);
    iCurrKeyFrame  = getappdata(handles.figure1,'iCurrKeyFrame');
    
    setappdata(handles.figure1,'iCurrFrame',iCurrFrame);
    fnInvalidate(handles);
end

if strcmp(b.Key,'leftarrow')
    iCurrFrame = max(1,iCurrFrame - 2);
    setappdata(handles.figure1,'iCurrFrame',iCurrFrame);
    fnInvalidate(handles);
end
if strcmp(b.Key,'downarrow')
    iCurrKeyFrame = getappdata(handles.figure1,'iCurrKeyFrame');
    fnSetNewKeyFrame(handles,iCurrKeyFrame+1,bUpdateList);
end

if strcmp(b.Key,'uparrow')
    iCurrKeyFrame = getappdata(handles.figure1,'iCurrKeyFrame');
    fnSetNewKeyFrame(handles,iCurrKeyFrame-1,bUpdateList);
end

if strcmpi(b.Key,'c')
    iCurrKeyFrame = getappdata(handles.figure1,'iCurrKeyFrame');
    fnSetStatus(handles,iCurrKeyFrame,'Correct');
    fnSetNewKeyFrame(handles,iCurrKeyFrame+1,true);
end

if strcmpi(b.Key,'i')
    iCurrKeyFrame = getappdata(handles.figure1,'iCurrKeyFrame');
    fnSetStatus(handles,iCurrKeyFrame,'Incorrect (skip)');
    fnSetNewKeyFrame(handles,iCurrKeyFrame+1,true);
end


if strcmpi(b.Key,'s')
    iCurrKeyFrame = getappdata(handles.figure1,'iCurrKeyFrame');
    fnSetStatus(handles,iCurrKeyFrame,'Failed Seg');
    fnSetNewKeyFrame(handles,iCurrKeyFrame+1,true);
end

if strcmpi(b.Key,'n')
    iCurrKeyFrame = getappdata(handles.figure1,'iCurrKeyFrame');
    fnSetStatus(handles,iCurrKeyFrame,'Not Checked');
    fnSetNewKeyFrame(handles,iCurrKeyFrame+1,true);
end


return;

function fnSetStatus(handles,iCurrKeyFrame,strStatus)
astrctGT = getappdata(handles.figure1,'astrctGT');
astrctGT(iCurrKeyFrame).m_strDescr =strStatus;
setappdata(handles.figure1,'astrctGT',astrctGT);
fnUpdateStatus(handles);
return;

function fnUpdateStatus(handles)
astrctGT = getappdata(handles.figure1,'astrctGT');
iCurrKeyFrame =getappdata(handles.figure1,'iCurrKeyFrame');
if all(astrctGT(iCurrKeyFrame).m_aiPerm == [1,2,3,4])
    set(handles.hFrameStatus,'String',[num2str(iCurrKeyFrame),' : Correct!']);
else
    set(handles.hFrameStatus,'String',[num2str(iCurrKeyFrame),' : ',astrctGT(iCurrKeyFrame).m_strDescr ]);
end
return;

function fnSetNewKeyFrame(handles, iNewKeyFrame,bUpdateList)
astrctGT = getappdata(handles.figure1,'astrctGT');
iNewKeyFrame = min(length(astrctGT), max(1, iNewKeyFrame));
setappdata(handles.figure1,'iCurrKeyFrame',iNewKeyFrame);
setappdata(handles.figure1,'iCurrFrame',astrctGT(iNewKeyFrame).m_iFrame);
if bUpdateList
    set(handles.listbox1,'value',iNewKeyFrame);
end
fnUpdateStatus(handles);

return;



function fnInvalidate(handles)
iCurrFrame = getappdata(handles.figure1,'iCurrFrame');
iCurrKeyFrame = getappdata(handles.figure1,'iCurrKeyFrame');
astrctGT = getappdata(handles.figure1,'astrctGT');
strctMovInfo = getappdata(handles.figure1,'strctMovInfo');
astrctTrackers = getappdata(handles.figure1,'astrctTrackers');
ahRect = getappdata(handles.figure1,'ahRect');
ahPatches = getappdata(handles.figure1,'ahPatches');
ahEllipseHandles = getappdata(handles.figure1,'ahEllipseHandles');
delete(ahEllipseHandles);
hImage = getappdata(handles.figure1,'hImage');
a2iFrame = fnReadFrameFromVideo(strctMovInfo, iCurrFrame);
set(hImage,'cdata',fnDup3(a2iFrame));
a3iRectified = fnCollectRectifiedMice2(a2iFrame, astrctTrackers, iCurrFrame);

ahEllipseHandles = fnDrawTrackers4(astrctTrackers, iCurrFrame, handles.hImage);

setappdata(handles.figure1,'ahEllipseHandles',ahEllipseHandles);

for k=1:length(ahPatches)
    set(ahPatches(k),'cdata',fnDup3(a3iRectified(:,:,k)));
end

acColor = 'rgbcym';
for k=1:length(ahRect)
    iTmp = astrctGT(iCurrKeyFrame).m_aiPerm(k);
    if iTmp == 0
        set(ahRect(k),'EdgeColor', 'm');
    else
        set(ahRect(k),'EdgeColor', acColor(iTmp));
    end
end

return;

function B=fnDup3(A)
B(:,:,1) = double(A)/255;
B(:,:,2) = double(A)/255;
B(:,:,3) = double(A)/255;
return;
% UIWAIT makes GroundTruthGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GroundTruthGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
%varargout{1} = handles.output;


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
astrctGT = getappdata(handles.figure1,'astrctGT');
iNewKeyFrame = get(hObject,'value');
setappdata(handles.figure1,'iCurrKeyFrame',iNewKeyFrame);
setappdata(handles.figure1,'iCurrFrame',astrctGT(iNewKeyFrame).m_iFrame);
fnUpdateStatus(handles);
fnInvalidate(handles);
return;


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function hSaveGT_Callback(hObject, eventdata, handles)
strResultsFolder = getappdata(handles.figure1,'strResultsFolder');
astrctTrackers = getappdata(handles.figure1,'astrctTrackers');

if ~exist(strResultsFolder,'dir')
    try
        mkdir(strResultsFolder);
    catch
    end;
end;

[strFile,strPath] = uiputfile([strResultsFolder,'GroundTruth.mat']);
if strFile(1) == 0
    return;
end;
astrctGT = getappdata(handles.figure1,'astrctGT');
save([strPath,strFile],'astrctGT','astrctTrackers');
return;


% --------------------------------------------------------------------
function hLoadGT_Callback(hObject, eventdata, handles)
strResultsFolder = getappdata(handles.figure1,'strResultsFolder');
if ~exist(strResultsFolder,'dir')
    try
        mkdir(strResultsFolder);
    catch
    end;
end;

[strFile,strPath] = uigetfile([strResultsFolder,'GroundTruth.mat']);
if strFile(1) == 0
    return;
end;
load([strPath,strFile]);

setappdata(handles.figure1,'astrctTrackers',astrctTrackers);
setappdata(handles.figure1,'astrctGT',astrctGT);
fnRefreshList(handles);
fnUpdateStatus(handles);
fnInvalidate(handles);
return;


% --------------------------------------------------------------------
function hLoadResults_Callback(hObject, eventdata, handles)
% hObject    handle to hLoadResults (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


