function varargout = ReliableFramesGUI(varargin)
% RELIABLEFRAMESGUI M-file for ReliableFramesGUI.fig
%      RELIABLEFRAMESGUI, by itself, creates a new RELIABLEFRAMESGUI or raises the existing
%      singleton*.
%
%      H = RELIABLEFRAMESGUI returns the handle to a new RELIABLEFRAMESGUI or the handle to
%      the existing singleton*.
%
%      RELIABLEFRAMESGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RELIABLEFRAMESGUI.M with the given input arguments.
%
%      RELIABLEFRAMESGUI('Property','Value',...) creates a new RELIABLEFRAMESGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ReliableFramesGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ReliableFramesGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ReliableFramesGUI

% Last Modified by GUIDE v2.5 26-Nov-2009 12:02:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ReliableFramesGUI_OpeningFcn, ...
    'gui_OutputFcn',  @ReliableFramesGUI_OutputFcn, ...
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


% --- Executes just before ReliableFramesGUI is made visible.
function ReliableFramesGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ReliableFramesGUI (see VARARGIN)

% Choose default command line output for ReliableFramesGUI
handles.output = hObject;
setappdata(handles.figure1,'strctMovieInfo', varargin{1});
setappdata(handles.figure1,'strctAdditionalInfo', varargin{2});
setappdata(handles.figure1,'strResultsFolder', varargin{3});
setappdata(handles.figure1,'iNumMice', varargin{4});
setappdata(handles.figure1,'iStartFrame', varargin{5});
setappdata(handles.figure1,'iEndFrame', varargin{6});
setappdata(handles.figure1,'iMaxJobSize',50000);
setappdata(handles.figure1,'iNumFramesMissing',10);
%setappdata(handles.figure1,'iMinInterval', 5000);
setappdata(handles.figure1,'iMinInterval', 50);
setappdata(handles.figure1,'iSkip',3000);
setappdata(handles.figure1,'iNumReinitalizations',5);
setappdata(handles.figure1,'bIntervalsAvailable', false);
set(handles.figure1,'name',varargin{1}.m_strFileName);
set(handles.figure1,'WindowScrollWheelFcn',{@fnMouseScroll,handles});
set(handles.figure1,'WindowButtonDownFcn',{@fnMouseDown,handles});
set(handles.figure1,'WindowButtonMotionFcn',{@fnMouseMove,handles});
set(handles.figure1,'WindowButtonUpFcn',{@fnMouseUp,handles});

setappdata(handles.figure1,'iCurrReliable',0);

% Update handles structure
guidata(hObject, handles);


hold(handles.axes1,'on');
set(handles.axes1,'visible','off');

% UIWAIT makes ReliableFramesGUI wait for user response (see UIRESUME)
uiwait(handles.figure1);

return;

function fnMouseUp(obj,eventdata,handles)
setappdata(handles.figure1,'bMouseDown',0);
return;

function fnMouseMove(obj,eventdata,handles)
bMouseDown = getappdata(handles.figure1,'bMouseDown');

if bMouseDown > 0 
    fnHandleMouseMoveWhileDown(handles);
end;
return;

function fnHandleMouseMoveWhileDown(handles)
iSelectedMouse = getappdata(handles.figure1,'iSelectedMouse');
iSelectedController = getappdata(handles.figure1,'iSelectedController');
if isempty(iSelectedMouse) && isempty(iSelectedController)
    return;
end;

pt2fDownPoint = getappdata(handles.figure1,'pt2fMouseDown');

astrctReliableFrames = getappdata(handles.figure1,'astrctReliableFrames');
iCurrReliable = getappdata(handles.figure1,'iCurrReliable');
%strctAdditionalInfo = getappdata(handles.figure1,'strctAdditionalInfo');
%strctMovieInfo = getappdata(handles.figure1,'strctMovieInfo');
Tmp=get(handles.axes1,'CurrentPoint');
pt2fCurrPoint = Tmp([1,3]);

