function varargout = AnnotationGUI(varargin)
% ANNOTATIONGUI M-file for AnnotationGUI.fig
%      ANNOTATIONGUI, by itself, creates a new ANNOTATIONGUI or raises the existing
%      singleton*.
%
%      H = ANNOTATIONGUI returns the handle to a new ANNOTATIONGUI or the handle to
%      the existing singleton*.
%
%      ANNOTATIONGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ANNOTATIONGUI.M with the given input arguments.
%
%      ANNOTATIONGUI('Property','Value',...) creates a new ANNOTATIONGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AnnotationGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AnnotationGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help AnnotationGUI

% Last Modified by GUIDE v2.5 25-Oct-2009 21:35:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @AnnotationGUI_OpeningFcn, ...
    'gui_OutputFcn',  @AnnotationGUI_OutputFcn, ...
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
function my_closereq(a,b,handles)
% User-defined close request function
% to display a question dialog box
selection = questdlg('Save annotation file and quit?',...
    'Warning',...
    'Yes','No, Just Exit','Cancel','Yes');
switch selection,
    case 'Yes',
        fnSaveAnnotations(handles)
        delete(gcf)
        clear global
    case 'No, Just Exit'
        clear global
        delete(gcf)
        return
end
return;

function fnSetDefaultDetectParams(handles)

strctFollowingParams.m_fVelocityThresholdPix = 10;
strctFollowingParams.m_fSameOrientationAngleThresDeg = 90;
strctFollowingParams.m_fDistanceThresholdPix = 250;
strctFollowingParams.m_iMergeIntervalsFrames = 30;
strctFollowingParams.m_iDiscardInterval = 5;
setappdata(handles.figure1,'strctFollowingParams',strctFollowingParams);

strctButtSniffParams.m_fVelocityThresholdPix = 5;
strctButtSniffParams.m_fHeadToButtDistPix = 20;
strctButtSniffParams.m_fBodiesAwayMult = 2;
strctButtSniffParams.m_iMergeIntervalsFrames = 30;
strctButtSniffParams.m_iDiscardInterval = 3;
setappdata(handles.figure1,'strctButtSniffParams',strctButtSniffParams);

strctHeadSniffParams.m_fVelocityThresholdPix = 5;
strctHeadSniffParams.m_fHeadToHeadDistPix = 15;
strctHeadSniffParams.m_fBodiesAwayMult = 2;
strctHeadSniffParams.m_iMergeIntervalsFrames = 30;
strctHeadSniffParams.m_iDiscardInterval = 3;
setappdata(handles.figure1,'strctHeadSniffParams',strctHeadSniffParams);


set(handles.hFollowDist,'String', num2str(strctFollowingParams.m_fDistanceThresholdPix));
set(handles.hFollowMerge,'String', num2str(strctFollowingParams.m_iMergeIntervalsFrames));
set(handles.hFollowSameOri,'String', num2str(strctFollowingParams.m_fSameOrientationAngleThresDeg));
set(handles.hFollowVel,'String', num2str(strctFollowingParams.m_fVelocityThresholdPix));


set(handles.hButtSniffVel,'String', num2str(strctButtSniffParams.m_fVelocityThresholdPix));
set(handles.hButtSniffHeadDist,'String', num2str(strctButtSniffParams.m_fHeadToButtDistPix));
set(handles.hButtSniffAwayMult,'String', num2str(strctButtSniffParams.m_fBodiesAwayMult));
set(handles.hButtSniffMerge,'String', num2str(strctButtSniffParams.m_iMergeIntervalsFrames));

set(handles.hHeadSniffVel,'String', num2str(strctHeadSniffParams.m_fVelocityThresholdPix));
set(handles.hHeadSniffHeadDist,'String', num2str(strctHeadSniffParams.m_fHeadToHeadDistPix));
set(handles.hHeadSniffAwayMult,'String', num2str(strctHeadSniffParams.m_fBodiesAwayMult));
set(handles.hHeadSniffMerge,'String', num2str(strctHeadSniffParams.m_iMergeIntervalsFrames));

return;


% --- Executes just before AnnotationGUI is made visible.
function AnnotationGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AnnotationGUI (see VARARGIN)

% Choose default command line output for AnnotationGUI
clear global
global g_strctExperiment g_strctBehaviors g_strctConst

g_strctConst.m_iFollowing = 1;
g_strctConst.m_iButtSniff = 2;
g_strctConst.m_iHeadSniff = 3;

handles.output = hObject;
fnFirstInvalidate(handles);
fnSetDefaultDetectParams(handles);

set(handles.figure1,'CloseRequestFcn',{@my_closereq,handles});

if length(varargin) >=2 && ~isempty(varargin{2})
    % search for "final" result file
    strResultsFolder = varargin{2};
    setappdata(handles.figure1,'strResultsFolder',strResultsFolder);
    strFinalResultFile = [strResultsFolder,'Correct.mat'];
    if exist(strFinalResultFile,'file')
        fprintf('Found final tracking results. Loading it up...\n');
        fnLoadNewPositionFile(handles,strFinalResultFile);
        
        strAnnotationFile = [strResultsFolder,'Annotation.mat'];
        if exist(strFinalResultFile,'file')
            fprintf('Found annotation file. Loading...');
            fnLoadAnnotation(handles, strAnnotationFile);
            fnInvalidateBehaviorList(handles);
            fprintf('Done!\n');
        end;
        
    else
        fnLoadNewVideoFile(handles,varargin{1});
    end;
end;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes AnnotationGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function fnFirstInvalidate(handles)
a3fCdata = zeros(768,1024);
colormap(gray(256))
hImage = image([], [], a3fCdata, 'BusyAction', 'cancel', 'Parent', handles.hImageAxes, 'Interruptible', 'off');
setappdata(handles.figure1,'hImage',hImage);

hTSImage = image([], [], zeros(20,180), 'BusyAction', 'cancel', 'Parent', handles.hTimestampAxes, 'Interruptible', 'off');
setappdata(handles.figure1,'hTSImage',hTSImage);


set(handles.hImageAxes,'visible','off');
set(handles.hTimestampAxes,'visible','off');

hold(handles.hImageAxes,'on');
hold(handles.hAxes,'on')
box(handles.hAxes,'on')
setappdata(handles.figure1,'iCurrFrame',0);
setappdata(handles.figure1,'iCurrMouse',1);
setappdata(handles.figure1,'iZoomRangeX',500);
setappdata(handles.figure1,'bMouseDown',0);
setappdata(handles.figure1,'iZoomRangeY',10);
setappdata(handles.figure1,'iCurrY',0);
fnSetNumMice(handles, 0);


strctEmptyBehavior.m_iStart = -1;
strctEmptyBehavior.m_iEnd = -1;
strctEmptyBehavior.m_strDescription = ''; % Grooming, Chasing Red, ...
strctEmptyBehavior.m_hDrawHandle = [];

acAnnotation{1}(1) = strctEmptyBehavior;
acAnnotation{2}(1) = strctEmptyBehavior;
acAnnotation{3}(1) = strctEmptyBehavior;
acAnnotation{4}(1) = strctEmptyBehavior;

setappdata(handles.figure1,'strResultsFolder','');

setappdata(handles.figure1,'acAnnotation',acAnnotation);
fnCreateContextMenu(handles);

set(handles.figure1,'WindowButtonDownFcn',{@fnMouseDown,handles});
set(handles.figure1,'WindowButtonUpFcn',{@fnMouseUp,handles});
set(handles.figure1,'WindowButtonMotionFcn',{@fnMouseMove,handles});
set(handles.figure1,'WindowScrollWheelFcn',{@fnMouseScroll,handles});
set(handles.figure1,'Units','pixels');
return;

function fnCreateContextMenu(handles)
cmenu = uicontextmenu;
item1 = uimenu(cmenu, 'Label', 'Sleeping', 'Callback', {@fnChangeBehavior,handles,'Sleeping',''});
item2 = uimenu(cmenu, 'Label', 'Grooming', 'Callback', {@fnChangeBehavior,handles,'Grooming',''});
item3 = uimenu(cmenu, 'Label', 'Eating/Drinking', 'Callback', {@fnChangeBehavior,handles,'Eating/Drinking',''});
item4 = uimenu(cmenu, 'Label', 'Exploring/Running', 'Callback', {@fnChangeBehavior,handles,'Exploring/Running',''});
item5 = uimenu(cmenu, 'Label', 'Chasing');
uimenu(item5, 'Label', 'Red','Callback', {@fnChangeBehavior,handles,'Chasing','Red'});
uimenu(item5, 'Label', 'Green','Callback', {@fnChangeBehavior,handles,'Chasing','Green'});
uimenu(item5, 'Label', 'Blue','Callback',  {@fnChangeBehavior,handles,'Chasing','Blue'});
uimenu(item5, 'Label', 'Cyan','Callback',  {@fnChangeBehavior,handles,'Chasing','Cyan'});
item6 = uimenu(cmenu, 'Label', 'Fighting');
uimenu(item6, 'Label', 'Red','Callback', {@fnChangeBehavior,handles,'Fighting','Red'});
uimenu(item6, 'Label', 'Green','Callback', {@fnChangeBehavior,handles,'Fighting','Green'});
uimenu(item6, 'Label', 'Blue','Callback',  {@fnChangeBehavior,handles,'Fighting','Blue'});
uimenu(item6, 'Label', 'Cyan','Callback',  {@fnChangeBehavior,handles,'Fighting','Cyan'});

item7 = uimenu(cmenu, 'Label', 'Sniffing');
uimenu(item7, 'Label', 'Red','Callback', {@fnChangeBehavior,handles,'Sniffing','Red'});
uimenu(item7, 'Label', 'Green','Callback', {@fnChangeBehavior,handles,'Sniffing','Green'});
uimenu(item7, 'Label', 'Blue','Callback',  {@fnChangeBehavior,handles,'Sniffing','Blue'});
uimenu(item7, 'Label', 'Cyan','Callback',  {@fnChangeBehavior,handles,'Sniffing','Cyan'});

item8 = uimenu(cmenu, 'Label', 'Courting');
uimenu(item8, 'Label', 'Red','Callback', {@fnChangeBehavior,handles,'Courting','Red'});
uimenu(item8, 'Label', 'Green','Callback', {@fnChangeBehavior,handles,'Courting','Green'});
uimenu(item8, 'Label', 'Blue','Callback',  {@fnChangeBehavior,handles,'Courting','Blue'});
uimenu(item8, 'Label', 'Cyan','Callback',  {@fnChangeBehavior,handles,'Courting','Cyan'});

uimenu(cmenu, 'Label', 'Delete', 'Callback', {@fnChangeBehavior,handles,'Delete',''}, 'Separator','on');
setappdata(handles.figure1,'cmenu',cmenu);
return;

