function varargout = TuneSegmentationGUI(varargin)
% TuneSegmentationGUI M-file for TuneSegmentationGUI.fig
%      TuneSegmentationGUI, by itself, creates a new TuneSegmentationGUI or raises the existing
%      singleton*.
%
%      H = TuneSegmentationGUI returns the handle to a new TuneSegmentationGUI or the handle to
%      the existing singleton*.
%
%      TuneSegmentationGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TuneSegmentationGUI.M with the given input arguments.
%
%      TuneSegmentationGUI('Property','Value',...) creates a new TuneSegmentationGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TuneSegmentationGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TuneSegmentationGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TuneSegmentationGUI

% Last Modified by GUIDE v2.5 19-May-2011 14:35:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @TuneSegmentationGUI_OpeningFcn, ...
    'gui_OutputFcn',  @TuneSegmentationGUI_OutputFcn, ...
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


% --- Executes just before TuneSegmentationGUI is made visible.
function TuneSegmentationGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TuneSegmentationGUI (see VARARGIN)

% Choose default command line output for TuneSegmentationGUI
handles.output = hObject;

set(handles.figure1,'WindowScrollWheelFcn',{@fnMouseScroll,handles});
set(handles.figure1,'WindowButtonDownFcn',{@fnMouseDown,handles});
set(handles.figure1,'WindowButtonMotionFcn',{@fnMouseMove,handles});
set(handles.figure1,'WindowButtonUpFcn',{@fnMouseUp,handles});

strResultsFolder = varargin{2};
iNumMice = varargin{1};
setappdata(handles.figure1,'strResultsFolder', strResultsFolder);
setappdata(handles.figure1,'iNumMice', iNumMice);

if length(varargin)>2
   fnLog('TuneSegmentationGUI called from fnTuneBackgroundFromScratch, therefor strctAdditionalInfo and aiSampleFrames are passed as varargins 3 and 4');
   strctAdditionalInfo = varargin{3};
   setappdata(handles.figure1,'aiSampleFrames',varargin{4});
   set(handles.slider1,'min',1,'max',length(varargin{4}),'value',1,'SliderStep',[1 10]/length(varargin{4}));
else
   fnLog('TuneSegmentationGUI called directly from MouseHouseGUI, therefor an earlier tunning will be loaded');
   strctAdditionalInfo = fnLoadBackground(handles);
end
setappdata(handles.figure1,'strctAdditionalInfo', strctAdditionalInfo);
fnTune(handles);

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

% Update handles structure
guidata(hObject, handles);

uiwait(handles.figure1);
return;


function fnTune(handles)
%
axes(handles.axes1);
cla;
hold(handles.axes1,'on');
strctAdditionalInfo = getappdata(handles.figure1,'strctAdditionalInfo');
a3fTmp(:,:,1)=strctAdditionalInfo.strctBackground.m_a2fMedian; a3fTmp(:,:,2)=a3fTmp(:,:,1); a3fTmp(:,:,3)=a3fTmp(:,:,1);
image([], [], a3fTmp, 'BusyAction', 'cancel', 'Parent', handles.axes1, 'Interruptible', 'off');
axis image;
%axis ij;
axis off;
set(handles.axes1, 'DataAspectRatioMode', 'auto');
set(handles.axes1, 'PlotBoxAspectRatioMode', 'auto');

bMarkFloorEdges = true;
if isfield(strctAdditionalInfo.strctBackground,'m_a2bFloor') && ~isempty(strctAdditionalInfo.strctBackground.m_a2bFloor)
    C = bwboundaries(strctAdditionalInfo.strctBackground.m_a2bFloor);
    hFloorArea = plot(handles.axes1, C{1}(:,2),C{1}(:,1),'b');
    setappdata(handles.figure1,'hFloorArea',hFloorArea);
    strChoice = questdlg('Do you want to mark other floor edges?', 'Floor Edges Confirmation', 'No, keep these.', 'Yes, I can do better.', 'No, keep these.');
    if strcmp(strChoice, 'No, keep these.')
       bMarkFloorEdges = false;
    else
       delete(hFloorArea);
    end