if iSelectedController == 1
    % Change center
    astrctReliableFrames(iCurrReliable).m_astrctEllipse(iSelectedMouse).m_fX =  pt2fCurrPoint(1);
    astrctReliableFrames(iCurrReliable).m_astrctEllipse(iSelectedMouse).m_fY =  pt2fCurrPoint(2);
end;
x = astrctReliableFrames(iCurrReliable).m_astrctEllipse(iSelectedMouse).m_fX;
y = astrctReliableFrames(iCurrReliable).m_astrctEllipse(iSelectedMouse).m_fY;
a = astrctReliableFrames(iCurrReliable).m_astrctEllipse(iSelectedMouse).m_fA;
b = astrctReliableFrames(iCurrReliable).m_astrctEllipse(iSelectedMouse).m_fB;
xp = pt2fCurrPoint(1);
yp = pt2fCurrPoint(2);

if iSelectedController == 4 || iSelectedController == 2
    % Major Axis
    newa = sqrt((xp-x).^2 + (yp-y).^2);
    u = [xp-x;yp-y];
    u = u ./ norm(u);
    theta = atan2(-u(2),u(1));
    if newa < b
        setappdata(handles.figure1,'iSelectedController',3);
        astrctReliableFrames(iCurrReliable).m_astrctEllipse(iSelectedMouse).m_fTheta  = ...
            astrctReliableFrames(iCurrReliable).m_astrctEllipse(iSelectedMouse).m_fTheta + pi /2;
    else
        astrctReliableFrames(iCurrReliable).m_astrctEllipse(iSelectedMouse).m_fA = newa;
        astrctReliableFrames(iCurrReliable).m_astrctEllipse(iSelectedMouse).m_fTheta  = theta ;
    end;
end;
    
if iSelectedController ==5 || iSelectedController ==3
    % Minor Axis
    newb = sqrt((xp-x).^2 + (yp-y).^2);
    u = [xp-x;yp-y];
    u = u ./ norm(u);
    theta = atan2(-u(2),u(1))+pi/2;
    if newb > a
        setappdata(handles.figure1,'iSelectedController',2);
        astrctReliableFrames(iCurrReliable).m_astrctEllipse(iSelectedMouse).m_fTheta  = ...
            astrctReliableFrames(iCurrReliable).m_astrctEllipse(iSelectedMouse).m_fTheta + pi /2;
    else
        astrctReliableFrames(iCurrReliable).m_astrctEllipse(iSelectedMouse).m_fB = newb;
        astrctReliableFrames(iCurrReliable).m_astrctEllipse(iSelectedMouse).m_fTheta  = theta ;
    end;
end;

while astrctReliableFrames(iCurrReliable).m_astrctEllipse(iSelectedMouse).m_fTheta > 2*pi
    astrctReliableFrames(iCurrReliable).m_astrctEllipse(iSelectedMouse).m_fTheta  = ...
        astrctReliableFrames(iCurrReliable).m_astrctEllipse(iSelectedMouse).m_fTheta - 2*pi;
end;

while astrctReliableFrames(iCurrReliable).m_astrctEllipse(iSelectedMouse).m_fTheta < 0
    astrctReliableFrames(iCurrReliable).m_astrctEllipse(iSelectedMouse).m_fTheta  = ...
        astrctReliableFrames(iCurrReliable).m_astrctEllipse(iSelectedMouse).m_fTheta  + 2*pi;
end;

setappdata(handles.figure1,'astrctReliableFrames',astrctReliableFrames);

% Update screen...

a2fCol = [1,0,0;
    0,1,0;
    0,0,1;
    0,1,1;
    1,1,0;
    1,0,1];

a2hShapeControls = getappdata(handles.figure1,'a2hShapeControls');
ahHandles = getappdata(handles.figure1,'ahHandles');
delete(a2hShapeControls);
delete(ahHandles);