function afColor = fnGetBehaviorColors(strBehavior,strAdditionalInfo)
switch lower(strBehavior)
    case 'sleeping'
        iIndex = 1;
    case 'grooming'
        iIndex = 2;
    case 'eating/drinking'
        iIndex = 3;
    case 'exploring/running'
        iIndex = 4;
    case 'chasing'
        iIndex = 5;
    case 'fighting'
        iIndex = 6;
    case 'sniffing'
        iIndex = 7;
    case 'courting'
        iIndex = 8;
    otherwise
        iIndex = 9;
end
A=hsv;
afColor = A(round(iIndex/9 * size(A,1)),:);
return;


function fnChangeBehavior(a,b,handles,strDescription,strAdditionalInfo)
error('');

strctMouseDown = getappdata(handles.figure1,'strctMouseDown');
iCurrMouse = getappdata(handles.figure1,'iCurrMouse');
acAnnotation = getappdata(handles.figure1,'acAnnotation');

[iIndex] = fnGetSelectedInterval(handles,strctMouseDown);

if isempty(iIndex)
    fprintf('Critical error - no interval found?!?!?!\n');
    return;
end;
if strcmpi(strDescription,'Delete')
    delete(acAnnotation{iCurrMouse}(iIndex).m_hDrawHandle);
    acAnnotation{iCurrMouse}(iIndex) = [];
else
    afColor = fnGetBehaviorColors(strDescription,strAdditionalInfo);
    acAnnotation{iCurrMouse}(iIndex).m_strDescription = [strDescription,' ',strAdditionalInfo];
    set(acAnnotation{iCurrMouse}(iIndex).m_hDrawHandle,'facecolor', afColor);
end;

setappdata(handles.figure1,'acAnnotation',acAnnotation);
return;




% --- Outputs from this function are returned to the command line.
function varargout = AnnotationGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function fnSafeDelete(ahHandles)
for k=1:length(ahHandles)
    if ishandle(ahHandles(k))
        delete(ahHandles(k));
    end
end;
return;

function fnDrawTrackers(handles,iCurrFrame, iCurrMouse)
global g_strctExperiment
iNumMice = size(g_strctExperiment.a2fX,1);
ahHandles = getappdata(handles.figure1,'hTrackerHighlights');
fnSafeDelete(ahHandles);
for iMouseIter=1:iNumMice
    [afSelected, afUnSelected] = fnGetMiceColors(iMouseIter);
    strctTracker.m_fX = g_strctExperiment.a2fX(iMouseIter, iCurrFrame);
    strctTracker.m_fY = g_strctExperiment.a2fY(iMouseIter, iCurrFrame);
    strctTracker.m_fA = g_strctExperiment.a2fA(iMouseIter, iCurrFrame);
    strctTracker.m_fB = g_strctExperiment.a2fB(iMouseIter, iCurrFrame);
    strctTracker.m_fTheta = g_strctExperiment.a2fTheta(iMouseIter, iCurrFrame);
    
    if iMouseIter == iCurrMouse
        hHandle = fnDrawTracker(handles.hImageAxes,strctTracker,afSelected, 1,0);
    else
        hHandle = fnDrawTracker(handles.hImageAxes,strctTracker, afUnSelected, 1,0);
    end;
    ahHandles = [ahHandles;hHandle];
end;
setappdata(handles.figure1,'hTrackerHighlights',ahHandles);
return;

function hHandle = fnDrawRect(aiCoord, aiCol,cmenu)
w = abs(aiCoord(2) - aiCoord(1));
h = abs(aiCoord(4) - aiCoord(3));
cx = min(aiCoord([1,2])) ;
cy = min(aiCoord([3,4])) ;

hHandle = rectangle('position',[cx,cy,w,h],'facecolor',aiCol,'UIContextMenu', cmenu);
return;

function fnDrawAnnotation(handles,iCurrFrame,iCurrMouse)
global g_strctBehaviors g_strctExperiment
aiSelectedMouseBehaviors = find(g_strctBehaviors.m_aiMouseA == iCurrMouse);
iNumFrames = getappdata(handles.figure1,'iNumFrames');

cla(handles.hAxes);
[afSelected, afUnSelected] = fnGetMiceColors(iCurrMouse);
iZoomRangeX = getappdata(handles.figure1,'iZoomRangeX');
%hVelocityTrace = plot(handles.hAxes, 0.8 + 0.09*afVelNorm,'color',afUnSelected,'Linewidth',2);
%hLowerBound = plot(handles.hAxes,[0 iNumFrames],[0.8 0.8],'--k','LineWidth',2);
%hUpperBound = plot(handles.hAxes,[0 iNumFrames],[0.9 0.9],'--k','LineWidth',2);

iZoomRangeY = getappdata(handles.figure1,'iZoomRangeY');
iCurrY = getappdata(handles.figure1,'iCurrY');
afYZoom = min(10,max(0,[iCurrY-iZoomRangeY,iCurrY+iZoomRangeY]));

hCurrFrameIndicator = plot(handles.hAxes,[iCurrFrame iCurrFrame],[0 10],'--k');
setappdata(handles.figure1,'hCurrFrameIndicator',hCurrFrameIndicator);
axis(handles.hAxes,[iCurrFrame-iZoomRangeX iCurrFrame+iZoomRangeX afYZoom]);
%set(handles.hAxes,'Xtick',[iCurrFrame-iZoomRangeX+1, iCurrFrame, iCurrFrame+iZoomRangeX-1])
%hLowerBound = plot(handles.hAxes,[0 iNumFrames],[0.6 0.6],'--k','LineWidth',2);
%hUpperBound = plot(handles.hAxes,[0 iNumFrames],[0.7 0.7],'--k','LineWidth',2);
%hAngleVelocityTrace = plot(handles.hAxes, 0.6 + 0.09*afVelTheta,'color',afUnSelected,'Linewidth',2);
% % % %

cmenu = getappdata(handles.figure1,'cmenu');

% at the moment, draw all, but if this becomes unreasonable, you should
% only plot the ones inside the current zoom range... but then you need to
% redraw this everytime you scroll to a differnet frame....

aiStart = g_strctBehaviors.m_aiStart(aiSelectedMouseBehaviors);
aiEnd =  g_strctBehaviors.m_aiEnd(aiSelectedMouseBehaviors);

aiSelectedMouseBehaviors = aiSelectedMouseBehaviors(aiStart <= iCurrFrame-iZoomRangeX & aiEnd >= iCurrFrame-iZoomRangeX | ...
    aiStart >= iCurrFrame-iZoomRangeX &  aiStart <= iCurrFrame+iZoomRangeX);
axes(handles.hAxes);

iNumMice = getappdata(handles.figure1,'iNumMice');

a2fColors = fnGetBehaviorColor(g_strctBehaviors.m_aiMouseA(aiSelectedMouseBehaviors),...
    g_strctBehaviors.m_aiMouseB(aiSelectedMouseBehaviors),...
    g_strctBehaviors.m_aiType(aiSelectedMouseBehaviors),iNumMice);

for k=1:length(aiSelectedMouseBehaviors)
    
    g_strctBehaviors.m_ahDrawHandle(aiSelectedMouseBehaviors(k)) = ...
        fnDrawRect([g_strctBehaviors.m_aiStart(aiSelectedMouseBehaviors(k)) ...
        g_strctBehaviors.m_aiEnd(aiSelectedMouseBehaviors(k)) ...
        g_strctBehaviors.m_aiStartY(aiSelectedMouseBehaviors(k)) ...
        g_strctBehaviors.m_aiEndY(aiSelectedMouseBehaviors(k))] ...
        ,a2fColors(:,k),cmenu);
end;

return;

function [a2fColor] = fnGetBehaviorColor(aiMouseA, aiMouseB, aiType,iNumMice)

% fStartY = iType + iMouseB;
% fEndY = fStartY + 0.1;
iNumBehaviors = 7;
a2iJet = jet(iNumMice*iNumMice*iNumBehaviors);
a2fColor = a2iJet(aiMouseA * iNumMice*iNumMice + aiMouseB * iNumMice + aiType,:)';
return;

function fnInvalidate(handles)
global g_strctExperiment
astrctVideoInfo = getappdata(handles.figure1,'astrctVideoInfo');
hImage = getappdata(handles.figure1,'hImage');
hTSImage = getappdata(handles.figure1,'hTSImage');

if isempty(astrctVideoInfo)
    set(hImage,'cdata',zeros(768,1024));
    set(hTSImage,'cdata',zeros(1:20,1:180));
    return;
end;
iCurrFrame = getappdata(handles.figure1,'iCurrFrame');

a2iFramesToSeq = getappdata(handles.figure1,'a2iFramesToSeq');
% Find which sequence iCurrFrame corresponds to...
iSelectedSeq = find(a2iFramesToSeq(:,1) <= iCurrFrame & a2iFramesToSeq(:,2) >= iCurrFrame);
if ~isempty(astrctVideoInfo) && isfield(astrctVideoInfo,'m_strFileName') && ~isempty(astrctVideoInfo(iSelectedSeq).m_strFileName) && ...
    ~isempty(astrctVideoInfo(iSelectedSeq)) && ~isempty(astrctVideoInfo(iSelectedSeq).m_iNumFrames)
    a2iFrame = fnReadFrameFromSeq(astrctVideoInfo(iSelectedSeq), iCurrFrame - a2iFramesToSeq(iSelectedSeq,1) + 1);
    set(hImage,'cdata',a2iFrame);
    set(hTSImage,'cdata',a2iFrame(1:20,1:180));
else
    set(hImage,'cdata',zeros(768,1024));
    set(hTSImage,'cdata',zeros(1:20,1:180));
end;
iCurrMouse = getappdata(handles.figure1,'iCurrMouse');
if ~isempty(g_strctExperiment)
    fnDrawTrackers(handles, iCurrFrame, iCurrMouse);
end;
set(handles.hStatusLine,'string',num2str(iCurrFrame));
return;


function fnClearAnnotation(handles)
global g_strctBehaviors
g_strctBehaviors = [];
fnInvalidateBehaviorList(handles);
return;

function fnClearPositionalInfo(handles)
return;

function hLoadExperiment_Callback(hObject, eventdata, handles)
global g_strctExperiment
strDefaultPath = 'D:\Data\Janelia Farm\Results\MergedExperiments\';
strDefaultVideoPath = 'M:\Data\Movies\Experiment1\';
[strFile,strPath] = uigetfile([strDefaultPath,'*.mat']);
if strFile(1) == 0
    return;
