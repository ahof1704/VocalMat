function varargout = EllipseMarkingGUI(varargin)
% EllipseMarkingGUI M-file for EllipseMarkingGUI.fig
%      EllipseMarkingGUI, by itself, creates a new EllipseMarkingGUI or raises the existing
%      singleton*.
%
%      H = EllipseMarkingGUI returns the handle to a new EllipseMarkingGUI or the handle to
%      the existing singleton*.
%
%      EllipseMarkingGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EllipseMarkingGUI.M with the given input arguments.
%
%      EllipseMarkingGUI('Property','Value',...) creates a new EllipseMarkingGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before EllipseMarkingGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to EllipseMarkingGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help EllipseMarkingGUI

% Last Modified by GUIDE v2.5 20-May-2011 17:29:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @EllipseMarkingGUI_OpeningFcn, ...
    'gui_OutputFcn',  @EllipseMarkingGUI_OutputFcn, ...
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


% --- Executes just before EllipseMarkingGUI is made visible.
function EllipseMarkingGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to EllipseMarkingGUI (see VARARGIN)

% Choose default command line output for EllipseMarkingGUI

clear global;

handles.output = hObject;

set(handles.figure1,'WindowScrollWheelFcn',{@fnMouseScroll,handles});
set(handles.figure1,'WindowButtonDownFcn',{@fnMouseDown,handles});
set(handles.figure1,'WindowButtonMotionFcn',{@fnMouseMove,handles});
set(handles.figure1,'WindowButtonUpFcn',{@fnMouseUp,handles});
% sClipName = 'C:\MouseTrack\Data\Mice_G\Movies\b6_pop_cage_14_12.04.10_09.55.49.730_40001.seq';
% sClipName = 'C:\data\pilot\b6_popcage_16_110405_21.58.31.238.seq';
sClipName = 'C:\data\pilot\b6_popcage_16_110405_09.58.30.268.seq';
% sClipName = '/groups/egnor/mousetrack/mousetrack_16/b6_popcage_16_110405_09.58.30.268.seq';
strOutputFile = 'HandMadeEllipses30268.mat';
iNumMice = 4;
setappdata(handles.figure1,'strOutputFile', strOutputFile);
setappdata(handles.figure1,'iNumMice', iNumMice);

strctAdditionalInfo.strctMovieInfo = fnReadVideoInfo(sClipName);
astrctDefaultEllipses = fnSetDefaultEllipses(iNumMice);
setappdata(handles.figure1,'astrctDefaultEllipses', astrctDefaultEllipses);

if exist(strOutputFile)
   fprintf('Loading existing file %s for editing. To start a new session with the same frames, please rename this file and use the new name as an argument for EllipeMarkingGUI. \n', strOutputFile);
   load(strOutputFile);
   astrctEllipses = strctBackground.m_astrctTuningEllipses;
   aiSampleFrames = [astrctEllipses.m_iFrame];
else
   if isempty(varargin) || isempty(varargin{1})
      aiSampleFrames = randperm(strctAdditionalInfo.strctMovieInfo.m_iNumFrames);
      aiSampleFrames = aiSampleFrames(1:min(1000,length(aiSampleFrames)));
      astrctEllipses = fnInitEllipses(astrctDefaultEllipses, aiSampleFrames);
   else
      fprintf('Starting a new session for marking the same frames of %s . \n', varargin{1});
      load(varargin{1});
      aiSampleFrames = [strctBackground.m_astrctTuningEllipses.m_iFrame];
      strctBackground.m_astrctTuningEllipses = [];
      astrctEllipses = fnInitEllipses(astrctDefaultEllipses, aiSampleFrames);
   end
end
setappdata(handles.figure1,'aiSampleFrames',aiSampleFrames);
set(handles.slider1,'min',1,'max',length(aiSampleFrames),'value',1,'SliderStep',[1 10]/length(aiSampleFrames));
setappdata(handles.figure1,'astrctEllipses', astrctEllipses);
setappdata(handles.figure1,'strctAdditionalInfo', strctAdditionalInfo);
fnTune(handles);

% Update handles structure
guidata(hObject, handles);

% uiwait(handles.figure1);
return;


function fnTune(handles)
%
set(handles.text1, 'string', 'Mark mice with ellipses. Double click when you''re done.');
setappdata(handles.figure1,'iCurrSample',1);
iNumMice = getappdata(handles.figure1,'iNumMice');
% astrctEllipses = strctAdditionalInfo.strctBackground.m_astrctTuningEllipses;
% aiSampleFrames = [astrctEllipses.m_iFrame];
% setappdata(handles.figure1,'astrctEllipses',astrctEllipses);

% setappdata(handles.figure1,'strctAdditionalInfo', strctAdditionalInfo);
% setappdata(handles.figure1,'aiSampleFrame', aiSampleFrames);