iNumMice = getappdata(handles.figure1,'iNumMice');
ahHandles = [];
a2hShapeControls= [];
for iMouseIter=1:iNumMice
    [hHandle,ahShapeHandles] = fnDrawTracker(handles.axes1,astrctReliableFrames(iCurrReliable).m_astrctEllipse(iMouseIter),a2fCol(iMouseIter,:), 2,1);
    ahHandles = [ahHandles;hHandle];
    a2hShapeControls(:,iMouseIter) = ahShapeHandles;
end;
setappdata(handles.figure1,'a2hShapeControls',a2hShapeControls);
setappdata(handles.figure1,'ahHandles',ahHandles);

return;


% --- Outputs from this function are returned to the command line.
function varargout = ReliableFramesGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
global TMP
if ~isempty(TMP)
    abValid = zeros(1,length(TMP))>0;
    for k=1:length(TMP)
        abValid(k) = TMP(k).m_bValid && ~isempty(TMP(k).m_astrctEllipse);
    end;
    TMP=TMP(abValid);
end;
varargout{1} = TMP;
TMP = [];
clear global TMP

return;


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
bIntervalsAvailable = getappdata(handles.figure1,'bIntervalsAvailable');
if ~bIntervalsAvailable
    return;
end;
astrctReliableFrames = getappdata(handles.figure1,'astrctReliableFrames');
iCurrReliable = round(get(handles.slider1,'value'));
setappdata(handles.figure1,'iCurrReliable',iCurrReliable);
fnInvalidate(handles);
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
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function hSaveReliable_Callback(hObject, eventdata, handles)
strResultsFolder=getappdata(handles.figure1,'strResultsFolder');
[strFile,strPath] = uiputfile([strResultsFolder,'ReliableKeyFrames.mat']);
if strFile(1) == 0
    return;
end;
astrctReliableFrames = getappdata(handles.figure1,'astrctReliableFrames');

strctMovieInfo = getappdata(handles.figure1,'strctMovieInfo');
strMovieFileName = strctMovieInfo.m_strFileName;

fprintf('Writing to disk...');
save([strPath,strFile],'astrctReliableFrames','strMovieFileName');
fprintf('Done!\n');


% --------------------------------------------------------------------
function hLoadReliable_Callback(hObject, eventdata, handles)
strResultsFolder=getappdata(handles.figure1,'strResultsFolder');
[strFile,strPath] = uigetfile([strResultsFolder,'ReliableKeyFrames.mat']);
if strFile(1) == 0
    return;
end;
fprintf('Reading from disk...');
strctTmp = load([strPath,strFile]);
astrctReliableFrames = strctTmp.astrctReliableFrames;
fprintf('Done!\n');
setappdata(handles.figure1,'bIntervalsAvailable', true);
set(handles.hButton,'String','Submit Jobs');
setappdata(handles.figure1,'astrctReliableFrames',astrctReliableFrames);
setappdata(handles.figure1,'iCurrReliable',1);
set(handles.slider1,'min',1,'max',length(astrctReliableFrames),'value',1);
fnInvalidate(handles);
return;

% --- Executes on button press in hButton.
function hButton_Callback(hObject, eventdata, handles)
global TMP
bIntervalsAvailable = getappdata(handles.figure1,'bIntervalsAvailable');
if bIntervalsAvailable
   astrctReliableFrames = getappdata(handles.figure1,'astrctReliableFrames');
   TMP = astrctReliableFrames;
    delete(handles.figure1);
    return;
else

    strctMovieInfo = getappdata(handles.figure1,'strctMovieInfo');
    strctAdditionalInfo = getappdata(handles.figure1,'strctAdditionalInfo');
    iNumMice = getappdata(handles.figure1,'iNumMice');
    iStartFrame = getappdata(handles.figure1,'iStartFrame');
    iEndFrame = getappdata(handles.figure1,'iEndFrame');
    iMinInterval = getappdata(handles.figure1,'iMinInterval');
    iSkip = getappdata(handles.figure1,'iSkip');
    iMaxJobSize = getappdata(handles.figure1,'iMaxJobSize');
    iNumReinitalizations = getappdata(handles.figure1,'iNumReinitalizations');
    iNumFramesMissing = getappdata(handles.figure1,'iNumFramesMissing');

    astrctReliableFrames = fnFindReliable(strctMovieInfo,strctAdditionalInfo,iNumMice,...
        iStartFrame,iEndFrame,iMinInterval,iSkip,iNumReinitalizations,iMaxJobSize,iNumFramesMissing,handles);
    setappdata(handles.figure1,'astrctReliableFrames',astrctReliableFrames);
    set(handles.slider1,'min',1,'max',length(astrctReliableFrames),'value',1);
    setappdata(handles.figure1,'iCurrReliable',1);
    fnInvalidate(handles);
