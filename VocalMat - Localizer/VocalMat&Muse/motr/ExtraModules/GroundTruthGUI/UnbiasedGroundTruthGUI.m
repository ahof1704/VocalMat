function varargout = UnbiasedGroundTruthGUI(varargin)
% UNBIASEDGROUNDTRUTHGUI M-file for UnbiasedGroundTruthGUI.fig
%      UNBIASEDGROUNDTRUTHGUI, by itself, creates a new UNBIASEDGROUNDTRUTHGUI or raises the existing
%      singleton*.
%
%      H = UNBIASEDGROUNDTRUTHGUI returns the handle to a new UNBIASEDGROUNDTRUTHGUI or the handle to
%      the existing singleton*.
%
%      UNBIASEDGROUNDTRUTHGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UNBIASEDGROUNDTRUTHGUI.M with the given input arguments.
%
%      UNBIASEDGROUNDTRUTHGUI('Property','Value',...) creates a new UNBIASEDGROUNDTRUTHGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before UnbiasedGroundTruthGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to UnbiasedGroundTruthGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help UnbiasedGroundTruthGUI

% Last Modified by GUIDE v2.5 31-Mar-2011 09:21:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @UnbiasedGroundTruthGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @UnbiasedGroundTruthGUI_OutputFcn, ...
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


% --- Executes just before UnbiasedGroundTruthGUI is made visible.
function UnbiasedGroundTruthGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to UnbiasedGroundTruthGUI (see VARARGIN)

% Choose default command line output for UnbiasedGroundTruthGUI
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
if isfield(strctRes,'a2iRandPerm')
    fprintf('NOTICE! Loading a file that has been randomized!\n');
    a2iRandPerm = strctRes.a2iRandPerm;
else
    a2iRandPerm = [];
end;

setappdata(handles.figure1,'a2iRandPerm',a2iRandPerm);

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
%set(handles.figure1,'WindowButtonDownFcn',{@fnMouseDown,handles});
%set(handles.figure1,'WindowButtonUpFcn',{@fnMouseUp,handles});
%set(handles.figure1,'WindowButtonMotionFcn',{@fnMouseMove,handles});
set(handles.figure1,'WindowScrollWheelFcn',{@fnMouseScroll,handles});
set(handles.listbox1,'KeyPressFcn',{@fnKeyDown,handles,false});
set(handles.figure1,'CloseRequestFcn',{@my_closereq,handles});

% Update handles structure
guidata(hObject, handles);



function my_closereq(a,b,handles)
% User-defined close request function
% to display a question dialog box
selection = questdlg('Save ground truth file and quit?',...
    'Warning',...
    'Yes','No, Just Exit','Cancel','Yes');
switch selection,
    case 'Yes',
        hSaveGT_Callback([], [], handles);
        delete(gcf)
    case 'No, Just Exit'
        delete(gcf)
        return
end
return;


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
if iSelectedMouseUp == iSelectedMouseDown || iSelectedMouseDown == -1 || iSelectedMouseUp == -1
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
astrctGT = getappdata(handles.figure1,'astrctGT');
iCurrKeyFrame  = getappdata(handles.figure1,'iCurrKeyFrame');

aiAllGTFrames = cat(1,astrctGT.m_iFrame);
%[fDummy,iKeyFrame]=min(abs(iCurrFrame-aiAllGTFrames));
[fDummy,iKeyFrame]=min(abs(iCurrFrame+1-aiAllGTFrames));

%
if iKeyFrame ~= iCurrKeyFrame
    setappdata(handles.figure1,'iCurrKeyFrame',iKeyFrame);
    fnUpdateStatus(handles);
    set(handles.listbox1,'value',iKeyFrame);
end

setappdata(handles.figure1,'iCurrFrame',iCurrFrame);
fnInvalidate(handles);

return;

function fnSetDefaultGroundTruthInterval(handles)
strctMovInfo = getappdata(handles.figure1,'strctMovInfo');
iTimeSkipSec = 5;
iSkipFrame = ceil(strctMovInfo.m_fFPS	 * iTimeSkipSec);
aiInterval = 1:iSkipFrame:strctMovInfo.m_iNumFrames;
iNumMice = 4;
for k=1:length(aiInterval)
    astrctGT(k).m_iFrame = aiInterval(k);
    astrctGT(k).m_abHeadTailSwap = false(1,iNumMice);
    astrctGT(k).m_abNeitherHeadTail = false(1,iNumMice);
    astrctGT(k).m_aiPerm = zeros(1,iNumMice); % Tracker to Ground truth
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
    astrctGT = getappdata(handles.figure1,'astrctGT');
    iCurrKeyFrame  = getappdata(handles.figure1,'iCurrKeyFrame');
    aiAllGTFrames = cat(1,astrctGT.m_iFrame);
    %[fDummy,iKeyFrame]=min(abs(iCurrFrame-aiAllGTFrames));