end;
strExpFile = [strPath,strFile];
try
    fprintf('Trying to load experiment. Please wait...');
    g_strctExperiment = load(strExpFile);
    fprintf('Experiment loaded successfuly!\n');
catch
    error('Not enough memory');
end;

setappdata(handles.figure1,'a2iFramesToSeq',g_strctExperiment.a2iFramesToSeq);
% Load video information
% Try to load first video, if not found, ask user for folder
if ~exist([strDefaultVideoPath,g_strctExperiment.acstrSequence{end},'.seq'],'file')
    fprintf('Movie sequences for this experiment were not found in the default folder. Please tell me where they are.\n');
    strMoviePath = uigetdir();
else
    strMoviePath = strDefaultVideoPath;
end;

fprintf('Reading video headers...');
astrctVideoInfo = struct('m_strFileName',[],'m_iWidth',[],'m_iHeight',[],'m_iImageBitDepth',[],'m_iImageBitDepthReal',[],'m_iImageSizeBytes',[],...
    'm_iImageFormat',[],'m_iNumFrames',[],'m_iTrueImageSize',[],'m_fFPS',[],'m_iSeqiVersion',[],'m_aiSeekPos',[],'m_afTimestamp',[]);
for iSeqIter=1:length(g_strctExperiment.acstrSequence)
    if exist([strDefaultVideoPath,g_strctExperiment.acstrSequence{iSeqIter},'.seq'],'file')
        astrctVideoInfo(iSeqIter) = fnReadVideoInfo([strDefaultVideoPath,g_strctExperiment.acstrSequence{iSeqIter},'.seq']);
    else
        fprintf('Could not find video sequence %s\n',g_strctExperiment.acstrSequence{iSeqIter});
    end;
end;
fprintf('Done!\n');
setappdata(handles.figure1,'astrctVideoInfo',astrctVideoInfo);
setappdata(handles.figure1,'acstrVideoFile',g_strctExperiment.acstrSequence);
setappdata(handles.figure1,'iCurrFrame',1);
setappdata(handles.figure1,'iCurrMouse',1);
setappdata(handles.figure1,'iNumFrames', size(g_strctExperiment.a2fX,2));
setappdata(handles.figure1,'iNumMice', size(g_strctExperiment.a2fX,1));

fnClearAnnotation(handles);
fnInvalidate(handles);
fnSetActiveMouse(handles,1);
return;

function fnLoadNewVideoFile(handles,strVideoFile)
if isempty(strVideoFile)
    setappdata(handles.figure1,'a2iFramesToSeq',[0 0]);
    setappdata(handles.figure1,'astrctVideoInfo',[]);
    setappdata(handles.figure1,'acstrVideoFile',[]);
    set(handles.figure1,'Name','');
    fnClearAnnotation(handles);
    fnInvalidate(handles);
    return;
end;


fprintf('Loading video info...');
strctVideoInfo = fnReadVideoInfo(strVideoFile);
fprintf('Done!\n');
a2iFramesToSeq = [1, strctVideoInfo.m_iNumFrames];
setappdata(handles.figure1,'a2iFramesToSeq',a2iFramesToSeq);
setappdata(handles.figure1,'astrctVideoInfo',strctVideoInfo);
setappdata(handles.figure1,'acstrVideoFile',{strVideoFile});
setappdata(handles.figure1,'iCurrFrame',1);
setappdata(handles.figure1,'iNumFrames',strctVideoInfo.m_iNumFrames);

set(handles.figure1,'Name',strVideoFile);

fnClearAnnotation(handles);
fnClearPositionalInfo(handles);
fnInvalidate(handles);
return;

function [afSelected, afUnSelected] = fnGetMiceColors(iMouse)
a2fColorsSelected = [1,0,0;
    0,1,0;
    0,0,1;
    0,1,1; % c
    1,0,1; % m
    1,1,0]; % y
a2fColorsUnSelected = min(1,0.2 + a2fColorsSelected * 0.6);
afSelected = a2fColorsSelected(iMouse,:);
afUnSelected = a2fColorsUnSelected(iMouse,:);
return;

function fnSetActiveMouse(handles,iActiveMouse)
iNumMice = getappdata(handles.figure1,'iNumMice');

ahHandles = [handles.hSelectRedMouse, handles.hSelectGreenMouse, handles.hSelectBlueMouse, handles.hSelectCyanMouse];
setappdata(handles.figure1,'iCurrMouse',iActiveMouse);
for k=1:length(ahHandles)
    if k > iNumMice
        set(ahHandles(k),'enable','off');
        set(ahHandles(k),'BackgroundColor',[0.941176 0.941176 0.941176])
        
    else
        set(ahHandles(k),'enable','on');
    end;
    [afSelected, afUnSelected] = fnGetMiceColors(k);
    if k == iActiveMouse
        set(ahHandles(k),'FontWeight','bold')
        set(ahHandles(k),'BackgroundColor',afSelected);
    else
        set(ahHandles(k),'FontWeight','normal')
        if k <= iNumMice
            set(ahHandles(k),'BackgroundColor',afUnSelected);
        end;
    end;
end;
fnInvalidate(handles);
fnInvalidateAnnotation(handles);
return;

function fnSetNumMice(handles, iNumMice)
setappdata(handles.figure1,'iNumMice',iNumMice);
fnSetActiveMouse(handles,iNumMice);

return;


function fnLoadNewPositionFile(handles,strPositionFile)
fprintf('Loading positional info...');
strctTmp = load(strPositionFile);
fprintf('Done!\n');
if isfield(strctTmp,'strctMovieInfo')
    strVideoFileName = strctTmp.strctMovieInfo.m_strFileName;
elseif isfield(strctTmp,'strMovieFileName')
    strVideoFileName = strctTmp.strMovieFileName;
else
    error('Could not find video file information inside positional file');
end;

if ~exist(strVideoFileName,'file')
    strDefaultPath = 'D:\Data\Janelia Farm\Movies\';
    [strFile,strPath] = uigetfile([strDefaultPath,'*.seq'],'Where is the movie sequence corresponding to this tracking results?');
    if strFile(1) ~= 0
        % Video file is not available....
        strVideoFileName = [strPath,strFile];
        fnLoadNewVideoFile(handles,strVideoFileName);
    else
        % Video file does not exist. Reset video to black
        fnLoadNewVideoFile(handles,[]);
    end;
else
    fnLoadNewVideoFile(handles,strVideoFileName);
end;

global g_strctExperiment
g_strctExperiment.a2fX = single(cat(1,strctTmp.astrctTrackers.m_afX));
g_strctExperiment.a2fY = single(cat(1,strctTmp.astrctTrackers.m_afY));
g_strctExperiment.a2fA = single(cat(1,strctTmp.astrctTrackers.m_afA));
g_strctExperiment.a2fB = single(cat(1,strctTmp.astrctTrackers.m_afB));
g_strctExperiment.a2fTheta = single(cat(1,strctTmp.astrctTrackers.m_afTheta));

g_strctExperiment.afTimeStamp = 0:1/30:(length(strctTmp.astrctTrackers(1).m_afX)-1)*(1/30);

fnSetNumMice(handles, size(g_strctExperiment.a2fX,1));

fnInvalidate(handles);

fnInvalidateAnnotation(handles);
return;

function fnInvalidateAnnotation(handles)
global g_strctBehaviors
if isempty(g_strctBehaviors)
    return;
end;
iCurrMouse = getappdata(handles.figure1,'iCurrMouse');
iCurrFrame = getappdata(handles.figure1,'iCurrFrame');
fnDrawAnnotation(handles,iCurrFrame,iCurrMouse);
return;

% --------------------------------------------------------------------
function hLoadVideo_Callback(hObject, eventdata, handles)
strDefaultPath = 'D:\Data\Janelia Farm\Movies\';
[strFile,strPath] = uigetfile([strDefaultPath,'*.seq']);
if strFile(1) == 0
    return;
end;
strVideoFile = [strPath,strFile];
fnLoadNewVideoFile(handles,strVideoFile);

return;


% --------------------------------------------------------------------
function hLoadMicePosition_Callback(hObject, eventdata, handles)

if ispc
    strDefaultPath ='D:\Data\Janelia Farm\GroundTruth\';
else
    strDefaultPath ='/groups/egnor/mousetrack/';
end;


[strFile,strPath] = uigetfile([strDefaultPath,'*.mat']);
% strFile = 'Sequence.mat';
% strPath = 'C:\Users\Shay\Documents\Data\Janelia Farm\Results\b6_dg_em_090201_first_night_cropped20K\';
% strPath = 'C:\Users\Shay\Documents\Data\Janelia Farm\GroundTruth\';
% strFile = 'GroundTruth00.mat';
if strFile(1) == 0
    return;
end;
strPositionFile = [strPath,strFile];
fnLoadNewPositionFile(handles,strPositionFile);
return;




% --- Executes on button press in hSelectRedMouse.
function hSelectRedMouse_Callback(hObject, eventdata, handles)
fnSetActiveMouse(handles,1);

% --- Executes on button press in hSelectGreenMouse.
function hSelectGreenMouse_Callback(hObject, eventdata, handles)
fnSetActiveMouse(handles,2);

% --- Executes on button press in hSelectBlueMouse.
function hSelectBlueMouse_Callback(hObject, eventdata, handles)
fnSetActiveMouse(handles,3);

% --- Executes on button press in hSelectCyanMouse.
function hSelectCyanMouse_Callback(hObject, eventdata, handles)
fnSetActiveMouse(handles,4);


%% Mouse related events



function abInterval = fnGetIntervals1(handles)
iNumFrames = getappdata(handles.figure1,'iNumFrames');
iCurrMouse = getappdata(handles.figure1,'iCurrMouse');
abInterval = zeros(1,iNumFrames) > 0;
acAnnotation = getappdata(handles.figure1,'acAnnotation');
iStartIndex = 1;
if acAnnotation{iCurrMouse}(iStartIndex).m_iStart < 0
    iStartIndex = 2;
end;

for k=iStartIndex:length(acAnnotation{iCurrMouse})
    abInterval(acAnnotation{iCurrMouse}(k).m_iStart:acAnnotation{iCurrMouse}(k).m_iEnd) = 1;
end;

return;




function fnChangeAnnotationInterval(handles, iIndex, iNewStart, iNewEnd)
global g_strctBehaviors
iNumFrames = getappdata(handles.figure1,'iNumFrames');
if iNewEnd <= iNewStart || iNewStart < 1 || iNewEnd > iNumFrames
    return;
end;

g_strctBehaviors.m_aiStart(iIndex)= round(iNewStart);
g_strctBehaviors.m_aiEnd(iIndex) = round(iNewEnd);
iNewWidth = iNewEnd - iNewStart;
% iStart, 0.2, iWidth, 0.4
set(g_strctBehaviors.m_ahDrawHandle(iIndex),'Position',[iNewStart,0.2,iNewWidth,0.2]);
strDescription = fnGetBehaviorString(iIndex);