fnInvalidate(handles);

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
%
bEnableEllipseEditing = getappdata(handles.figure1,'bEnableEllipseEditing');
if ~bEnableEllipseEditing
   return;
end;
iSelectedMouse = getappdata(handles.figure1,'iSelectedMouse');
iSelectedController = getappdata(handles.figure1,'iSelectedController');
if isempty(iSelectedMouse) && isempty(iSelectedController)
    return;
end;

pt2fDownPoint = getappdata(handles.figure1,'pt2fMouseDown');

astrctEllipses = getappdata(handles.figure1,'astrctEllipses');
iCurrSample = getappdata(handles.figure1,'iCurrSample');
Tmp=get(handles.axes1,'CurrentPoint');
pt2fCurrPoint = Tmp([1,3]);

if iSelectedController == 1
    % Change center
    astrctEllipses(iCurrSample).m_astrctEllipse(iSelectedMouse).m_fX =  pt2fCurrPoint(1);
    astrctEllipses(iCurrSample).m_astrctEllipse(iSelectedMouse).m_fY =  pt2fCurrPoint(2);
else
   x = astrctEllipses(iCurrSample).m_astrctEllipse(iSelectedMouse).m_fX;
   y = astrctEllipses(iCurrSample).m_astrctEllipse(iSelectedMouse).m_fY;
   a = astrctEllipses(iCurrSample).m_astrctEllipse(iSelectedMouse).m_fA;
   b = astrctEllipses(iCurrSample).m_astrctEllipse(iSelectedMouse).m_fB;
   t = astrctEllipses(iCurrSample).m_astrctEllipse(iSelectedMouse).m_fTheta;
   xp = pt2fCurrPoint(1);
   yp = pt2fCurrPoint(2);
   
   bMajor = iSelectedController == 4 || iSelectedController == 2;
   iSign = 1;
   if iSelectedController == 4 || iSelectedController == 3
      iSign = -1;
   end;
   if bMajor
      X = x + iSign*a*cos(t);
      Y = y - iSign*a*sin(t);
   else
      X = x - iSign*b*cos(t-pi/2);
      Y = y + iSign*b*sin(t-pi/2);
   end;
   x = x + (xp-X)/2;
   y = y + (yp-Y)/2;
   u = [xp-x; yp-y];
   d = norm(u);
   if d < 1
      u = [1 0];
      d = 1;
   end;
   u = u ./ d;
   if bMajor
      t = atan2(-u(2),u(1)) + (1-iSign)*pi/2;
      a = max(b, d);
   else
      t = -atan2(-u(1),u(2)) + (1+iSign)*pi/2;
      b = min(a, d);
   end;
   t = mod(t, 2*pi);
   astrctEllipses(iCurrSample).m_astrctEllipse(iSelectedMouse).m_fX = x;
   astrctEllipses(iCurrSample).m_astrctEllipse(iSelectedMouse).m_fY = y;
   astrctEllipses(iCurrSample).m_astrctEllipse(iSelectedMouse).m_fA = a;
   astrctEllipses(iCurrSample).m_astrctEllipse(iSelectedMouse).m_fB = b;
   astrctEllipses(iCurrSample).m_astrctEllipse(iSelectedMouse).m_fTheta = t;
end;

setappdata(handles.figure1,'astrctEllipses',astrctEllipses);

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
    [hHandle,ahShapeHandles] = fnDrawTracker(handles.axes1,astrctEllipses(iCurrSample).m_astrctEllipse(iMouseIter),a2fCol(iMouseIter,:), 2,1);
    ahHandles = [ahHandles;hHandle];
    a2hShapeControls(:,iMouseIter) = ahShapeHandles;
end;
setappdata(handles.figure1,'a2hShapeControls',a2hShapeControls);
setappdata(handles.figure1,'ahHandles',ahHandles);

return;


% --- Outputs from this function are returned to the command line.
function varargout = EllipseMarkingGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% 
astrctEllipses = getappdata(handles.figure1,'astrctEllipses');
iCurrSample = round(get(handles.slider1,'value'));
setappdata(handles.figure1,'iCurrSample',iCurrSample);
fnInvalidate(handles);
guidata(hObject, handles);
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

function fnSaveBackground(handles)
%
strOutputFile = getappdata(handles.figure1,'strOutputFile');
astrctEllipses = getappdata(handles.figure1,'astrctEllipses');
strctAdditionalInfo = getappdata(handles.figure1,'strctAdditionalInfo');
strctMovieInfo = strctAdditionalInfo.strctMovieInfo;
strctBackground.m_astrctTuningEllipses = astrctEllipses;
fprintf('Writing %s to disk...',strOutputFile);
save(strOutputFile,'strctMovieInfo','strctBackground');
fprintf('Done!\n');