[fDummy,iKeyFrame]=min(abs(iCurrFrame+1-aiAllGTFrames));

%    
    if iKeyFrame ~= iCurrKeyFrame
        setappdata(handles.figure1,'iCurrKeyFrame',iKeyFrame);
        fnUpdateStatus(handles);
        set(handles.listbox1,'value',iKeyFrame);
    end
    
    
    
    setappdata(handles.figure1,'iCurrFrame',iCurrFrame);
    fnInvalidate(handles);
end

if strcmp(b.Key,'leftarrow')
    iCurrFrame = max(1,iCurrFrame - 2);
    
    astrctGT = getappdata(handles.figure1,'astrctGT');
    iCurrKeyFrame  = getappdata(handles.figure1,'iCurrKeyFrame');
    aiAllGTFrames = cat(1,astrctGT.m_iFrame);
    %[fDummy,iKeyFrame]=min(abs(iCurrFrame-aiAllGTFrames));
[fDummy,iKeyFrame]=min(abs(iCurrFrame+1-aiAllGTFrames));

%    
    if iKeyFrame ~= iCurrKeyFrame
        setappdata(handles.figure1,'iCurrKeyFrame',iKeyFrame);
        fnUpdateStatus(handles);
        set(handles.listbox1,'value',iKeyFrame);
    end
    
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

% if strcmpi(b.Key,'c')
%     iCurrKeyFrame = getappdata(handles.figure1,'iCurrKeyFrame');
%     fnSetStatus(handles,iCurrKeyFrame,'Correct');
%     fnSetNewKeyFrame(handles,iCurrKeyFrame+1,true);
% end

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

function strStatus = fnGetStatus(handles,iCurrKeyFrame)
astrctGT = getappdata(handles.figure1,'astrctGT');
strStatus = astrctGT(iCurrKeyFrame).m_strDescr;
return;

function aiPerm = fnGetPerm(handles,iCurrKeyFrame)
astrctGT = getappdata(handles.figure1,'astrctGT');
aiPerm = astrctGT(iCurrKeyFrame).m_aiPerm;
return;

function fnSetStatus(handles,iCurrKeyFrame,strStatus)
astrctGT = getappdata(handles.figure1,'astrctGT');
astrctGT(iCurrKeyFrame).m_strDescr = strStatus;
setappdata(handles.figure1,'astrctGT',astrctGT);
fnUpdateStatus(handles);
return;

function fnUpdateStatus(handles)
astrctGT = getappdata(handles.figure1,'astrctGT');
iCurrKeyFrame =getappdata(handles.figure1,'iCurrKeyFrame');
strHuddle = [];
if isfield(astrctGT(iCurrKeyFrame), 'm_bHuddling') && ~isempty(astrctGT(iCurrKeyFrame).m_bHuddling) && astrctGT(iCurrKeyFrame).m_bHuddling
   strHuddle = ' ; Huddling ';
end
if strcmp(astrctGT(iCurrKeyFrame).m_strDescr, 'Failed Seg')
   strIdConfLevel = [];
else
   strIdConfLevel = ' ; ID Conf Level UNSPECIFIED';
   if isfield(astrctGT(iCurrKeyFrame), 'm_iIdConfLevel') && ~isempty(astrctGT(iCurrKeyFrame).m_iIdConfLevel) && astrctGT(iCurrKeyFrame).m_iIdConfLevel>0
      switch astrctGT(iCurrKeyFrame).m_iIdConfLevel
         case 1
            strIdConfLevel = ' ; Low ID Conf Level ';
         case 2
            strIdConfLevel = ' ; Medium ID Conf Level ';
         case 3
            strIdConfLevel = ' ; High ID Conf Level ';
      end
   end
end
set(handles.hFrameStatus,'String',[num2str(iCurrKeyFrame),' : ',astrctGT(iCurrKeyFrame).m_strDescr, strHuddle, strIdConfLevel]);
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
delete(ahEllipseHandles(ishandle(ahEllipseHandles)));
hImage = getappdata(handles.figure1,'hImage');
a2iFrame = fnReadFrameFromVideo(strctMovInfo, iCurrFrame);
set(hImage,'cdata',fnDup3(a2iFrame));
a3iRectified = fnCollectRectifiedMice2(a2iFrame, astrctTrackers, iCurrFrame);
iNumMice = 4;