Tmp = get(handles.hBehaviorList,'String');
Tmp(iIndex,:) = 0;
Tmp(iIndex,1:length(strDescription)) =  strDescription;
set(handles.hBehaviorList,'String',Tmp,'value',iIndex);

return;

function [iMinLeft, iMaxRight] = fnGetPossibleIntervalChanges(handles, iIndex)
% Find the neighborhing intervals....
global g_strctBehaviors
if isempty(iIndex)
    iMinLeft = [];
    iMaxRight = [];
    return;
end;

iNumFrames = getappdata(handles.figure1,'iNumFrames');
iCurrMouse = getappdata(handles.figure1,'iCurrMouse');

aiRelevantBehaviors = find(g_strctBehaviors.m_aiMouseA == iCurrMouse & g_strctBehaviors.m_aiType == g_strctBehaviors.m_aiType(iIndex));

aiStart = g_strctBehaviors.m_aiStart(aiRelevantBehaviors);
aiEnd = g_strctBehaviors.m_aiEnd(aiRelevantBehaviors);

iMinLeft = aiEnd(find(aiEnd < g_strctBehaviors.m_aiStart(iIndex),1,'last'));
if isempty(iMinLeft)
    iMinLeft = 1;
end;

iMaxRight = aiStart(find(aiStart > g_strctBehaviors.m_aiEnd(iIndex),1,'first'));
if isempty(iMaxRight)
    iMaxRight = iNumFrames;
end;


return;


function fnMouseUp(obj,eventdata,handles)
global g_strctBehaviors

setappdata(handles.figure1,'bMouseDown',0);
strctMouseOp.m_strButton = fnGetClickType(handles.figure1);
strctMouseOp.m_strAction = 'Up';
[strctMouseOp.m_hAxes, strctMouseOp.m_strWindow] = fnGetActiveWindow(handles);
strctMouseOp.m_pt2fPos = fnGetMouseCoordinate(strctMouseOp.m_hAxes);

strctMouseDown = getappdata(handles.figure1,'strctMouseDown');
if ~isempty(strctMouseDown) && strcmpi(strctMouseDown.m_strButton,'right') && strcmpi(strctMouseOp.m_strWindow,'Bottom')
    % Either add new behavior, or change behavior type
    
    
    iIndex = fnGetSelectedInterval(handles,strctMouseDown);
    if isempty(iIndex)
        % add new behavior
        iNumFrames = getappdata(handles.figure1,'iNumFrames');
        iCurrMouse = getappdata(handles.figure1,'iCurrMouse');
        bRightwardDrag = strctMouseOp.m_pt2fPos(1) > strctMouseDown.m_pt2fPos(1);
        
        iStartFrame = min(round(strctMouseDown.m_pt2fPos(1)),round(strctMouseOp.m_pt2fPos(1)));
        iEndFrame = max(round(strctMouseDown.m_pt2fPos(1)),round(strctMouseOp.m_pt2fPos(1)));
        
        if iEndFrame > iStartFrame  && iStartFrame >= 1 && iEndFrame >= 1 && iStartFrame < iNumFrames && iEndFrame <= iNumFrames
            % crop start and end frames to the nearest position, and make sure
            % there are no overlaps!
            aiSelected = find(g_strctBehaviors.m_aiMouseA == iCurrMouse);
            
            if bRightwardDrag
                iNext = find(g_strctBehaviors.m_aiStart(aiSelected) >= iStartFrame,1,'first');
                if ~isempty(iNext)
                    iStartNext = g_strctBehaviors.m_aiStart(aiSelected(iNext));
                    iEndFrame = min(iEndFrame, iStartNext - 1);
                end;
            else
                % leftward drag
                iPrev = find(g_strctBehaviors.m_aiEnd(aiSelected) <= iEndFrame,1,'last');
                
                if ~isempty(iPrev)
                    iEndPrev = g_strctBehaviors.m_aiEnd(aiSelected(iPrev));
                    iStartFrame = max(iStartFrame, iEndPrev+ 1);
                end;
            end;
            fprintf('Adding new behavior to mouse %d between %d - %d\n',iCurrMouse, iStartFrame, iEndFrame);
            fnAddNewBehavior(handles, iStartFrame, iEndFrame, iCurrMouse);
        end;
    else
        
    end;
end;


setappdata(handles.figure1,'strctMouseCurr',strctMouseOp);
setappdata(handles.figure1,'strctMouseUp',strctMouseOp);


return;


function fnMouseScroll(obj,eventdata,handles)
fDelta = eventdata.VerticalScrollCount;
[hAxes,strActiveWindow] = fnGetActiveWindow(handles);
if isempty(hAxes)
    return;
end;

abKeys=zeros(1,255)>0;%fndllKeyscan;

if strcmpi(strActiveWindow,'bottom')
    iZoomRangeX=getappdata(handles.figure1,'iZoomRangeX');
    iCurrFrame = getappdata(handles.figure1,'iCurrFrame');
    iZoomRangeY = getappdata(handles.figure1,'iZoomRangeY');
    iCurrY = getappdata(handles.figure1,'iCurrY');
    afYZoom = min(10,max(0,[iCurrY-iZoomRangeY,iCurrY+iZoomRangeY]));
    
    if ~abKeys(17) % Shift is pressed
        if fDelta < 0
            iZoomRangeX = iZoomRangeX * 1.1;
        else
            iZoomRangeX = iZoomRangeX * 0.9;
        end;
        iZoomRangeX = min(1000000,max(10,iZoomRangeX));
        setappdata(handles.figure1,'iZoomRangeX',iZoomRangeX);
    else
        
        if fDelta < 0
            iZoomRangeY = iZoomRangeY * 1.1;
        else
            iZoomRangeY = iZoomRangeY * 0.9;
        end;
        iZoomRangeY = min(10,max(0.1,iZoomRangeY));
        setappdata(handles.figure1,'iZoomRangeY',iZoomRangeY);
        afYZoom = min(10,max(0,[iCurrY-iZoomRangeY,iCurrY+iZoomRangeY]));
        
    end;
    axis(hAxes,[iCurrFrame-iZoomRangeX iCurrFrame+iZoomRangeX afYZoom]);
    
    fprintf('[%d - %d]\n',iCurrFrame-iZoomRangeX,iCurrFrame+iZoomRangeX);
end;
if strcmpi(strActiveWindow,'Top')
    iCurrFrame = getappdata(handles.figure1,'iCurrFrame');
    iNumFrames = getappdata(handles.figure1,'iNumFrames');
    iCurrFrame = min(iNumFrames,max(1,iCurrFrame + fDelta));
    setappdata(handles.figure1,'iCurrFrame',iCurrFrame);
    fnInvalidate(handles);
end

fnInvalidateAnnotation(handles);


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

function pt2fMouseDownPosition = fnGetMouseCoordinate(hAxes)
pt2fMouseDownPosition = get(hAxes,'CurrentPoint');
if size(pt2fMouseDownPosition,2) ~= 3
    pt2fMouseDownPosition = [-1 -1];
else
    pt2fMouseDownPosition = [pt2fMouseDownPosition(1,1), pt2fMouseDownPosition(1,2)];
end;
return;
%
function [hAxes,strActiveWindow] = fnGetActiveWindow(handles)

if (fnInsideImage(handles,handles.hImageAxes))
    hAxes = handles.hImageAxes;
    strActiveWindow = 'Top';
    return;
end;
if (fnInsideImage(handles,handles.hAxes))
    hAxes = handles.hAxes;
    strActiveWindow = 'Bottom';
    return;
end;
% ahZoomArray = [handles.hZoom1,handles.hZoom2,handles.hZoom3,handles.hZoom4,handles.hZoom5];
% for iZoomIter=1:length(ahZoomArray)
%     if (fnInsideImage(handles,ahZoomArray(iZoomIter)))
%         hAxes = ahZoomArray(iZoomIter);
%         strActiveWindow = ['Zoom',num2str(iZoomIter)];
%         return;
%     end;
% end;
hAxes = [];
strActiveWindow = [];
return;

function fnPrintMouseOp(strctMouseOp)
fprintf('%s %s in %s window, Pos [%.2f %.2f]\n',...
    strctMouseOp.m_strButton, strctMouseOp.m_strAction, ...
    strctMouseOp.m_strWindow,strctMouseOp.m_pt2fPos(1),strctMouseOp.m_pt2fPos(2));
return;
%set(handles.figure1,'Pointer','watch');



function fnMouseDown(obj,eventdata,handles)
strMouseMoveMode = getappdata(handles.figure1,'strMouseMoveMode');
setappdata(handles.figure1,'bMouseDown',1);
strctMouseOp.m_strButton = fnGetClickType(handles.figure1);
strctMouseOp.m_strAction = 'Down';
[strctMouseOp.m_hAxes, strctMouseOp.m_strWindow] = fnGetActiveWindow(handles);
strctMouseOp.m_pt2fPos = fnGetMouseCoordinate(strctMouseOp.m_hAxes);
strctMouseOp.m_strModeWhenDown = strMouseMoveMode;
[strctMouseOp.m_iIndex,strctMouseOp.m_strAction,...
    strctMouseOp.m_iOrigLeft,strctMouseOp.m_iOrigRight] =...
    fnGetSelectedInterval(handles,strctMouseOp);

[strctMouseOp.m_iMinLeft, strctMouseOp.m_iMaxRight] = fnGetPossibleIntervalChanges(handles, strctMouseOp.m_iIndex);

if ~isempty(strctMouseOp.m_iIndex)
    set(handles.hBehaviorList,'value',strctMouseOp.m_iIndex)
end
%fnPrintMouseOp(strctMouseOp);

setappdata(handles.figure1,'strctMouseDown',strctMouseOp);
setappdata(handles.figure1,'strctMouseCurr',strctMouseOp);
%fnHandleMouseDownEvent(strctMouseOp,handles);

return;
function fnMouseMove(obj,eventdata,handles)
bMouseDown = getappdata(handles.figure1,'bMouseDown');
strctMouseOp.m_strButton = fnGetClickType(handles.figure1);
strctMouseOp.m_strAction = 'Move';
[strctMouseOp.m_hAxes, strctMouseOp.m_strWindow] = fnGetActiveWindow(handles);
strctMouseOp.m_pt2fPos = fnGetMouseCoordinate(strctMouseOp.m_hAxes);
strctPrevMouseOp = getappdata(handles.figure1,'strctMouseCurr');
setappdata(handles.figure1,'strctMouseCurr', strctMouseOp);
strctMouseDown = getappdata(handles.figure1,'strctMouseDown');
[iIndex,strAction] = fnGetSelectedInterval(handles,strctMouseOp);