end

%% Mark floor edges
if bMarkFloorEdges
   setappdata(handles.figure1,'bEnableEllipseEditing',false);
   set(handles.hButton, 'visible', 'off');
   set(handles.slider1, 'visible', 'off');
   a2bMask = [];
   while isempty(a2bMask)
      a2bMask = roipoly(strctAdditionalInfo.strctBackground.m_a2fMedian);
%       uiwait(handles.figure1);
   end
   strctAdditionalInfo.strctBackground.m_a2bFloor = a2bMask;
   setappdata(handles.figure1,'bEnableEllipseEditing',true);
end

%%
if ~isfield(strctAdditionalInfo.strctBackground, 'm_astrctTuningEllipses')
   iNumMice = getappdata(handles.figure1,'iNumMice');
   aiSampleFrames = getappdata(handles.figure1,'aiSampleFrames');
   iNumReinitalizations = 5;
   set(handles.figure1,'pointer','watch');  drawnow('expose');  drawnow('update');
   astrctEllipses = fnFindBoundingEllipses(strctAdditionalInfo, iNumMice, aiSampleFrames, iNumReinitalizations);
   set(handles.figure1,'pointer','watch');  drawnow('expose');  drawnow('update');
   % Set up the figure for user editing of ellipses.
   set(handles.hButton, 'visible', 'on');
   set(handles.slider1, 'visible', 'on');
   set(handles.text1, 'string', 'Mark mice with ellipses. Double click when you''re done.');
   setappdata(handles.figure1,'iCurrSample',1);
else
   set(handles.hButton, 'visible', 'on');
   set(handles.slider1, 'visible', 'on');
   set(handles.text1, 'string', 'Mark mice with ellipses. Double click when you''re done.');
   setappdata(handles.figure1,'iCurrSample',1);
   hFig=handles.figure1;
   iNumMice = getappdata(handles.figure1,'iNumMice');
   astrctEllipses = strctAdditionalInfo.strctBackground.m_astrctTuningEllipses;
   aiSampleFrames = [astrctEllipses.m_iFrame];
end
setappdata(handles.figure1,'astrctEllipses',astrctEllipses);

setappdata(handles.figure1,'strctAdditionalInfo', strctAdditionalInfo);
setappdata(handles.figure1,'aiSampleFrame', aiSampleFrames);
setappdata(handles.figure1,'bInvertForeground',false);

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
   
   iMinD = 10;
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
   d = max(iMinD, d);
   if bMajor
      t = atan2(-u(2),u(1)) + (1-iSign)*pi/2;
      a = d;
   else
      t = -atan2(-u(1),u(2)) + (1+iSign)*pi/2;
      b = d;
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
    [hHandle,ahShapeHandles] = fnDrawTrackerNoTail(handles.axes1,astrctEllipses(iCurrSample).m_astrctEllipse(iMouseIter),a2fCol(iMouseIter,:), 2,1);
    ahHandles = [ahHandles;hHandle];
    a2hShapeControls(:,iMouseIter) = ahShapeHandles;
end;
setappdata(handles.figure1,'a2hShapeControls',a2hShapeControls);
setappdata(handles.figure1,'ahHandles',ahHandles);

return;

function strctEllipse = fnKeepInsideFrame(strctEllipse, handles)
%
strctAdditionalInfo = getappdata(handles.figure1,'strctAdditionalInfo');
w = strctAdditionalInfo.strctMovieInfo.m_iWidth;
h = strctAdditionalInfo.strctMovieInfo.m_iHeight;
t = strctEllipse.m_fTheta;
if isnan(t) || isinf(t)
    t = 0;
    strctEllipse.m_fTheta = 0;
end
a = max(10, min(100, strctEllipse.m_fA));
b = max(8, min(100, strctEllipse.m_fB));
strctEllipse.m_fA = a;
strctEllipse.m_fB = b;
mx = abs(a * cos(t)) + abs(b * sin(t)) + 6;
my = abs(a * sin(t)) + abs(b * cos(t)) + 6;
strctEllipse.m_fX = max(mx, min(w-mx, strctEllipse.m_fX));
strctEllipse.m_fY = max(my, min(h-my, strctEllipse.m_fY));