aiAllGTFrames = cat(1,astrctGT.m_iFrame);
[fDummy,iKeyFrame]=min(abs(iCurrFrame+1-aiAllGTFrames));

%if iCurrFrame == astrctGT(iCurrKeyFrame).m_iFrame
ahEllipseHandles = fnDrawTrackers5(astrctTrackers, iCurrFrame, handles.hImage,astrctGT(iKeyFrame).m_aiPerm);
%else
%    ahEllipseHandles = fnDrawTrackers5(astrctTrackers, iCurrFrame, handles.hImage,zeros(1,iNumMice));
%end
set(handles.hCurrFrameText,'String',sprintf('Current Frame : %d, Current Key Frame : %d',iCurrFrame,iKeyFrame));
setappdata(handles.figure1,'ahEllipseHandles',ahEllipseHandles);

for k=1:length(ahPatches)
    if astrctGT(iCurrKeyFrame).m_abHeadTailSwap(k) 
         set(ahPatches(k),'cdata',fnDup3(a3iRectified(:,end:-1:1,k)));
    else
        set(ahPatches(k),'cdata',fnDup3(a3iRectified(:,:,k)));
    end
end

if ~isfield(astrctGT(iCurrKeyFrame), 'm_abNeitherHeadTail')
    astrctGT(iCurrKeyFrame).m_abNeitherHeadTail = [0 0 0 0];
end
set(handles.hTracker1neither,'Value',astrctGT(iCurrKeyFrame).m_abNeitherHeadTail(1));
set(handles.hTracker2neither,'Value',astrctGT(iCurrKeyFrame).m_abNeitherHeadTail(2));
set(handles.hTracker3neither,'Value',astrctGT(iCurrKeyFrame).m_abNeitherHeadTail(3));
set(handles.hTracker4neither,'Value',astrctGT(iCurrKeyFrame).m_abNeitherHeadTail(4));

acColor = 'rgbcym';
for k=1:length(ahRect)
    iTmp = astrctGT(iKeyFrame).m_aiPerm(k);
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
% UIWAIT makes UnbiasedGroundTruthGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = UnbiasedGroundTruthGUI_OutputFcn(hObject, eventdata, handles) 
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



a2iRandPerm = getappdata(handles.figure1,'a2iRandPerm');
fprintf('Saving ground truth to %s\n',[strPath,strFile]);
save([strPath,strFile],'astrctGT','astrctTrackers','a2iRandPerm');
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


function hTracker1Red_Callback(hObject, eventdata, handles)
fnChangeIdentity(handles, 1, 1);
function hTracker1Green_Callback(hObject, eventdata, handles)
fnChangeIdentity(handles, 1, 2);
function hTracker1Blue_Callback(hObject, eventdata, handles)
fnChangeIdentity(handles, 1, 3);
function hTracker1Cyan_Callback(hObject, eventdata, handles)
fnChangeIdentity(handles, 1, 4);
function hTracker1HeadTail_Callback(hObject, eventdata, handles)
fnChangeHeadTail(handles, 1);
function hTracker1neither_Callback(hObject, eventdata, handles)
fnToggleNeitherHeadTail(handles, 1);

function hTracker2Red_Callback(hObject, eventdata, handles)
fnChangeIdentity(handles, 2, 1);
function hTracker2Green_Callback(hObject, eventdata, handles)
fnChangeIdentity(handles, 2, 2);
function hTracker2Blue_Callback(hObject, eventdata, handles)
fnChangeIdentity(handles, 2, 3);
function hTracker2Cyan_Callback(hObject, eventdata, handles)
fnChangeIdentity(handles, 2, 4);
function hTracker2HeadTail_Callback(hObject, eventdata, handles)
fnChangeHeadTail(handles, 2);
function hTracker2neither_Callback(hObject, eventdata, handles)
fnToggleNeitherHeadTail(handles, 2);