if ~isempty(iIndex)
    if strcmpi(strAction,'LeftDrag')
        set(handles.figure1,'Pointer','left');
    elseif strcmpi(strAction,'RightDrag')
        set(handles.figure1,'Pointer','right');
    else
        set(handles.figure1,'Pointer','fleur');
    end;
    
    % crosshair | {arrow} | watch | topl |
    % topr | botl | botr | circle | cross |
    % fleur | left | right | top | bottom |
    % fullcrosshair | ibeam | customPo
else
    set(handles.figure1,'Pointer','arrow');
end

astrctVideoInfo = getappdata(handles.figure1,'astrctVideoInfo');
if bMouseDown > 0 && ~isempty(strctMouseOp.m_hAxes) && ~isempty(strctMouseDown.m_hAxes) && ...
        strctMouseOp.m_hAxes == strctMouseDown.m_hAxes && ~isempty(astrctVideoInfo)
    fnHandleMouseMoveWhileDown(strctPrevMouseOp, strctMouseOp, handles);
end;
return;



function [iIndex,strAction, iLeft,iRight] = fnGetSelectedInterval(handles,strctMouseDown)
global g_strctBehaviors

strAction = '';
iLeft = [];
iRight = [];
iIndex = [];
iCurrMouse = getappdata(handles.figure1,'iCurrMouse');
if isempty(g_strctBehaviors) || iCurrMouse == 0
    return;
end;
iMouseDownPositionX = strctMouseDown.m_pt2fPos(1);
iMouseDownPositionY = strctMouseDown.m_pt2fPos(2);


% if bUseYConstraint && strctMouseDown.m_pt2fPos(2) > 0.4 || strctMouseDown.m_pt2fPos(2) < 0.2
%     return;
% end;
aiSelectedMouseBehaviors = find(g_strctBehaviors.m_aiMouseA == iCurrMouse);


iFound = find(iMouseDownPositionX >= g_strctBehaviors.m_aiStart(aiSelectedMouseBehaviors) & ...
    (iMouseDownPositionX <= g_strctBehaviors.m_aiEnd(aiSelectedMouseBehaviors)) & ...
    (iMouseDownPositionY >= g_strctBehaviors.m_aiStartY(aiSelectedMouseBehaviors)) & ...
    (iMouseDownPositionY <= g_strctBehaviors.m_aiEndY(aiSelectedMouseBehaviors)));

if ~isempty(iFound)
    iIndex = aiSelectedMouseBehaviors(iFound);
    
    iIntervalLength = g_strctBehaviors.m_aiEnd(iIndex)- g_strctBehaviors.m_aiStart(iIndex);
    fRatio = (iMouseDownPositionX - g_strctBehaviors.m_aiStart(iIndex)) / iIntervalLength;
    if fRatio < 0.1
        strAction = 'LeftDrag';
    elseif fRatio > 0.9
        strAction = 'RightDrag';
    else
        strAction = 'CenterDrag';
    end;
    iLeft =  g_strctBehaviors.m_aiStart(iIndex);
    iRight = g_strctBehaviors.m_aiEnd(iIndex);
    
end;

return;


function fnHandleMouseMoveWhileDown(strctPrevMouseOp, strctMouseOp, handles)
%fnPrintMouseOp(strctMouseOp);
strctMouseDown = getappdata(handles.figure1,'strctMouseDown');

if strcmp(strctMouseOp.m_strButton ,'Right') && isempty(strctMouseDown.m_iIndex)
    % Draw the new interval that is being generated...
end;

if strcmp(strctMouseOp.m_strButton ,'Left')
    dl = strctMouseDown.m_pt2fPos - strctMouseOp.m_pt2fPos;
    iCurrFrame = getappdata(handles.figure1,'iCurrFrame');
    iZoomRangeX  = getappdata(handles.figure1,'iZoomRangeX');
    
    iNumFrames = getappdata(handles.figure1,'iNumFrames');
    if isempty(strctMouseDown.m_iIndex)
        % Pan the entire window
        iCurrFrame = iCurrFrame + dl(1);
        iCurrFrame = round(min(iNumFrames,max(1,iCurrFrame)));
        iZoomRangeY = getappdata(handles.figure1,'iZoomRangeY');
        iCurrY = getappdata(handles.figure1,'iCurrY');
        
        iCurrY = min(10,max(0,iCurrY + iZoomRangeY/5 * dl(2)));
        afYZoom = min(10,max(0,[iCurrY-iZoomRangeY,iCurrY+iZoomRangeY]));
        
        axis(handles.hAxes,[iCurrFrame-iZoomRangeX iCurrFrame+iZoomRangeX afYZoom]);
        hCurrFrameIndicator = getappdata(handles.figure1,'hCurrFrameIndicator');
        if ~isempty(hCurrFrameIndicator)
            set(hCurrFrameIndicator,'xdata',[iCurrFrame iCurrFrame]);
        end;
        setappdata(handles.figure1,'iCurrY',iCurrY);
        setappdata(handles.figure1,'iCurrFrame', iCurrFrame);
        fnInvalidate(handles);
    else
        % Shift the selected interval...
        if strcmpi(strctMouseDown.m_strAction,'LeftDrag')
            iNewLeft = max(strctMouseDown.m_iOrigLeft - dl(1), strctMouseDown.m_iMinLeft);
            iNewRight = strctMouseDown.m_iOrigRight;
            fnChangeAnnotationInterval(handles, strctMouseDown.m_iIndex,iNewLeft, iNewRight);
        elseif strcmpi(strctMouseDown.m_strAction,'RightDrag')
            iNewLeft = strctMouseDown.m_iOrigLeft;
            iNewRight = min(strctMouseDown.m_iOrigRight - dl(1),strctMouseDown.m_iMaxRight);
            fnChangeAnnotationInterval(handles, strctMouseDown.m_iIndex,iNewLeft, iNewRight);
        else
            iNewLeft = strctMouseDown.m_iOrigLeft - dl(1);
            iNewRight = strctMouseDown.m_iOrigRight - dl(1);
            if iNewRight <= strctMouseDown.m_iMaxRight && iNewLeft >= strctMouseDown.m_iMinLeft
                fnChangeAnnotationInterval(handles, strctMouseDown.m_iIndex,iNewLeft, iNewRight);
            end;
        end;
        
    end;
    fnInvalidateAnnotation(handles);
    
end;

return;

function fnAddNewBehavior(handles, iStartFrame, iEndFrame, iCurrMouse)
global g_strctBehaviors
cmenu = getappdata(handles.figure1,'cmenu');
iNumMice = getappdata(handles.figure1,'iNumMice');

iDefaultType = 1;

g_strctBehaviors.m_aiStart =  [iStartFrame; g_strctBehaviors.m_aiStart];
g_strctBehaviors.m_aiEnd =    [iEndFrame; g_strctBehaviors.m_aiEnd ];
g_strctBehaviors.m_aiType =   [iDefaultType; g_strctBehaviors.m_aiType ];
g_strctBehaviors.m_aiMouseA = [iCurrMouse; g_strctBehaviors.m_aiMouseA];
g_strctBehaviors.m_aiMouseB = [0; g_strctBehaviors.m_aiMouseB ];
g_strctBehaviors.m_aiStartY = [iDefaultType ; g_strctBehaviors.m_aiStartY];
g_strctBehaviors.m_aiEndY =   [iDefaultType + 1/(iNumMice+1); g_strctBehaviors.m_aiEndY];

afColors = fnGetBehaviorColor(iCurrMouse, 0, iDefaultType,iNumMice);
hDrawHandle = ...
    fnDrawRect([iStartFrame, iEndFrame, iDefaultType,iDefaultType + 1/(iNumMice+1)],afColors,cmenu);

g_strctBehaviors.m_ahDrawHandle = hDrawHandle;

fnInvalidateAnnotation(handles);

return;


% --------------------------------------------------------------------
function Untitled_2_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function fnSaveAnnotations(handles)
strAnnotationFileName = getappdata(handles.figure1,'strAnnotationFileName');
if ~isempty(strAnnotationFileName)
    fnSaveAnnotationsToFile(handles, strAnnotationFileName)
else
    fnSaveAnnotationAs(handles);
end;

return;


function fnSaveAnnotationsToFile(handles, strFileName)
global g_strctBehaviors g_strctExperiment
strVideoFile = getappdata(handles.figure1,'strVideoFile');
strTrackingResultsFile = getappdata(handles.figure1,'strTrackingResultsFile');
iNumMice = getappdata(handles.figure1,'iNumMice');
fprintf('Saving annotation...');
fStartTime = g_strctExperiment.afTimeStamp(1);
fEndTime = g_strctExperiment.afTimeStamp(end);
save(strFileName,'g_strctBehaviors','strVideoFile','strTrackingResultsFile','iNumMice','fStartTime','fEndTime');
fprintf('Done!\n');
return;

function fnSaveAnnotationAs(handles)
strResultsFolder = getappdata(handles.figure1,'strResultsFolder');
[strFile,strPath] = uiputfile([strResultsFolder,'Annotation.mat']);
if strFile(1) == 0
    return;
end;

strFileName = [strPath,strFile];
fnSaveAnnotationsToFile(handles, strFileName);
return;

% --------------------------------------------------------------------
function hSaveAnnotationAs_Callback(hObject, eventdata, handles)
fnSaveAnnotationAs(handles);
return;

function fnLoadAnnotation(handles, strFullFileName)
global g_strctBehaviors
fprintf('Loading annotation file...');
strctTmp = load(strFullFileName);
fprintf('Done!\n');

g_strctBehaviors = strctTmp.g_strctBehaviors;
if ~isfield(strctTmp,'iNumMice')
    strctTmp.iNumMice = 4;
end;
setappdata(handles.figure1,'strAnnotationFileName',strFullFileName);
setappdata(handles.figure1,'iCurrMouse',1);
setappdata(handles.figure1,'iCurrFrame',1);
setappdata(handles.figure1,'iNumMice',strctTmp.iNumMice );



fnInvalidateBehaviorList(handles);
fnInvalidateAnnotation(handles);

return;

% --------------------------------------------------------------------
function hLoadAnnotation_Callback(hObject, eventdata, handles)
strResultsFolder = getappdata(handles.figure1,'strResultsFolder');
[strFile,strPath] = uigetfile([strResultsFolder,'Annotation.mat']);
if strFile(1) == 0
    return;
end;
strFullFileName = [strPath,strFile];
fnLoadAnnotation(handles, strFullFileName);