% --- Outputs from this function are returned to the command line.
function varargout = TuneSegmentationGUI_OutputFcn(hObject, eventdata, handles)
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


% --------------------------------------------------------------------
function hSaveBackground_Callback(hObject, eventdata, handles)
%
fnSaveBackground(handles);

function fnSaveBackground(handles)
%
global g_bMouseHouse;
strResultsFolder = getappdata(handles.figure1,'strResultsFolder');
if g_bMouseHouse
   strOutputFile = fullfile(strResultsFolder,'Detection.mat');
else
   [strFile,strPath] = uiputfile([strResultsFolder,'Detection.mat']);
   if strFile(1) == 0
      return;
   end;
   strOutputFile = [strPath,strFile];
end;
astrctEllipses = getappdata(handles.figure1,'astrctEllipses');
strctAdditionalInfo = getappdata(handles.figure1,'strctAdditionalInfo');
strctMovieInfo = strctAdditionalInfo.strctMovieInfo;
strctBackground.m_strctSegParams = strctAdditionalInfo.strctBackground.m_strctSegParams;
strctBackground.m_a2fMedian = strctAdditionalInfo.strctBackground.m_a2fMedian;
strctBackground.m_a2bFloor = strctAdditionalInfo.strctBackground.m_a2bFloor;
strctBackground.m_astrctTuningEllipses = astrctEllipses;
strctBackground.m_strMethod = 'FrameDiff_v7';
fprintf('Writing %s to disk...',strOutputFile);
save(strOutputFile,'strctMovieInfo','strctBackground');
fprintf('Done!\n');


% --------------------------------------------------------------------
function hLoadBackground_Callback(hObject, eventdata, handles)
%
strctAdditionalInfo = fnLoadBackground(handles);
setappdata(handles.figure1,'strctAdditionalInfo',strctAdditionalInfo);
fnTune(handles);
return;


function strctAdditionalInfo = fnLoadBackground(handles)
%
global g_bMouseHouse;
strResultsFolder = getappdata(handles.figure1,'strResultsFolder');
if g_bMouseHouse
   strInputFile = fullfile(strResultsFolder,'Detection.mat');
else
   [strFile,strPath] = uiputfile([strResultsFolder,'Detection.mat']);
   if strFile(1) == 0
      return;
   end;
   strInputFile = [strPath,strFile];
end;
fprintf('Reading from disk...');
fnLog(['Loading ' strInputFile]);
load(strInputFile);
fprintf('Done!\n');
setappdata(handles.figure1,'astrctEllipses',strctBackground.m_astrctTuningEllipses);
setappdata(handles.figure1,'a2fMedian',strctBackground.m_a2fMedian);
setappdata(handles.figure1,'a2bFloor',strctBackground.m_a2bFloor);
setappdata(handles.figure1,'strctMovieInfo',strctMovieInfo);
setappdata(handles.figure1,'iCurrSample',0);
strctAdditionalInfo.strctBackground = strctBackground;
strctAdditionalInfo.strctMovieInfo = strctMovieInfo;
set(handles.slider1,'min',1,'max',length(strctBackground.m_astrctTuningEllipses),'value',1,'SliderStep',[1 10]/length(strctBackground.m_astrctTuningEllipses));
fnLog(['Loaded ' num2str(length(strctBackground.m_astrctTuningEllipses)) ' sample frames. Median image is '], 1, strctBackground.m_a2fMedian);
return;

% --- Executes on button press in hButton.
function hButton_Callback(hObject, eventdata, handles)
%

iCurrSample = getappdata(handles.figure1,'iCurrSample');
astrctEllipses = getappdata(handles.figure1,'astrctEllipses');
bFinishedSeg = getappdata(handles.figure1, 'bFinishedSeg');
if isempty(bFinishedSeg), bFinishedSeg = false; end;
if iCurrSample==0
  set(handles.slider1,'min',1,'max',length(astrctEllipses),'value',1,'visible','on','SliderStep',[1 10]/length(astrctEllipses));
  setappdata(handles.figure1,'iCurrSample',1);
  setappdata(handles.hButton,'visible','on');
  setappdata(handles.slider1,'visible','on');
  fnInvalidate(handles);
