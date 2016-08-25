function varargout = SnapshotReview(varargin)
% SNAPSHOTREVIEW M-file for SnapshotReview.fig
%      SNAPSHOTREVIEW, by itself, creates a new SNAPSHOTREVIEW or raises the existing
%      singleton*.
%
%      H = SNAPSHOTREVIEW returns the handle to a new SNAPSHOTREVIEW or the handle to
%      the existing singleton*.
%
%      SNAPSHOTREVIEW('CALLBACK',hObject,eventData,handles,...) calls the
%      local
%      function named CALLBACK in SNAPSHOTREVIEW.M with the given input arguments.
%
%      SNAPSHOTREVIEW('Property','Value',...) creates a new SNAPSHOTREVIEW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SnapshotReview_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SnapshotReview_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SnapshotReview

% Last Modified by GUIDE v2.5 23-Jan-2011 23:58:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SnapshotReview_OpeningFcn, ...
                   'gui_OutputFcn',  @SnapshotReview_OutputFcn, ...
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


% --- Executes just before SnapshotReview is made visible.
function SnapshotReview_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SnapshotReview (see VARARGIN)

% Choose default command line output for SnapshotReview
handles.output = hObject;

strctMovieInfo = varargin{1};
astrctTrackers = varargin{2};
astrctTrackers2 = varargin{3};
aiFrames = varargin{4};
strBaseSequence = varargin{5};
strOtherSequence = varargin{6};
aiStatus = ones(1,size(aiFrames,2));
iNumFrames = length(aiFrames);
%load GroundTruthSegment;
iNumWindows = 6;
setappdata(handles.figure1, 'iNumWindows' , iNumWindows);
ahAxes = [handles.axes1 handles.axes2 handles.axes3 handles.axes4 handles.axes5 handles.axes6];
setappdata(handles.figure1, 'ahAxes', ahAxes);
setappdata(handles.figure1, 'strctMovieInfo', strctMovieInfo);
setappdata(handles.figure1, 'astrctTrackers', astrctTrackers);
setappdata(handles.figure1, 'astrctTrackers2', astrctTrackers2);
setappdata(handles.figure1, 'strBaseSequence', strBaseSequence);
setappdata(handles.figure1, 'strOtherSequence', strOtherSequence);
setappdata(handles.figure1, 'aiFrames', aiFrames);

setappdata(handles.figure1, 'aiStatus', aiStatus);

set(handles.figure1,'WindowButtonDownFcn',{@fnMouseDown,handles});

aiCurrFramesIndices = 1:min(6, iNumFrames);
setappdata(handles.figure1, 'aiCurrFramesIndices', aiCurrFramesIndices);