%strVideoFile = getappdata(handles.figure1,'strVideoFile');
%strTrackingResultsFile = getappdata(handles.figure1,'strTrackingResultsFile');
%fprintf('Saving annotation...');
%save([strPath,strFile],'acAnnotation','strVideoFile','strTrackingResultsFile');
%fprintf('Done!\n');


% --------------------------------------------------------------------
function hSaveAnnotation_Callback(hObject, eventdata, handles)
fnSaveAnnotations(handles);
return;


% --- Executes on button press in hRunFollowing.
function hRunFollowing_Callback(hObject, eventdata, handles)
global g_strctExperiment g_strctBehaviors
if isempty(g_strctExperiment)
    return;
end;

astrctFollowingBehaviors = struct('m_iStart',[],'m_iEnd',[],...
    'm_iLength',[],'m_strType',[],'m_iType',[],'m_iMouseA',[],'m_iMouseB',[],'m_hDrawHandle',[],'m_fStartTime',[],'m_fEndTime',[]);
iType = fnBehaviorStringToNumber('Following');

iNumMice = size(g_strctExperiment.a2fX,1);
strctFollowingParams = getappdata(handles.figure1,'strctFollowingParams');
hWaitbar = waitbar(0,'Processing...');
for iMouseA = 1:iNumMice
    for iMouseB = 1:iNumMice
        if iMouseA ==iMouseB
            continue;
        else
            waitbar( ((iMouseA-1)*iNumMice + iMouseB)/(iNumMice*iNumMice),hWaitbar);
            drawnow
            
            abDetected = fndllDetectBehavior('Following',...
                g_strctExperiment.a2fX,...
                g_strctExperiment.a2fY,...
                g_strctExperiment.a2fA,...
                g_strctExperiment.a2fB,...
                g_strctExperiment.a2fTheta, iMouseB,iMouseA, strctFollowingParams);
            astrctIntervals = fnDiscardSmallIntervals(fnMergeIntervals(fnGetIntervals(abDetected),strctFollowingParams.m_iMergeIntervalsFrames), strctFollowingParams.m_iDiscardInterval);
            if ~isempty(astrctIntervals)
                for k=1:length(astrctIntervals)
                    astrctIntervals(k).m_strType = 'Following';
                    astrctIntervals(k).m_iType = iType;
                    astrctIntervals(k).m_iMouseA = iMouseA;
                    astrctIntervals(k).m_iMouseB = iMouseB;
                    astrctIntervals(k).m_hDrawHandle = [];
                    astrctIntervals(k).m_fStartTime = g_strctExperiment.afTimeStamp(astrctIntervals(k).m_iStart);
                    astrctIntervals(k).m_fEndTime = g_strctExperiment.afTimeStamp(astrctIntervals(k).m_iEnd);
                end;
                astrctFollowingBehaviors = [astrctFollowingBehaviors, astrctIntervals];
            end;
        end;
    end;
end;
fnUpdateBehaviorVar(astrctFollowingBehaviors, iType);
close(hWaitbar);
fnInvalidateBehaviorList(handles);

return;
% Remove all previous Following behavior

function fnUpdateBehaviorVar(astrctIntervals, iType)
global g_strctBehaviors g_strctExperiment
iNumMice = size(g_strctExperiment.a2fX,1);
if isempty(astrctIntervals(1).m_iStart)
    astrctIntervals = astrctIntervals(2:end);
end;

if ~isempty(g_strctBehaviors)
    aiIndices = find(g_strctBehaviors.m_aiType ~= iType);
    
    g_strctBehaviors.m_aiStart =  [cat(1,astrctIntervals.m_iStart); g_strctBehaviors.m_aiStart(aiIndices)];
    g_strctBehaviors.m_aiEnd =    [cat(1,astrctIntervals.m_iEnd); g_strctBehaviors.m_aiEnd(aiIndices)];
    g_strctBehaviors.m_aiType =   [cat(1,astrctIntervals.m_iType); g_strctBehaviors.m_aiType(aiIndices)];
    g_strctBehaviors.m_aiMouseA = [cat(1,astrctIntervals.m_iMouseA);g_strctBehaviors.m_aiMouseA(aiIndices)];
    g_strctBehaviors.m_aiMouseB = [cat(1,astrctIntervals.m_iMouseB);g_strctBehaviors.m_aiMouseB(aiIndices)];
    g_strctBehaviors.m_aiStartY = [g_strctBehaviors.m_aiType + g_strctBehaviors.m_aiMouseB / (iNumMice+1); g_strctBehaviors.m_aiStartY(aiIndices)];
    g_strctBehaviors.m_aiEndY =   [g_strctBehaviors.m_aiStartY + 1/(iNumMice+1); g_strctBehaviors.m_aiEndY(aiIndices)];
    g_strctBehaviors.m_afStartTime = [g_strctExperiment.afTimeStamp(cat(1,astrctIntervals.m_iStart)),g_strctBehaviors.m_afStartTime];
    g_strctBehaviors.m_afEndTime = [g_strctExperiment.afTimeStamp(cat(1,astrctIntervals.m_iEnd)),g_strctBehaviors.m_afEndTime];
    g_strctBehaviors.m_ahDrawHandle = [zeros(1, length(astrctIntervals)), g_strctBehaviors.m_ahDrawHandle(aiIndices)];
    
else
    g_strctBehaviors.m_aiStart = cat(1,astrctIntervals.m_iStart);
    g_strctBehaviors.m_aiEnd = cat(1,astrctIntervals.m_iEnd);
    g_strctBehaviors.m_aiType = cat(1,astrctIntervals.m_iType);
    g_strctBehaviors.m_aiMouseA = cat(1,astrctIntervals.m_iMouseA);
    g_strctBehaviors.m_aiMouseB = cat(1,astrctIntervals.m_iMouseB);
    g_strctBehaviors.m_aiStartY = g_strctBehaviors.m_aiType + g_strctBehaviors.m_aiMouseB / (iNumMice+1);
    g_strctBehaviors.m_aiEndY = g_strctBehaviors.m_aiStartY + 1/(iNumMice+1);
    g_strctBehaviors.m_afStartTime = g_strctExperiment.afTimeStamp(cat(1,astrctIntervals.m_iStart));
    g_strctBehaviors.m_afEndTime = g_strctExperiment.afTimeStamp(cat(1,astrctIntervals.m_iEnd));
    g_strctBehaviors.m_ahDrawHandle = zeros(1, length(g_strctBehaviors.m_aiStart));
end;
return;

function fnReorderBehaviors(aiIndices)
global g_strctBehaviors
if ~isempty(g_strctBehaviors)
    g_strctBehaviors.m_aiStart =  g_strctBehaviors.m_aiStart(aiIndices);
    g_strctBehaviors.m_aiEnd =    g_strctBehaviors.m_aiEnd(aiIndices);
    g_strctBehaviors.m_aiType =   g_strctBehaviors.m_aiType(aiIndices);
    g_strctBehaviors.m_aiMouseA = g_strctBehaviors.m_aiMouseA(aiIndices);
    g_strctBehaviors.m_aiMouseB = g_strctBehaviors.m_aiMouseB(aiIndices);
    g_strctBehaviors.m_aiStartY = g_strctBehaviors.m_aiStartY(aiIndices);
    g_strctBehaviors.m_aiEndY =   g_strctBehaviors.m_aiEndY(aiIndices);
    g_strctBehaviors.m_afStartTime = g_strctBehaviors.m_afStartTime(aiIndices);
    g_strctBehaviors.m_afEndTime = g_strctBehaviors.m_afEndTime(aiIndices);
    g_strctBehaviors.m_ahDrawHandle = g_strctBehaviors.m_ahDrawHandle(aiIndices);
end;

return;


% Following
function hFollowVel_Callback(hObject, eventdata, handles)
strctFollowingParams = getappdata(handles.figure1,'strctFollowingParams');
strctFollowingParams.m_fVelocityThresholdPix = str2num(get(hObject,'String'));
setappdata(handles.figure1,'strctFollowingParams',strctFollowingParams);
return;

function hFollowVel_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function hFollowSameOri_Callback(hObject, eventdata, handles)
strctFollowingParams = getappdata(handles.figure1,'strctFollowingParams');
strctFollowingParams.m_fSameOrientationAngleThresDeg = str2num(get(hObject,'String'));
setappdata(handles.figure1,'strctFollowingParams',strctFollowingParams);
return;

function hFollowSameOri_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function hFollowMerge_Callback(hObject, eventdata, handles)
strctFollowingParams = getappdata(handles.figure1,'strctFollowingParams');
strctFollowingParams.m_iMergeIntervalsFrames = str2num(get(hObject,'String'));
setappdata(handles.figure1,'strctFollowingParams',strctFollowingParams);
return;

function hFollowMerge_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function hFollowDist_Callback(hObject, eventdata, handles)
strctFollowingParams = getappdata(handles.figure1,'strctFollowingParams');
strctFollowingParams.m_fDistanceThresholdPix = str2num(get(hObject,'String'));
setappdata(handles.figure1,'strctFollowingParams',strctFollowingParams);
return;

function hFollowDist_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function slider1_Callback(hObject, eventdata, handles)
fValue = get(hObject,'value');
setappdata(handles.figure1,'iCurrY',fValue);
fnInvalidateAnnotation(handles);
return;

function slider1_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function hButtSniffVel_Callback(hObject, eventdata, handles)
strctButtSniffParams = getappdata(handles.figure1,'strctButtSniffParams');
strctButtSniffParams.m_fVelocityThresholdPix = str2num(get(hObject,'String'));
setappdata(handles.figure1,'strctButtSniffParams',strctButtSniffParams);
return;

% --- Executes during object creation, after setting all properties.
function hButtSniffVel_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

return;


function hButtSniffHeadDist_Callback(hObject, eventdata, handles)
strctButtSniffParams = getappdata(handles.figure1,'strctButtSniffParams');
strctButtSniffParams.m_fHeadToButtDistPix = str2num(get(hObject,'String'));
setappdata(handles.figure1,'strctButtSniffParams',strctButtSniffParams);
return;

function hButtSniffHeadDist_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hButtSniffAwayMult_Callback(hObject, eventdata, handles)
strctButtSniffParams = getappdata(handles.figure1,'strctButtSniffParams');
strctButtSniffParams.m_fBodiesAwayMult = str2num(get(hObject,'String'));
setappdata(handles.figure1,'strctButtSniffParams',strctButtSniffParams);
return;


function hButtSniffAwayMult_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function hButtSniffMerge_Callback(hObject, eventdata, handles)
strctButtSniffParams = getappdata(handles.figure1,'strctButtSniffParams');
strctButtSniffParams.m_iMergeIntervalsFrames = str2num(get(hObject,'String'));
setappdata(handles.figure1,'strctButtSniffParams',strctButtSniffParams);
return;