end
setappdata(handles.figure1,'bIntervalsAvailable',true);
set(handles.hButton,'String','Submit Jobs');

return;


% --------------------------------------------------------------------
function Untitled_3_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --------------------------------------------------------------------
function hChangeSearchParameters_Callback(hObject, eventdata, handles)

prompt={'Min interval length',...
    'Skip', ...
    'Num reinitalizations',...
    'Max Job Size (Force Key Frame)',...
    'Missing Frames Detection'};
name='Parameters';
numlines=1;
defaultanswer={'5000','3000','10','50000','10'};

answer=inputdlg(prompt,name,numlines,defaultanswer);
if isempty(answer)
    return;
end;

iMinInterval = str2num(answer{1});
iSkip = str2num(answer{2});
iNumReinitalizations = str2num(answer{3});
iMaxJobSize = str2num(answer{4});
iNumFramesMissing = str2num(answer{5});
setappdata(handles.figure1,'iMinInterval', iMinInterval);
setappdata(handles.figure1,'iSkip', iSkip);
setappdata(handles.figure1,'iNumReinitalizations',iNumReinitalizations);
setappdata(handles.figure1,'bIntervalsAvailable',false);
setappdata(handles.figure1,'iMaxJobSize',iMaxJobSize);
setappdata(handles.figure1,'iNumFramesMissing',iNumFramesMissing);


set(handles.hButton,'String','Find Reliable Frames');

return;
 


function fnMouseScroll(obj,eventdata,handles)
bIntervalsAvailable = getappdata(handles.figure1,'bIntervalsAvailable');
if ~bIntervalsAvailable
    return;
end;
astrctReliableFrames = getappdata(handles.figure1,'astrctReliableFrames');
iCurrReliable = getappdata(handles.figure1,'iCurrReliable');
iDelta = round(eventdata.VerticalScrollCount);
iCurrReliable  = min(length(astrctReliableFrames)  ,max(1,iCurrReliable +iDelta));
set(handles.slider1,'value',iCurrReliable );
setappdata(handles.figure1,'iCurrReliable',iCurrReliable );
fnInvalidate(handles);
return;

function fnInvalidate(handles)
astrctReliableFrames = getappdata(handles.figure1,'astrctReliableFrames');
iCurrReliable = getappdata(handles.figure1,'iCurrReliable');
strctMovieInfo = getappdata(handles.figure1,'strctMovieInfo');

iCurrFrame = astrctReliableFrames(iCurrReliable).m_iFrame;
a2iFrame = fnReadFrameFromVideo(strctMovieInfo,iCurrFrame);
a2fFrame = double(a2iFrame)/255;

cla;
a3fTmp(:,:,1)=a2fFrame;a3fTmp(:,:,2)=a2fFrame;a3fTmp(:,:,3)=a2fFrame;
image([], [], a3fTmp, 'BusyAction', 'cancel', 'Parent', handles.axes1, 'Interruptible', 'off');
axis ij
a2fCol = [1,0,0;
    0,1,0;
    0,0,1;
    0,1,1;
    1,1,0;
    1,0,1];

if astrctReliableFrames(iCurrReliable).m_bValid
    iNumMice = getappdata(handles.figure1,'iNumMice');
    ahHandles = [];
    a2hShapeControls= [];
    for iMouseIter=1:iNumMice
        [hHandle,ahShapeHandles] = fnDrawTrackerNoTail(handles.axes1,astrctReliableFrames(iCurrReliable).m_astrctEllipse(iMouseIter),a2fCol(iMouseIter,:), 2,1);
        ahHandles = [ahHandles;hHandle];
        a2hShapeControls(:,iMouseIter) = ahShapeHandles;
    end;
  setappdata(handles.figure1,'a2hShapeControls',a2hShapeControls);
  setappdata(handles.figure1,'ahHandles',ahHandles);