function hTracker3Red_Callback(hObject, eventdata, handles)
fnChangeIdentity(handles, 3, 1);
function hTracker3Green_Callback(hObject, eventdata, handles)
fnChangeIdentity(handles, 3, 2);
function hTracker3Blue_Callback(hObject, eventdata, handles)
fnChangeIdentity(handles, 3, 3);
function hTracker3Cyan_Callback(hObject, eventdata, handles)
fnChangeIdentity(handles, 3, 4);
function hTracker3HeadTail_Callback(hObject, eventdata, handles)
fnChangeHeadTail(handles, 3);
function hTracker3neither_Callback(hObject, eventdata, handles)
fnToggleNeitherHeadTail(handles, 3);

function hTracker4Red_Callback(hObject, eventdata, handles)
fnChangeIdentity(handles, 4, 1);
function hTracker4Green_Callback(hObject, eventdata, handles)
fnChangeIdentity(handles, 4, 2);
function hTracker4Blue_Callback(hObject, eventdata, handles)
fnChangeIdentity(handles, 4, 3);
function hTracker4Cyan_Callback(hObject, eventdata, handles)
fnChangeIdentity(handles, 4, 4);
function hTracker4HeadTail_Callback(hObject, eventdata, handles)
fnChangeHeadTail(handles, 4);
function hTracker4neither_Callback(hObject, eventdata, handles)
fnToggleNeitherHeadTail(handles, 4);

function fnChangeIdentity(handles, iTracker, iIdentity)
astrctGT = getappdata(handles.figure1,'astrctGT');
iCurrKeyFrame = getappdata(handles.figure1,'iCurrKeyFrame');
aiPrevPerm = astrctGT(iCurrKeyFrame).m_aiPerm;
if aiPrevPerm(iTracker) == iIdentity
    % No change.
    return;
end;

if aiPrevPerm(iTracker) > 0
    astrctGT(iCurrKeyFrame).m_aiPerm(iTracker) = iIdentity;
    if iIdentity > 0
        astrctGT(iCurrKeyFrame).m_aiPerm(aiPrevPerm == iIdentity) = aiPrevPerm(iTracker);
    end
else
    astrctGT(iCurrKeyFrame).m_aiPerm(iTracker) = iIdentity;
end

% Fill in the last mouse
if iIdentity > 0
    X = astrctGT(iCurrKeyFrame).m_aiPerm;
    I=unique(X(X>0));
    if length(I) == 3
        iLastMouse = setdiff(1:4,X);
        astrctGT(iCurrKeyFrame).m_aiPerm(astrctGT(iCurrKeyFrame).m_aiPerm == 0) = iLastMouse;
    end
end

astrctGT(iCurrKeyFrame).m_strDescr = fnGetDescription(astrctGT(iCurrKeyFrame).m_aiPerm);
    
setappdata(handles.figure1,'astrctGT',astrctGT);
fnUpdateStatus(handles);
fnInvalidate(handles);
return;

function strDescr = fnGetDescription(aiPerm)
%
strDescr = 'Semi-Checked';
if all(aiPerm > 0) 
    if all(sort(aiPerm) == [1 2 3 4])
        strDescr = 'Checked';
    else
        strDescr = 'ERROR. Same identity assignment';
    end
else
    X = aiPerm;
    X = X(X>0);
    if length(X) ~= length(unique(X))
        strDescr = 'ERROR. Same identity assignment';
    end    
end


function fnChangeHeadTail(handles, iTracker)
astrctGT = getappdata(handles.figure1,'astrctGT');
iCurrKeyFrame = getappdata(handles.figure1,'iCurrKeyFrame');
astrctGT(iCurrKeyFrame).m_abHeadTailSwap(iTracker) = ~astrctGT(iCurrKeyFrame).m_abHeadTailSwap(iTracker);
%astrctGT(iCurrKeyFrame).m_strDescr = 'Incorrect';
setappdata(handles.figure1,'astrctGT',astrctGT);
fnUpdateStatus(handles);
fnInvalidate(handles);
return;


function fnToggleNeitherHeadTail(handles, iTracker)
astrctGT = getappdata(handles.figure1,'astrctGT');
iCurrKeyFrame = getappdata(handles.figure1,'iCurrKeyFrame');
astrctGT(iCurrKeyFrame).m_abNeitherHeadTail(iTracker) = ~astrctGT(iCurrKeyFrame).m_abNeitherHeadTail(iTracker);
setappdata(handles.figure1,'astrctGT',astrctGT);
fnUpdateStatus(handles);
fnInvalidate(handles);
return;

function hTracker1Magenta_Callback(hObject, eventdata, handles)
fnChangeIdentity(handles, 1, 0);

function hTracker2Magenta_Callback(hObject, eventdata, handles)
fnChangeIdentity(handles, 2, 0);