% --- Executes on button press in hButton.
function hButton_Callback(hObject, eventdata, handles)
%
astrctEllipses = getappdata(handles.figure1,'astrctEllipses');
fnSaveBackground(handles);
delete(handles.figure1);

return;


% --------------------------------------------------------------------
function Untitled_3_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function fnMouseScroll(obj,eventdata,handles)
% 
bEnableEllipseEditing = getappdata(handles.figure1,'bEnableEllipseEditing');
if ~bEnableEllipseEditing
   return;
end;
astrctEllipses = getappdata(handles.figure1,'astrctEllipses');
iCurrSample = getappdata(handles.figure1,'iCurrSample');
iDelta = round(eventdata.VerticalScrollCount);
iCurrSample  = min(length(astrctEllipses)  ,max(1,iCurrSample +iDelta));
set(handles.slider1,'value',iCurrSample);
setappdata(handles.figure1,'iCurrSample',iCurrSample );
fnInvalidate(handles);

return;

function fnInvalidate(handles)
%
astrctEllipses = getappdata(handles.figure1,'astrctEllipses');
iCurrSample = getappdata(handles.figure1,'iCurrSample');
strctAdditionalInfo = getappdata(handles.figure1,'strctAdditionalInfo');
strctMovieInfo = strctAdditionalInfo.strctMovieInfo;

iCurrFrame = astrctEllipses(iCurrSample).m_iFrame;
a2iFrame = fnReadFrameFromVideo(strctMovieInfo,iCurrFrame);
a2fFrame = double(a2iFrame)/255;

axes(handles.axes1);
cla;
hold(handles.axes1,'on');
a3fTmp(:,:,1)=a2fFrame;a3fTmp(:,:,2)=a2fFrame;a3fTmp(:,:,3)=a2fFrame;
image([], [], a3fTmp, 'BusyAction', 'cancel', 'Parent', handles.axes1, 'Interruptible', 'off');
axis ij
axis off;
set(handles.axes1, 'DataAspectRatioMode', 'auto');
set(handles.axes1, 'PlotBoxAspectRatioMode', 'auto');

a2fCol = [1,0,0;
   0,1,0;
   0,0,1;
   0,1,1;
   1,1,0;
   1,0,1];

iNumMice = getappdata(handles.figure1,'iNumMice');
ahHandles = [];
a2hShapeControls= [];
for iMouseIter=1:iNumMice
   [hHandle,ahShapeHandles] = fnDrawTracker(handles.axes1,astrctEllipses(iCurrSample).m_astrctEllipse(iMouseIter),a2fCol(iMouseIter,:), 2,1);
   ahHandles = [ahHandles;hHandle];
   a2hShapeControls(:,iMouseIter) = ahShapeHandles;
end;
setappdata(handles.figure1,'a2hShapeControls',a2hShapeControls);
setappdata(handles.figure1,'ahHandles',ahHandles);
set(handles.text1, 'String',sprintf('%d out of %d   [Frame %d]',iCurrSample,length(astrctEllipses),iCurrFrame));

% drawnow

return;

function fnMouseDown(obj,eventdata,handles)
% 
bEnableEllipseEditing = getappdata(handles.figure1,'bEnableEllipseEditing');
if ~bEnableEllipseEditing
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


astrctEllipses = getappdata(handles.figure1,'astrctEllipses');
iCurrSample = getappdata(handles.figure1,'iCurrSample');
astrctEllipses(iCurrSample).m_bValid = true;
strMouseType = get(handles.figure1,'selectiontype');
if (strcmp( strMouseType,'alt'))
    astrctEllipses(iCurrSample).m_bValid = false;
end;

setappdata(handles.figure1,'astrctEllipses',astrctEllipses);
fnInvalidate(handles);

return;


% --- Executes on key press with focus on hButton and none of its controls.
function hButton_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to hButton (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

function astrctEllipses = fnSetDefaultEllipses(iNumMice)
%
astrctEllipses(1) = struct('m_fX',50, 'm_fY',100, 'm_fA',35, 'm_fB',15, 'm_fTheta',pi/2);
for j=2:iNumMice
   astrctEllipses(j) = astrctEllipses(j-1);
   astrctEllipses(j).m_fY = astrctEllipses(j).m_fY + 120;
end

function astrctEllipses = fnInitEllipses(astrctDefaultEllipses, aiSampleFrames)
%
for i=1:length(aiSampleFrames)
   astrctEllipses(i).m_iFrame = aiSampleFrames(i);
   astrctEllipses(i).m_bValid = false;
   astrctEllipses(i).m_astrctEllipse = astrctDefaultEllipses;
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over slider1.
function slider1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