%    fnDrawTrackers();
else
    text(200,200,'INVALID','color','r');
  setappdata(handles.figure1,'a2hShapeControls',[]);
  setappdata(handles.figure1,'ahHandles',[]);
    
end;
if astrctReliableFrames(iCurrReliable).m_bBigJump
    set(handles.text1, 'String',sprintf('%d out of %d [Frame %d] - FRAME DROP!',iCurrReliable,...
        length(astrctReliableFrames),iCurrFrame));

else
    set(handles.text1, 'String',sprintf('%d out of %d [Frame %d]',iCurrReliable,...
        length(astrctReliableFrames),iCurrFrame));
end
drawnow

return;

function fnMouseDown(obj,eventdata,handles)
bIntervalsAvailable = getappdata(handles.figure1,'bIntervalsAvailable');
if ~bIntervalsAvailable
    return;
end;
a2hShapeControls = getappdata(handles.figure1,'a2hShapeControls');
iNumMice = getappdata(handles.figure1,'iNumMice');
if ~isempty(a2hShapeControls)
    set(handles.axes1,'units','pixels');
    Tmp=get(handles.axes1,'CurrentPoint');
    pt2fPoint = Tmp([1,3]);
    for k=1:iNumMice
        for j=1:5
            X=get(a2hShapeControls(j,k),'Xdata');
            Y=get(a2hShapeControls(j,k),'Ydata');
            a2fMinDist(j,k) = min(sqrt((X-pt2fPoint(1)).^2+(Y-pt2fPoint(2)).^2));
        end
    end;
    [iSelectedController,iSelectedMouse] = find(a2fMinDist < 7,1,'first');
    setappdata(handles.figure1,'iSelectedMouse',iSelectedMouse);
    setappdata(handles.figure1,'iSelectedController',iSelectedController);
    setappdata(handles.figure1,'pt2fMouseDown',pt2fPoint);

end;
setappdata(handles.figure1,'bMouseDown',1);


astrctReliableFrames = getappdata(handles.figure1,'astrctReliableFrames');
iCurrReliable = getappdata(handles.figure1,'iCurrReliable');
strMouseType = get(handles.figure1,'selectiontype');
if (strcmp( strMouseType,'alt')) && ~astrctReliableFrames(iCurrReliable).m_bBigJump
    astrctReliableFrames(iCurrReliable).m_bValid = ~astrctReliableFrames(iCurrReliable).m_bValid;
end;

setappdata(handles.figure1,'astrctReliableFrames',astrctReliableFrames);
fnInvalidate(handles);

return;


% --------------------------------------------------------------------
function hFrameDrop_Callback(hObject, eventdata, handles)
strctMovieInfo = getappdata(handles.figure1,'strctMovieInfo');
strctAdditionalInfo = getappdata(handles.figure1,'strctAdditionalInfo');
iNumMice = getappdata(handles.figure1,'iNumMice');
iStartFrame = getappdata(handles.figure1,'iStartFrame');
iEndFrame = getappdata(handles.figure1,'iEndFrame');
iNumReinitalizations = getappdata(handles.figure1,'iNumReinitalizations');
astrctReliableFrames = getappdata(handles.figure1,'astrctReliableFrames');
iNumFramesMissing = getappdata(handles.figure1,'iNumFramesMissing');
astrctReliableFrames = fnAddBigJumpsToReliableFrames(handles,strctAdditionalInfo,strctMovieInfo,astrctReliableFrames,iNumMice,iNumReinitalizations,iStartFrame,iEndFrame,iNumFramesMissing);
setappdata(handles.figure1,'astrctReliableFrames',astrctReliableFrames);
fnInvalidate(handles);
return;