function hTracker3Magenta_Callback(hObject, eventdata, handles)
fnChangeIdentity(handles, 3, 0);

function hTracker4Magenta_Callback(hObject, eventdata, handles)
fnChangeIdentity(handles, 4, 0);


% --- Executes on button press in hNextIncorrect.
function hNextIncorrect_Callback(hObject, eventdata, handles)
astrctGT = getappdata(handles.figure1,'astrctGT');
iCurrKeyFrame = getappdata(handles.figure1,'iCurrKeyFrame');

iNumMice = 4;
a2iPerms = cat(1,astrctGT.m_aiPerm);
aiKeyframesWithCorrectSegmentation = find(sum(a2iPerms >0,2) == iNumMice);

aiNot1234 = aiKeyframesWithCorrectSegmentation(find(sum(a2iPerms(aiKeyframesWithCorrectSegmentation,:) == repmat(1:iNumMice,size(aiKeyframesWithCorrectSegmentation,1),1),2) ~= iNumMice));
if isempty(aiNot1234)
    return
end

iFirstNext = find(aiNot1234 > iCurrKeyFrame,1,'first');
if isempty(iFirstNext)
    iFirstNext = 1;
end
iCurrKeyFrame = aiNot1234(iFirstNext);
fnSetNewKeyFrame(handles,iCurrKeyFrame,true);
fnInvalidate(handles);
return;


% --- Executes on button press in hTrackingIdentities.
function hTrackingIdentities_Callback(hObject, eventdata, handles)


% --- Executes on button press in hHuddling.
function hHuddling_Callback(hObject, eventdata, handles)
% hObject    handle to hHuddling (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

astrctGT = getappdata(handles.figure1,'astrctGT');
iCurrKeyFrame = getappdata(handles.figure1,'iCurrKeyFrame');
if isfield(astrctGT(iCurrKeyFrame), 'm_bHuddling') && ~isempty(astrctGT(iCurrKeyFrame).m_bHuddling)
   astrctGT(iCurrKeyFrame).m_bHuddling = ~astrctGT(iCurrKeyFrame).m_bHuddling;
else
   astrctGT(iCurrKeyFrame).m_bHuddling = true;
end
setappdata(handles.figure1,'astrctGT',astrctGT);
fnUpdateStatus(handles);

% --- Executes on button press in hHighConf.
function hHighConf_Callback(hObject, eventdata, handles)
% hObject    handle to hHighConf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

astrctGT = getappdata(handles.figure1,'astrctGT');
iCurrKeyFrame = getappdata(handles.figure1,'iCurrKeyFrame');
astrctGT(iCurrKeyFrame).m_iIdConfLevel = 3;
setappdata(handles.figure1,'astrctGT',astrctGT);
fnUpdateStatus(handles);

% --- Executes on button press in hMedConf.
function hMedConf_Callback(hObject, eventdata, handles)
% hObject    handle to hMedConf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

astrctGT = getappdata(handles.figure1,'astrctGT');
iCurrKeyFrame = getappdata(handles.figure1,'iCurrKeyFrame');
astrctGT(iCurrKeyFrame).m_iIdConfLevel = 2;
setappdata(handles.figure1,'astrctGT',astrctGT);
fnUpdateStatus(handles);

% --- Executes on button press in hLowConf.
function hLowConf_Callback(hObject, eventdata, handles)
% hObject    handle to hLowConf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

astrctGT = getappdata(handles.figure1,'astrctGT');
iCurrKeyFrame = getappdata(handles.figure1,'iCurrKeyFrame');
astrctGT(iCurrKeyFrame).m_iIdConfLevel = 1;
setappdata(handles.figure1,'astrctGT',astrctGT);
fnUpdateStatus(handles);


% --- Executes on button press in hFailedSegmentation.
function hFailedSegmentation_Callback(hObject, eventdata, handles)
% hObject    handle to hFailedSegmentation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

iCurrKeyFrame = getappdata(handles.figure1,'iCurrKeyFrame');
if strcmp(fnGetStatus(handles,iCurrKeyFrame), 'Failed Seg')
   fnSetStatus(handles,iCurrKeyFrame,fnGetDescription(fnGetPerm(handles,iCurrKeyFrame)));
else
   fnSetStatus(handles,iCurrKeyFrame,'Failed Seg');
end


% --- Executes during object creation, after setting all properties.
function hFailedSegmentation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hFailedSegmentation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