elseif ~bFinishedSeg
  iValidNum = sum([astrctEllipses.m_bValid]);
  if iValidNum > 0
    strctAdditionalInfo = getappdata(handles.figure1,'strctAdditionalInfo');
    astrctEllipses = getappdata(handles.figure1,'astrctEllipses');
    set(hObject,'Enable','off');
    set(handles.figure1,'pointer','watch');
    drawnow('expose');  drawnow('update');
    strctSegParams = fnOptimizeSegmentationParams(strctAdditionalInfo, astrctEllipses);
    set(handles.figure1,'pointer','arrow');
    drawnow('expose');  drawnow('update');
    setappdata(handles.figure1, 'bFinishedSeg', true);
    strctAdditionalInfo.strctBackground.m_strctSegParams = strctSegParams;
    setappdata(handles.figure1,'strctAdditionalInfo',strctAdditionalInfo);
    fnSaveBackground(handles);
    set(handles.slider1,'visible','on');
    set(hObject,'Enable','on');
    set(hObject,'string','Finished Segmentation Optimization - Click to close window');
    fnInvalidate(handles);
  else
    set(handles.text1, 'String',sprintf('All %d frames are marked INVALID. Please turn some of them to VALID, and correct their ellipses. Then try again. ',length(astrctEllipses)));
    drawnow
  end
else
%   answer = ...
%     questdlg(['Do you want to set new Detection parameters as the ' ...
%               'new default parameters?'], ...
%              'Question', ...
%              'Yes','No', ...
%              'No');
  answer='No';         
  if strcmpi(answer,'yes')
    strctAdditionalInfo = getappdata(handles.figure1,'strctAdditionalInfo');
    strctSegParams = strctAdditionalInfo.strctBackground.m_strctSegParams;
    segParamsFN= ...
      fullfile(g_strMouseStuffRootDirName, ...
               'Config', ...
               'defaultSegmentationParams.mat');
    save(segParamsFN,'strctSegParams');
  end
  delete(handles.figure1);
end

return;


% --------------------------------------------------------------------
function Untitled_3_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --------------------------------------------------------------------
% function hChangeSearchParameters_Callback(hObject, eventdata, handles)
% 
% prompt={'Min interval length',...
%     'Skip', ...
%     'Num reinitalizations',...
%     'Max Job Size (Force Key Frame)',...
%     'Missing Frames Detection'};
% name='Parameters';
% numlines=1;
% defaultanswer={'5000','3000','10','50000','10'};
% 
% answer=inputdlg(prompt,name,numlines,defaultanswer);
% if isempty(answer)
%     return;
% end;
% 
% iMinInterval = str2num(answer{1});
% iSkip = str2num(answer{2});
% iNumReinitalizations = str2num(answer{3});
% iMaxJobSize = str2num(answer{4});
% iNumFramesMissing = str2num(answer{5});
% setappdata(handles.figure1,'iMinInterval', iMinInterval);
% setappdata(handles.figure1,'iSkip', iSkip);
% setappdata(handles.figure1,'iNumReinitalizations',iNumReinitalizations);
% % setappdata(handles.figure1,'bIntervalsAvailable',false);
% setappdata(handles.figure1,'iMaxJobSize',iMaxJobSize);
% setappdata(handles.figure1,'iNumFramesMissing',iNumFramesMissing);
% 
% return;
 


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
set(handles.slider1,'value',iCurrSample );
setappdata(handles.figure1,'iCurrSample',iCurrSample );
fnInvalidate(handles);

return;