% --- Executes during object creation, after setting all properties.
function hButtSniffMerge_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in hRunHeadSniffing.
function hRunHeadSniffing_Callback(hObject, eventdata, handles)
global g_strctExperiment
if isempty(g_strctExperiment)
    return;
end;

astrctHeadSniffBehaviors = struct('m_iStart',[],'m_iEnd',[],...
    'm_iLength',[],'m_strType',[],'m_iType',[],'m_iMouseA',[],'m_iMouseB',[],'m_hDrawHandle',[],'m_fStartTime',[],'m_fEndTime',[]);

iType = fnBehaviorStringToNumber('HeadSniff');

iNumMice = size(g_strctExperiment.a2fX,1);
strctHeadSniffParams = getappdata(handles.figure1,'strctHeadSniffParams');
hWaitbar = waitbar(0,'Processing...');

for iMouseA = 1:iNumMice
    for iMouseB = 1:iNumMice
        if iMouseA ==iMouseB
            continue;
        else
            waitbar( ((iMouseA-1)*iNumMice + iMouseB)/(iNumMice*iNumMice),hWaitbar);
            drawnow
            
            abDetected = fndllDetectBehavior('Kiss',...
                g_strctExperiment.a2fX,...
                g_strctExperiment.a2fY,...
                g_strctExperiment.a2fA,...
                g_strctExperiment.a2fB,...
                g_strctExperiment.a2fTheta, iMouseB,iMouseA, strctHeadSniffParams);
            astrctIntervals = fnDiscardSmallIntervals(fnMergeIntervals(fnGetIntervals(abDetected),strctHeadSniffParams.m_iMergeIntervalsFrames), strctHeadSniffParams.m_iDiscardInterval);
            if ~isempty(astrctIntervals)
                
                for k=1:length(astrctIntervals)
                    astrctIntervals(k).m_strType = 'HeadSniff';
                    astrctIntervals(k).m_iType = iType;
                    astrctIntervals(k).m_iMouseA = iMouseA;
                    astrctIntervals(k).m_iMouseB = iMouseB;
                    astrctIntervals(k).m_hDrawHandle = [];
                    astrctIntervals(k).m_fStartTime = g_strctExperiment.afTimeStamp(astrctIntervals(k).m_iStart);
                    astrctIntervals(k).m_fEndTime = g_strctExperiment.afTimeStamp(astrctIntervals(k).m_iEnd);
                    
                end;
                astrctHeadSniffBehaviors = [astrctHeadSniffBehaviors, astrctIntervals];
            end;
        end;
    end;
end;

% Remove all previous Following behavior
fnUpdateBehaviorVar(astrctHeadSniffBehaviors, iType);
close(hWaitbar);
fnInvalidateBehaviorList(handles);
return;


function hHeadSniffVel_Callback(hObject, eventdata, handles)
strctHeadSniffParams = getappdata(handles.figure1,'strctHeadSniffParams');
strctHeadSniffParams.m_fVelocityThresholdPix = str2num(get(hObject,'String'));
setappdata(handles.figure1,'strctButtSniffParams',strctHeadSniffParams);
return;

function hHeadSniffVel_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function hHeadSniffHeadDist_Callback(hObject, eventdata, handles)
strctHeadSniffParams = getappdata(handles.figure1,'strctHeadSniffParams');
strctHeadSniffParams.m_fHeadToHeadDistPix = str2num(get(hObject,'String'));
setappdata(handles.figure1,'strctButtSniffParams',strctHeadSniffParams);
return;

function hHeadSniffHeadDist_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function hHeadSniffAwayMult_Callback(hObject, eventdata, handles)
strctHeadSniffParams = getappdata(handles.figure1,'strctHeadSniffParams');
strctHeadSniffParams.m_fBodiesAwayMult= str2num(get(hObject,'String'));
setappdata(handles.figure1,'strctButtSniffParams',strctHeadSniffParams);
return;


function hHeadSniffAwayMult_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function hHeadSniffMerge_Callback(hObject, eventdata, handles)
strctHeadSniffParams = getappdata(handles.figure1,'strctHeadSniffParams');
strctHeadSniffParams.m_iMergeIntervalsFrames= str2num(get(hObject,'String'));
setappdata(handles.figure1,'strctButtSniffParams',strctHeadSniffParams);
return;