fnShowFrames(handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SnapshotReview wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SnapshotReview_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function fnShowFrame(hAxes, strctMovieInfo, astrctTrackers, astrctTrackers2, iFrame, iStatus)
%
a2iImage = fnReadFrameFromVideo(strctMovieInfo, iFrame);
colormap(gray(256))
hold(hAxes, 'on');
hImage = image([], [], a2iImage, 'BusyAction', 'cancel', 'Parent', hAxes, 'Interruptible', 'off');
fnTitle(hAxes, iFrame, iStatus);
axis(hAxes, 'off');
axis(hAxes, 'ij');
axis(hAxes, 'image');
fnDrawTrackers(hAxes, astrctTrackers, iFrame, 1);
fnDrawTrackers(hAxes, astrctTrackers2, iFrame, 0);
hold(hAxes, 'off');
return;

function fnTitle(hAxes, iFrame, iStatus)
%
strTitle = num2str(iFrame);
switch iStatus
   case 0
      strTitle = [strTitle '  None'];
   case 1
      strTitle = [strTitle '  Base'];
   case 2
      strTitle = [strTitle '  Other'];
end
title(hAxes, strTitle);
return;

function fnShowFrames(handles)
%
hFigure = handles.figure1;
ahAxes = getappdata(hFigure, 'ahAxes');
strctMovieInfo = getappdata(hFigure, 'strctMovieInfo');
astrctTrackers = getappdata(hFigure, 'astrctTrackers');
astrctTrackers2 = getappdata(hFigure, 'astrctTrackers2');
aiFrames = getappdata(hFigure, 'aiFrames');
aiCurrFramesIndices = getappdata(hFigure, 'aiCurrFramesIndices');
aiStatus = getappdata(hFigure, 'aiStatus');
for i=1:length(aiCurrFramesIndices)
   %    set(ahAxes(i),'Visible','on');
   iIndex = aiCurrFramesIndices(i);
   fnShowFrame(ahAxes(i), strctMovieInfo, astrctTrackers, astrctTrackers2, aiFrames(2,iIndex), aiStatus(iIndex));
end
% iNumWindows = getappdata(hFigure, 'iNumWindows');
% if length(aiCurrFramesIndices)<iNumWindows
%    for i=length(aiCurrFramesIndices)+1:iNumWindows
%       set(ahAxes(i),'Visible','off');
%    end
% end
iNumWindows = getappdata(handles.figure1, 'iNumWindows');
iPage = floor(aiCurrFramesIndices(1)/iNumWindows) + 1;
set(handles.hPage, 'String', num2str(iPage));
return;

function fnSaveFrames(handles)
%
hFigure = handles.figure1;
ahAxes = getappdata(hFigure, 'ahAxes');
strctMovieInfo = getappdata(hFigure, 'strctMovieInfo');
astrctTrackers = getappdata(hFigure, 'astrctTrackers');
astrctTrackers2 = getappdata(hFigure, 'astrctTrackers2');
aiFrames = getappdata(hFigure, 'aiFrames');
aiCurrFramesIndices = getappdata(hFigure, 'aiCurrFramesIndices');
aiStatus = getappdata(hFigure, 'aiStatus');
iNumWindows = getappdata(handles.figure1, 'iNumWindows');
iPage = floor(aiCurrFramesIndices(1)/iNumWindows) + 1;
strReviewDocDir = './SnapshotReview/';
mkdir(strReviewDocDir);
strReviewDocFileName = [strReviewDocDir 'Page_' num2str(iPage) '.jpg'];
fprintf('Writing snapshot to %s ... ', strReviewDocFileName);
X=getframe(handles.figure1);
imwrite(X.cdata, strReviewDocFileName, 'jpg');
% print(handles.figure1, '-dpdf', strReviewDocFileName);
fprintf('Done\n');
strBaseSequence = getappdata(handles.figure1, 'strBaseSequence');
strOtherSequence = getappdata(handles.figure1, 'strOtherSequence');
fprintf('Writing database information to GroundTruthSegment ... ');
save GroundTruthSegment strctMovieInfo astrctTrackers astrctTrackers2 aiFrames aiStatus strBaseSequence strOtherSequence;
fprintf('Done\n');
return;


function a2fCol = fnGetMiceColors()
a2fCol = [1,0,0;
    0,1,0;
    0,0,1;
    0,1,1;
    1,1,0;
    1,0,1];
return;

function fnDrawTrackers(hAxes, astrctTrackers, iFrame, bMainTracker)
a2fCol = fnGetMiceColors();
for iMouseIter=1:length(astrctTrackers)
    strctTracker = fnGetTrackerAtFrame(astrctTrackers, iMouseIter, iFrame);
    hHandle = fnDrawTracker(hAxes,strctTracker, a2fCol(iMouseIter,:), 2-bMainTracker,0, bMainTracker);
end;
return;


function fnMouseDown(obj,eventdata,handles)
%
setappdata(handles.figure1,'bMouseDown',1);
aiCurrFramesIndices = getappdata(handles.figure1, 'aiCurrFramesIndices');
iWin = fnGetActiveWindow(handles);
if iWin>=1 && iWin<=length(aiCurrFramesIndices)
   iFrameIndex = aiCurrFramesIndices(iWin);
   aiStatus = getappdata(handles.figure1, 'aiStatus');
   iStatus = aiStatus(iFrameIndex);
   strMouseClick = fnGetClickType(handles.figure1);
   switch strMouseClick
      case 'Left'
         aiStatus(iFrameIndex) = 3 - max(1,iStatus);
      case 'Right'
         aiStatus(iFrameIndex) = 0;
   end;
   setappdata(handles.figure1, 'aiStatus', aiStatus);
   ahAxes = getappdata(handles.figure1, 'ahAxes');
   aiFrames = getappdata(handles.figure1, 'aiFrames');
   fnTitle(ahAxes(iWin), aiFrames(2,iFrameIndex), aiStatus(iFrameIndex));
end;
return;

function strMouseClick = fnGetClickType(hFigure)
strMouseType = get(hFigure,'selectiontype');
if (strcmp( strMouseType,'alt'))
    strMouseClick = 'Right';
end;
if (strcmp( strMouseType,'normal'))
    strMouseClick = 'Left';
end;
if (strcmp( strMouseType,'extend'))
    strMouseClick = 'Both';
end;
if (strcmp( strMouseType,'open'))
    strMouseClick = 'DoubleClick';
end;
return;

function iWin = fnGetActiveWindow(handles)
%
iNumWindows = getappdata(handles.figure1, 'iNumWindows');
ahAxes = getappdata(handles.figure1, 'ahAxes');
for i=1:iNumWindows
   if (fnInsideImage(handles, ahAxes(i)))
      iWin = i;
      return;
   end;
end;
iWin = 0;
return;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fnSaveFrames(handles);
aiCurrFramesIndices = getappdata(handles.figure1, 'aiCurrFramesIndices');
iNumWindows = getappdata(handles.figure1, 'iNumWindows');
aiFrames = getappdata(handles.figure1, 'aiFrames');
iFirstFramesIndex = max(aiCurrFramesIndices(1)-iNumWindows,1);
aiCurrFramesIndices = iFirstFramesIndex:min(iFirstFramesIndex+iNumWindows-1, size(aiFrames,2));
setappdata(handles.figure1, 'aiCurrFramesIndices', aiCurrFramesIndices);
fnShowFrames(handles);


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fnSaveFrames(handles);
aiCurrFramesIndices = getappdata(handles.figure1, 'aiCurrFramesIndices');
iNumWindows = getappdata(handles.figure1, 'iNumWindows');
aiFrames = getappdata(handles.figure1, 'aiFrames');
iFirstFramesIndex = min(aiCurrFramesIndices(1)+iNumWindows,size(aiFrames,2));
aiCurrFramesIndices = iFirstFramesIndex:min(iFirstFramesIndex+iNumWindows-1,size(aiFrames,2));
setappdata(handles.figure1, 'aiCurrFramesIndices', aiCurrFramesIndices);
fnShowFrames(handles);


% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function hPage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hPage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