function fnInvalidate(handles)
%
% I think this is called "fnInvalidate" b/c it's where the figure is
% reconfigured so that the user can mark the mice with ellipses, which are
% then used for segmentation tuning.  So you're marking which pixels are
% not valid background pixels.  --ALT, 2012-02-21
astrctEllipses = getappdata(handles.figure1,'astrctEllipses');
iCurrSample = getappdata(handles.figure1,'iCurrSample');
strctAdditionalInfo = getappdata(handles.figure1,'strctAdditionalInfo');
strctMovieInfo = strctAdditionalInfo.strctMovieInfo;

iCurrFrame = astrctEllipses(iCurrSample).m_iFrame;
a2iFrame = fnReadFrameFromVideo(strctMovieInfo,iCurrFrame);
a2fFrame = double(a2iFrame)/255;

bInvertForeground = getappdata(handles.figure1,'bInvertForeground');
if bInvertForeground
   a2bOnlyMouse = fnSegmentForeground2(a2fFrame, strctAdditionalInfo)>0;
   a2fFrame(a2bOnlyMouse) = 1 - a2fFrame(a2bOnlyMouse);
end

cla;
a3fTmp(:,:,1)=a2fFrame;a3fTmp(:,:,2)=a2fFrame;a3fTmp(:,:,3)=a2fFrame;
image([], [], a3fTmp, 'BusyAction', 'cancel', 'Parent', handles.axes1, 'Interruptible', 'off');
%axis ij
axis image
axis off;
%set(handles.axes1, 'DataAspectRatioMode', 'auto');
%set(handles.axes1, 'PlotBoxAspectRatioMode', 'auto');

a2fCol = [1,0,0;
    0,1,0;
    0,0,1;
    0,1,1;
    1,1,0;
    1,0,1];

if astrctEllipses(iCurrSample).m_bValid
    iNumMice = getappdata(handles.figure1,'iNumMice');
    ahHandles = [];
    a2hShapeControls= [];
    for iMouseIter=1:iNumMice
        [hHandle,ahShapeHandles] = fnDrawTrackerNoTail(handles.axes1,astrctEllipses(iCurrSample).m_astrctEllipse(iMouseIter),a2fCol(iMouseIter,:), 2,1);
        ahHandles = [ahHandles;hHandle];
        a2hShapeControls(:,iMouseIter) = ahShapeHandles;
    end;
    setappdata(handles.figure1,'a2hShapeControls',a2hShapeControls);
    setappdata(handles.figure1,'ahHandles',ahHandles);
else
   text(300,300,'INVALID','color','r');
   setappdata(handles.figure1,'a2hShapeControls',[]);
   setappdata(handles.figure1,'ahHandles',[]);    
end;
set(handles.text1, 'String',sprintf('%d out of %d (including %d valid frames)    [Frame %d]',iCurrSample,length(astrctEllipses),sum([astrctEllipses.m_bValid]),iCurrFrame));

drawnow

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
    [iSelectedController,iSelectedMouse] = find(a2fMinDist == min(12,min(a2fMinDist(:))),1,'first');
    setappdata(handles.figure1,'iSelectedMouse',iSelectedMouse);
    setappdata(handles.figure1,'iSelectedController',iSelectedController);
    setappdata(handles.figure1,'pt2fMouseDown',pt2fPoint);

end;
setappdata(handles.figure1,'bMouseDown',1);


astrctEllipses = getappdata(handles.figure1,'astrctEllipses');
iCurrSample = getappdata(handles.figure1,'iCurrSample');
strMouseType = get(handles.figure1,'selectiontype');
if (strcmp( strMouseType,'alt'))
    astrctEllipses(iCurrSample).m_bValid = ~astrctEllipses(iCurrSample).m_bValid;
elseif (strcmp( strMouseType,'open'))
   bInvertForeground = getappdata(handles.figure1,'bInvertForeground');
   setappdata(handles.figure1,'bInvertForeground',~bInvertForeground);
end;

setappdata(handles.figure1,'astrctEllipses',astrctEllipses);
fnInvalidate(handles);

return;


function astrctEllipses = fnFindBoundingEllipses(strctAdditionalInfo, iNumMice, aiSampleFrames, iNumReinitializations)
%
global g_strctGlobalParam;
iNumSampleFrames = length(aiSampleFrames);
fprintf('Processing frames: ');
astrctEllipses=struct('m_iFrame',cell(1,iNumSampleFrames), ...
                      'm_bValid',cell(1,iNumSampleFrames), ...
                      'm_astrctEllipse',cell(1,iNumSampleFrames));