function hHeadSniffMerge_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in hRunCuddling.
function hRunCuddling_Callback(hObject, eventdata, handles)
% hObject    handle to hRunCuddling (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function hCuddlingVel_Callback(hObject, eventdata, handles)
% hObject    handle to hCuddlingVel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hCuddlingVel as text
%        str2double(get(hObject,'String')) returns contents of hCuddlingVel as a double


% --- Executes during object creation, after setting all properties.
function hCuddlingVel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hCuddlingVel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit14_Callback(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit14 as text
%        str2double(get(hObject,'String')) returns contents of edit14 as a double


% --- Executes during object creation, after setting all properties.
function edit14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hCuddlingLengthSec_Callback(hObject, eventdata, handles)
% hObject    handle to hCuddlingLengthSec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hCuddlingLengthSec as text
%        str2double(get(hObject,'String')) returns contents of hCuddlingLengthSec as a double


% --- Executes during object creation, after setting all properties.
function hCuddlingLengthSec_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hCuddlingLengthSec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hCuddlingMerge_Callback(hObject, eventdata, handles)
% hObject    handle to hCuddlingMerge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hCuddlingMerge as text
%        str2double(get(hObject,'String')) returns contents of hCuddlingMerge as a double


% --- Executes during object creation, after setting all properties.
function hCuddlingMerge_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hCuddlingMerge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in hRunChasing.
function hRunChasing_Callback(hObject, eventdata, handles)
% hObject    handle to hRunChasing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function hChasingVel_Callback(hObject, eventdata, handles)
% hObject    handle to hChasingVel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hChasingVel as text
%        str2double(get(hObject,'String')) returns contents of hChasingVel as a double


% --- Executes during object creation, after setting all properties.
function hChasingVel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hChasingVel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hChasingSameOri_Callback(hObject, eventdata, handles)
% hObject    handle to hChasingSameOri (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hChasingSameOri as text
%        str2double(get(hObject,'String')) returns contents of hChasingSameOri as a double


% --- Executes during object creation, after setting all properties.
function hChasingSameOri_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hChasingSameOri (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hChasingDist_Callback(hObject, eventdata, handles)
% hObject    handle to hChasingDist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hChasingDist as text
%        str2double(get(hObject,'String')) returns contents of hChasingDist as a double


% --- Executes during object creation, after setting all properties.
function hChasingDist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hChasingDist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hChasingMerge_Callback(hObject, eventdata, handles)
% hObject    handle to hChasingMerge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hChasingMerge as text
%        str2double(get(hObject,'String')) returns contents of hChasingMerge as a double


% --- Executes during object creation, after setting all properties.
function hChasingMerge_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hChasingMerge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in hRunApproach.
function hRunApproach_Callback(hObject, eventdata, handles)
% hObject    handle to hRunApproach (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function hApproachVel_Callback(hObject, eventdata, handles)
% hObject    handle to hApproachVel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hApproachVel as text
%        str2double(get(hObject,'String')) returns contents of hApproachVel as a double


% --- Executes during object creation, after setting all properties.
function hApproachVel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hApproachVel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit18_Callback(hObject, eventdata, handles)
% hObject    handle to edit18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit18 as text
%        str2double(get(hObject,'String')) returns contents of edit18 as a double


% --- Executes during object creation, after setting all properties.
function edit18_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit19_Callback(hObject, eventdata, handles)
% hObject    handle to edit19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit19 as text
%        str2double(get(hObject,'String')) returns contents of edit19 as a double


% --- Executes during object creation, after setting all properties.
function edit19_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton13.
function pushbutton13_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit20_Callback(hObject, eventdata, handles)
% hObject    handle to edit20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit20 as text
%        str2double(get(hObject,'String')) returns contents of edit20 as a double


% --- Executes during object creation, after setting all properties.
function edit20_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit21_Callback(hObject, eventdata, handles)
% hObject    handle to edit21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit21 as text
%        str2double(get(hObject,'String')) returns contents of edit21 as a double


% --- Executes during object creation, after setting all properties.
function edit21_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit22_Callback(hObject, eventdata, handles)
% hObject    handle to edit22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit22 as text
%        str2double(get(hObject,'String')) returns contents of edit22 as a double


% --- Executes during object creation, after setting all properties.
function edit22_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit23_Callback(hObject, eventdata, handles)
% hObject    handle to edit23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit23 as text
%        str2double(get(hObject,'String')) returns contents of edit23 as a double


% --- Executes during object creation, after setting all properties.
function edit23_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function Untitled_3_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function hBehaviorList_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function hRunButtSniffing_Callback(hObject, eventdata, handles)
global g_strctExperiment
if isempty(g_strctExperiment)
    return;
end;
astrctButtSniffBehaviors = struct('m_iStart',[],'m_iEnd',[],...
    'm_iLength',[],'m_strType',[],'m_iType',[],'m_iMouseA',[],'m_iMouseB',[],'m_hDrawHandle',[],'m_fStartTime',[],'m_fEndTime',[]);

iType = fnBehaviorStringToNumber('ButtSniff');

iNumMice = size(g_strctExperiment.a2fX,1);
strctButtSniffParams = getappdata(handles.figure1,'strctButtSniffParams');
hWaitbar = waitbar(0,'Processing...');

for iMouseA = 1:iNumMice
    for iMouseB = 1:iNumMice
        if iMouseA ==iMouseB
            continue;
        else
            waitbar( ((iMouseA-1)*iNumMice + iMouseB)/(iNumMice*iNumMice),hWaitbar);
            drawnow
            
            abDetected = fndllDetectBehavior('SniffButt',...
                g_strctExperiment.a2fX,...
                g_strctExperiment.a2fY,...
                g_strctExperiment.a2fA,...
                g_strctExperiment.a2fB,...
                g_strctExperiment.a2fTheta, iMouseB,iMouseA, strctButtSniffParams);
            astrctIntervals = fnDiscardSmallIntervals(fnMergeIntervals(fnGetIntervals(abDetected),strctButtSniffParams.m_iMergeIntervalsFrames), strctButtSniffParams.m_iDiscardInterval);
            if ~isempty(astrctIntervals)
                
                for k=1:length(astrctIntervals)
                    astrctIntervals(k).m_strType = 'ButtSniff';
                    astrctIntervals(k).m_iType = iType;
                    astrctIntervals(k).m_iMouseA = iMouseA;
                    astrctIntervals(k).m_iMouseB = iMouseB;
                    astrctIntervals(k).m_hDrawHandle = [];
                    astrctIntervals(k).m_fStartTime = g_strctExperiment.afTimeStamp(astrctIntervals(k).m_iStart);
                    astrctIntervals(k).m_fEndTime = g_strctExperiment.afTimeStamp(astrctIntervals(k).m_iEnd);
                    
                end;
                astrctButtSniffBehaviors = [astrctButtSniffBehaviors, astrctIntervals];
            end;
        end;
    end;
end;

% Remove all previous Following behavior
fnUpdateBehaviorVar(astrctButtSniffBehaviors, iType);
close(hWaitbar);
fnInvalidateBehaviorList(handles);

return;

function fnInvalidateBehaviorList(handles)
global g_strctBehaviors
if isempty(g_strctBehaviors)
    set(handles.hBehaviorList,'string','');
    return;
end;

iNumBehaviors = length(g_strctBehaviors.m_aiStart);
astrOptions = zeros(iNumBehaviors,50);
for k=1:iNumBehaviors
    strDescription = fnGetBehaviorString(k);
    astrOptions(k,1:length(strDescription)) = strDescription;
end;
set(handles.hBehaviorList,'string',char(astrOptions)    );
return;

function strDescription = fnGetBehaviorString(iIndex)
global g_strctBehaviors g_strctConst
switch g_strctBehaviors.m_aiType(iIndex)
    case g_strctConst.m_iFollowing
        strDescription = [fnNumberToColor(g_strctBehaviors.m_aiMouseA(iIndex)),' ',...
            'Following',' ',fnNumberToColor(g_strctBehaviors.m_aiMouseB(iIndex)),' [',...
            num2str(g_strctBehaviors.m_aiStart(iIndex)),'-',num2str(g_strctBehaviors.m_aiEnd(iIndex)),']'];
    case g_strctConst.m_iButtSniff
        strDescription = [fnNumberToColor(g_strctBehaviors.m_aiMouseA(iIndex)),' ',...
            'Butt sniff',' ',fnNumberToColor(g_strctBehaviors.m_aiMouseB(iIndex)),' [',...
            num2str(g_strctBehaviors.m_aiStart(iIndex)),'-',num2str(g_strctBehaviors.m_aiEnd(iIndex)),']'];
    case g_strctConst.m_iHeadSniff
        strDescription = [fnNumberToColor(g_strctBehaviors.m_aiMouseA(iIndex)),' ',...
            'Head sniff',' ',fnNumberToColor(g_strctBehaviors.m_aiMouseB(iIndex)),' [',...
            num2str(g_strctBehaviors.m_aiStart(iIndex)),'-',num2str(g_strctBehaviors.m_aiEnd(iIndex)),']'];
        
end;
return;

function strColor = fnNumberToColor(iNumber)
acstrColor = {'Red','Green','Blue','Cyan','Yellow','Magenta'};
strColor = acstrColor{iNumber};
return;

function fnReorderBehaviorList(handles,iType)
global g_strctBehaviors
if iType == 0
    [afDummy, aiSortIndex] = sort(g_strctBehaviors.m_aiStart,'ascend');
else
    [afDummy, aiSortIndex] = sort(g_strctBehaviors.m_aiType == iType,'descend');
end;
fnReorderBehaviors(aiSortIndex);
fnInvalidateBehaviorList(handles);
return;

function hSortPanel_SelectionChangeFcn(hObject, eventdata, handles)
strSortOption = get(hObject,'String');
switch  strSortOption
    case 'Frames'
        iType = 0;
    otherwise
        iType = fnBehaviorStringToNumber(strSortOption);
end;
fnReorderBehaviorList(handles, iType);
return;

function iNumber = fnBehaviorStringToNumber(strType)
switch strType
    case 'Following'
        iNumber = 1;
    case 'ButtSniff'
        iNumber = 2;
    case 'Butt Sniff'
        iNumber = 2;
    case 'HeadSniff'
        iNumber = 3;
    case 'Head Sniff'
        iNumber = 3;
    case 'Chasing'
        iNumber = 4;
    case 'Cuddling'
        iNumber = 5;
    case 'Approach'
        iNumber = 6;
end;
return;

function hBehaviorList_Callback(hObject, eventdata, handles)
% user pressed on a specific activit for a specific mouse
% Go to the behabvior start frame
% select the mouse that we are talking about
% play the video sequence for that behavior?
iSelectedBehavior = get(hObject,'value');
fnSelectNewBehavior(handles, iSelectedBehavior);
return;

function fnSelectNewBehavior(handles, iSelectedBehavior)
global g_strctBehaviors
iCurrFrame = g_strctBehaviors.m_aiStart(iSelectedBehavior);
iCurrMouse = g_strctBehaviors.m_aiMouseA(iSelectedBehavior);
setappdata(handles.figure1,'iCurrFrame',iCurrFrame);
iZoomRangeX = g_strctBehaviors.m_aiEnd(iSelectedBehavior)-g_strctBehaviors.m_aiStart(iSelectedBehavior);
setappdata(handles.figure1,'iZoomRangeX',iZoomRangeX);
iCurrY = (g_strctBehaviors.m_aiStartY(iSelectedBehavior) + g_strctBehaviors.m_aiEndY(iSelectedBehavior) )/2;
iNumMice = 4;
iZoomRangeY = 1/(iNumMice+1);
setappdata(handles.figure1,'iZoomRangeY',iZoomRangeY);
setappdata(handles.figure1,'iCurrY',iCurrY);
afYZoom = min(10,max(0,[iCurrY-iZoomRangeY,iCurrY+iZoomRangeY]));
axis(handles.hAxes,[iCurrFrame-iZoomRangeX iCurrFrame+iZoomRangeX afYZoom]);
hCurrFrameIndicator = getappdata(handles.figure1,'hCurrFrameIndicator');
if ~isempty(hCurrFrameIndicator)
    set(hCurrFrameIndicator,'xdata',[iCurrFrame iCurrFrame]);
end;
fnSetActiveMouse(handles,iCurrMouse);
fnPlaySequence(handles,iCurrFrame, g_strctBehaviors.m_aiEnd(iSelectedBehavior));
return;

function fnPlaySequence(handles,iStart,iEnd)
for iFrame=iStart:iEnd
    A = find(fndllkeyscan());
    if ~isempty(A)
        break;
    end
    setappdata(handles.figure1,'iCurrFrame',iFrame);
    fnInvalidate(handles);
    fnInvalidateAnnotation(handles);
    drawnow
    drawnow update
    
end;


function hNextAny_Callback(hObject, eventdata, handles)
global g_strctBehaviors
iCurrMouse = getappdata(handles.figure1,'iCurrMouse');
iCurrFrame = getappdata(handles.figure1,'iCurrFrame');
aiRelevantBehaviors = find(g_strctBehaviors.m_aiMouseA == iCurrMouse);
if ~isempty(aiRelevantBehaviors)
    aiStart = g_strctBehaviors.m_aiStart(aiRelevantBehaviors);
    iNext = find(aiStart > iCurrFrame,1,'first');
    if ~isempty(iNext)
        iSelectedBehavior = aiRelevantBehaviors(iNext);
        set(handles.hBehaviorList,'value',iSelectedBehavior);
        fnSelectNewBehavior(handles, iSelectedBehavior);
    else
        iSelectedBehavior = aiRelevantBehaviors(1);
        set(handles.hBehaviorList,'value',iSelectedBehavior);
        fnSelectNewBehavior(handles, iSelectedBehavior);
    end;
end;

return;




% --------------------------------------------------------------------
function hPlotStatistics_Callback(hObject, eventdata, handles)
global g_strctBehaviors g_strctExperiment

% Plot behavior as a function of time....
fStartTime = g_strctExperiment.afTimeStamp(1);
fEndTime = g_strctExperiment.afTimeStamp(end);

iNumHours = ceil((fEndTime-fStartTime)/3600);
iNumDays = ceil(iNumHours/ 24);
iNumHoursExt = iNumDays*24;

%%
iBehaviorType =1;

figure(2);
clf;
iNumMice = 4;
for iMouseA=1:iNumMice
    aiSelectedBehaviors = find(g_strctBehaviors.m_aiMouseA == iMouseA & g_strctBehaviors.m_aiType == iBehaviorType);
    
    afTimeBins = 0:3600:iNumHoursExt*3600; % divide time into hours.
    afHours = afTimeBins/3600;
    afTimeCount = fndllIntervalHist(g_strctBehaviors.m_afStartTime(aiSelectedBehaviors) - fStartTime,...
        g_strctBehaviors.m_afEndTime(aiSelectedBehaviors) - fStartTime,afTimeBins);
    
    h=subplot(iNumMice,1,iMouseA);
    plot(afHours(1:end-1),afTimeCount/60,'linewidth',2);
    hold on;
    fMax = max(afTimeCount/60);
    for iDayIter=1:iNumDays
        plot([(iDayIter-1)*24 (iDayIter-1)*24],[0 fMax],'g--')
        text((iDayIter-1)*24 + 12, 1.1*fMax, sprintf('Day %d',iDayIter));
    end
    if iMouseA == iNumMice
        xlabel('Hours');
    end;
    ylabel('# min ');
    axis([0 iNumHoursExt 0 fMax*1.2])
    set(h,'XTick',[0:6:iNumHoursExt])
    title(sprintf('Mouse %d',iMouseA));
end;
% set(h,'XTickLabel',[0:6:18])


% iSelectedBehavior = get(handles.hBehaviorList,'value');
% aiFrames=g_strctBehaviors.m_aiStart(iSelectedBehavior):g_strctBehaviors.m_aiEnd(iSelectedBehavior);
% iMouseA = g_strctBehaviors.m_aiMouseA(iSelectedBehavior);
% iMouseB = g_strctBehaviors.m_aiMouseB(iSelectedBehavior);
% afVelA = sqrt(diff(g_strctExperiment.a2fX(iMouseA,aiFrames)).^2+diff( g_strctExperiment.a2fY(iMouseA,aiFrames)).^2);
% afVelB = sqrt(diff(g_strctExperiment.a2fX(iMouseB,aiFrames)).^2+diff( g_strctExperiment.a2fY(iMouseB,aiFrames)).^2)
%
% afDist>g_strctExperiment.a2fB(iMouseA,aiFrames)+g_strctExperiment.a2fB(iMouseB,aiFrames)
% afDist = sqrt((g_strctExperiment.a2fX(iMouseA,aiFrames)-g_strctExperiment.a2fX(iMouseB,aiFrames)).^2 + ...
%          (g_strctExperiment.a2fY(iMouseA,aiFrames)-g_strctExperiment.a2fY(iMouseB,aiFrames)).^2 )