for i=1:iNumSampleFrames
   iCurrFrame = aiSampleFrames(i);
   fprintf('%d; ',iCurrFrame);
   a2iFrame = fnReadFrameFromVideo(strctAdditionalInfo.strctMovieInfo,iCurrFrame);
   [bFailed, acstrctSampleEllipses] = fnRiskyInit2(a2iFrame, strctAdditionalInfo, iNumMice, iNumReinitializations);
   if bFailed
      % need to deal with failure in some way
      % Make up arbitrary but reasonable ellipses, and let the uses fix
      % them.
      [fHeightFrame,fWidthFrame]=size(a2iFrame);
      fX=(fWidthFrame+1)/2;
      fY=(fHeightFrame+1)/2;
      fAMax=g_strctGlobalParam.m_strctTracking.m_fMaxPredictMajorAxis;
      fAMin=g_strctGlobalParam.m_strctTracking.m_fMinPredictMajorAxis;
      fA=(fAMax+fAMin)/2;
      fB=fA/2;
      fTheta=0;
      strctEllipse=struct('m_fX',fX,...
                          'm_fY',fY,...
                          'm_fA',fA,...
                          'm_fB',fB,...
                          'm_fTheta',fTheta);
      astrctEllipse=repmat(strctEllipse,[1 iNumMice]);
      % store stuff in the return variable
      strctSample.m_iFrame = iCurrFrame;
      strctSample.m_bValid = false;  % is this right?  -- ALT
      strctSample.m_astrctEllipse = astrctEllipse;
   else
      strctSample.m_iFrame = iCurrFrame;
      strctSample.m_bValid = true;
      strctSample.m_astrctEllipse = acstrctSampleEllipses{1};
        % just use the ellipses from the first hypothesis
   end
   astrctEllipses(i) = strctSample;
end;
fprintf(' ; Done \n');
return;

% This function is not called, so commented it out.  --ALT, 2012-03-09
% function a2bEllipses = fnMarkEllipse(a2bEllipses, strctEllipse)
% %
% N = 400; 
% afTheta = linspace(0,2*pi,N);
% apt2f = [strctEllipse.m_fA * cos(afTheta); strctEllipse.m_fB * sin(afTheta)];
% R = [ cos(strctEllipse.m_fTheta), sin(strctEllipse.m_fTheta);
%     -sin(strctEllipse.m_fTheta), cos(strctEllipse.m_fTheta)];
% apt2iFinal = round(R*apt2f + repmat([strctEllipse.m_fX;strctEllipse.m_fY],1,N));
% % a2bEllipses(sub2ind(apt2iFinal(2,:),apt2iFinal(1,:))) = true;
% for i=1:N, a2bEllipses(apt2iFinal(2,i),apt2iFinal(1,i)) = true; end



% iNumSamples = length(astrctEllipses);
% afSegError = zeros(1,iNumSamples);
% for iSample=1:iNumSamples
%    if astrctEllipses(iSample).m_bValid
%       a2fFrame = double(fnReadFrameFromVideo(strctAdditionalInfo.strctMovieInfo, astrctEllipses(iSample).m_iFrame))/255;
%       a2bOnlyMouse = fnSegmentForeground2(a2fFrame, strctAdditionalInfo)>0;
%       a2bEllipses = fnEllipseBinaryImage(strctAdditionalInfo, astrctEllipses(iSample).m_astrctEllipse, size(a2fFrame));
%       %    astrctProps = regionprops(a2iOnlyMouse,'PixelList');
%       %    a2fPixelList = cat(1,astrctProps.PixelList);
%       a2bDiff = xor(a2bOnlyMouse, a2bEllipses);
%       afSegError(iSample) = sum(a2bDiff(:));
%    end
% end


% --- Executes on key press with focus on hButton and none of its controls.
function hButton_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to hButton (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
