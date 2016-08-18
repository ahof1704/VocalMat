function varargout = NewAnnotationGUI(varargin)
% NEWANNOTATIONGUI M-file for NewAnnotationGUI.fig
%      NEWANNOTATIONGUI, by itself, creates a new NEWANNOTATIONGUI or raises the existing
%      singleton*.
%
%      H = NEWANNOTATIONGUI returns the handle to a new NEWANNOTATIONGUI or the handle to
%      the existing singleton*.
%
%      NEWANNOTATIONGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NEWANNOTATIONGUI.M with the given input arguments.
%
%      NEWANNOTATIONGUI('Property','Value',...) creates a new NEWANNOTATIONGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before NewAnnotationGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to NewAnnotationGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help NewAnnotationGUI

% Last Modified by GUIDE v2.5 26-Jul-2010 00:11:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @NewAnnotationGUI_OpeningFcn, ...
    'gui_OutputFcn',  @NewAnnotationGUI_OutputFcn, ...
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
bDataChanged = getappdata(handles.figure1,'bDataChanged');
if bDataChanged
    selection = questdlg('Save annotation file and quit?',...
        'Warning',...
        'Yes','No, Just Exit','Cancel','Yes');
    switch selection,
        case 'Yes',
            fnSaveAnnotations(handles)
            delete(gcf)
            clear global g_strctExperiment
        case 'No, Just Exit'
            clear global g_strctExperiment
            delete(gcf)
            return
        case 'Cancel'
            return;
    end
else
%    clear global
clear global g_strctExperiment
    delete(gcf)
end
return;


%AllBehaviorList

% --- Executes just before NewAnnotationGUI is made visible.
function NewAnnotationGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to NewAnnotationGUI (see VARARGIN)

% Choose default command line output for NewAnnotationGUI
%clear global
global g_strctExperiment g_strMouseStuffRootDirName;

handles.output = hObject;
% fnSetDefaultDetectParams(handles);
configFileName=fullfile(g_strMouseStuffRootDirName,'Config','Annotation.xml');
strctConfig = fnLoadAnnotationXMLConfig(configFileName);
setappdata(handles.figure1,'strctConfig',strctConfig);

iBehaviorsNum = length(strctConfig.m_acBehaviors);
acBehaviorTypes = cell(iBehaviorsNum+1,1);
acBehaviorTypes{1} = 'All';
for i=1:iBehaviorsNum
    acBehaviorTypes{i+1}=strctConfig.m_acBehaviors{i}.m_strName;
end
set(handles.hPopBehaviorFilter, 'String', acBehaviorTypes);

set(handles.figure1,'CloseRequestFcn',{@my_closereq,handles});
% search for "final" result file
strMovieFileName = varargin{1};
strResultsFolder = varargin{2};
% Update handles structure

setappdata(handles.figure1,'strResultsFolder',strResultsFolder);
setappdata(handles.figure1,'strMovieFileName',strMovieFileName);
setappdata(handles.figure1,'bDataChanged',false);

strctIntervalListboxConfig = struct('iSelectedMouse', 0,  'iOtherMouse', 0,  'sBehaviorType', '',  'bSortLength', false);
setappdata(handles.figure1, 'strctIntervalListboxConfig', strctIntervalListboxConfig);
set(handles.hSortStart, 'Value', 1);
set(handles.hSortLength, 'Value', 0);

fnFillClassifierListbox(strctConfig.m_strctDirectories.m_strBehaviorClassifiersFolder, handles);

fnLoadNewVideoFile(handles, strMovieFileName);
fnFirstInvalidate(handles);

guidata(hObject, handles);

load './Config/globalBCparams.mat';
clear globalBCparams;
return;

function [iOp, bAntiOp] = getActionIndex(acBehaveNames, sAction)
%
iOp =  find(ismember(acBehaveNames, sAction));
if isempty(iOp)
    sAction(sAction=='_') = ' ';
    iOp =  find(ismember(acBehaveNames, sAction));
end
if iOp > length(acBehaveNames)/2
    iOp = iOp -length(acBehaveNames)/2;
    bAntiOp = true;
else
    bAntiOp = false;
end
assert(~isempty(iOp), 'Action is not included in acBehaveNames');


function fnInvalidate(handles)
global g_strctExperiment
astrctVideoInfo = getappdata(handles.figure1,'astrctVideoInfo');
hImage = getappdata(handles.figure1,'hImage');
iCurrFrame = getappdata(handles.figure1,'iCurrFrame');
set(handles.uipanel21,'Title',num2str(iCurrFrame));

a2iFramesToSeq = getappdata(handles.figure1,'a2iFramesToSeq');
% Find which sequence iCurrFrame corresponds to...
iSelectedSeq = find(a2iFramesToSeq(:,1) <= iCurrFrame & a2iFramesToSeq(:,2) >= iCurrFrame);


if ~isempty(astrctVideoInfo) && isfield(astrctVideoInfo,'m_strFileName') && ~isempty(astrctVideoInfo(iSelectedSeq).m_strFileName) && ...
    ~isempty(astrctVideoInfo(iSelectedSeq)) && ~isempty(astrctVideoInfo(iSelectedSeq).m_iNumFrames)
    a2iFrame = fnReadFrameFromSeq(astrctVideoInfo(iSelectedSeq), iCurrFrame - a2iFramesToSeq(iSelectedSeq,1) + 1);
else
   a2iFrame = zeros(768,1024);
end;


if isempty(hImage)
    hImage = image([], [], a2iFrame, 'BusyAction', 'cancel', 'Parent', handles.hImageAxes, 'Interruptible', 'off','CDataMapping','scaled');
    colormap gray
    setappdata(handles.figure1,'hImage',hImage);
    axis(handles.hImageAxes,'off')
    hold(handles.hImageAxes,'on')
%    axis(handles.hImageAxes,[170 804 21 656])
else
    set(hImage,'cdata',a2iFrame);
end

if ~isempty(g_strctExperiment)
    fnDrawTrackers(handles, iCurrFrame);
    
    bAutoZoom = getappdata(handles.figure1,'bAutoZoom');
    if bAutoZoom
        iActiveMouse = getappdata(handles.figure1,'iActiveMouse');
        axis(handles.hImageAxes,...
            [max(1,g_strctExperiment.m_a2fX(iActiveMouse, iCurrFrame)-200) min(size(a2iFrame,2), g_strctExperiment.m_a2fX(iActiveMouse, iCurrFrame)+200) ...
            max(1,g_strctExperiment.m_a2fY(iActiveMouse, iCurrFrame)-200) min(size(a2iFrame,1),g_strctExperiment.m_a2fY(iActiveMouse, iCurrFrame)+200)]);
    else
        axis(handles.hImageAxes,[140 round(0.9*size(a2iFrame,2)) -10 round(0.9*size(a2iFrame,1))]);
    end
    
end;

fnInvalidateRightPanel(handles)


%set(handles.hStatusLine,'string',num2str(iCurrFrame));
set(handles.hFrameSlider,'value',iCurrFrame);
aiIntStart = getappdata(handles.figure1, 'aiIntervalListStartFrame');
aiBehaviorlistBoxIndex = find(aiIntStart == iCurrFrame);
if ~isempty(aiBehaviorlistBoxIndex)
    set(handles.hIntervalListBox, 'Value', aiBehaviorlistBoxIndex(1));
end
return;



function strctConfig = fnLoadAnnotationXMLConfig(strConfigFile)
strctTmp = fnXMLToStruct(strConfigFile);
acBehaviors = cell(0);
iBehaviorIter = 0;
for i=1:length(strctTmp(2).Children)
    if strcmpi(strctTmp(2).Children(i).Name,'Directories')
        for m=1:length(strctTmp(2).Children(i).Attributes)
            eval(['strctConfig.m_strctDirectories.m_str',strctTmp(2).Children(i).Attributes(m).Name,' = ''',...
                strctTmp(2).Children(i).Attributes(m).Value,''';']);
        end
    end
    
    if strcmpi(strctTmp(2).Children(i).Name,'Behaviors')
        for k=1:length(strctTmp(2).Children(i).Children)
            if strcmpi(strctTmp(2).Children(i).Children(k).Name,'Behavior')
            strctBehavior = struct();
            iBehaviorIter=iBehaviorIter+1;
            for j=1:length(strctTmp(2).Children(i).Children(k).Attributes)
                Tmp = str2num(strctTmp(2).Children(i).Children(k).Attributes(j).Value);
                if ~isempty(Tmp)
                    if length(Tmp) > 1
                        strctBehavior=setfield(strctBehavior,['m_f',strctTmp(2).Children(i).Children(k).Attributes(j).Name],...
                            Tmp);
                    else
                        strctBehavior=setfield(strctBehavior,['m_af',strctTmp(2).Children(i).Children(k).Attributes(j).Name],...
                            Tmp);
                    end
                else
                    strctBehavior=setfield(strctBehavior,['m_str',strctTmp(2).Children(i).Children(k).Attributes(j).Name],...
                        strctTmp(2).Children(i).Children(k).Attributes(j).Value);
                end
            end
            acBehaviors{iBehaviorIter} = strctBehavior;
            end
        end
    end
end

strctConfig.m_acBehaviors = acBehaviors;
return;


function fnFirstInvalidate(handles)
setappdata(handles.figure1,'iActiveOp',1);
setappdata(handles.figure1,'iActiveBehavior',1);
setappdata(handles.figure1,'iOpeartionOnMouse',1);
setappdata(handles.figure1,'iActiveMouse',1);
setappdata(handles.figure1,'iMovieIncrement',1);
setappdata(handles.figure1,'iZoom',500);
setappdata(handles.figure1,'bAddingBehavior',0);
setappdata(handles.figure1,'bAutoZoom',0);
set(handles.hImageAxes,'visible','off');
set(handles.hBehaviorAxes,'visible','off');

hold(handles.hImageAxes,'on');
%hold(handles.hAxes,'on')
%box(handles.hAxes,'on')
% setappdata(handles.figure1,'iCurrFrame',0);

setappdata(handles.figure1,'bMouseDown',0);

set(handles.figure1,'WindowButtonDownFcn',{@fnMouseDown,handles});
set(handles.figure1,'WindowButtonUpFcn',{@fnMouseUp,handles});
set(handles.figure1,'WindowButtonMotionFcn',{@fnMouseMove,handles});
set(handles.figure1,'WindowScrollWheelFcn',{@fnMouseScroll,handles});

set(handles.figure1,'KeyPressFcn',{@fnKeyDown,handles});
set(handles.figure1,'KeyReleaseFcn',{@fnKeyUp,handles});


set(handles.figure1,'Units','pixels');
strctConfig= getappdata(handles.figure1,'strctConfig');
iNumBehaviors = length(strctConfig.m_acBehaviors);

acBehaveNames = cell(1,iNumBehaviors);
for k=1:iNumBehaviors
    acBehaveNames{k} = strctConfig.m_acBehaviors{k}.m_strName;
    acBehaveNames{k+iNumBehaviors} = ['-' strctConfig.m_acBehaviors{k}.m_strName];
end
setappdata(handles.figure1,'acBehaveNames',acBehaveNames);

%
% cmenu = uicontextmenu;
% item1 = uimenu(cmenu, 'Label', 'Delete', 'Callback', {@fnDeleteBehavior,handles});
% setappdata(handles.figure1,'cmenu',cmenu);

return;

function fnDeleteBehavior(handles,iBehaviorIndex)
iActiveMouse = getappdata(handles.figure1,'iActiveMouse');
astrctBehaviors = getappdata(handles.figure1,'astrctBehaviors');
astrctBehaviors{iActiveMouse}(iBehaviorIndex) = [];
fnUpdateBehaviorStruct(handles,astrctBehaviors);
setappdata(handles.figure1,'bDataChanged',1);
fnInvalidateRightPanel(handles);
return;

function fnNegateBehavior(handles,iBehaviorIndex)
iActiveMouse = getappdata(handles.figure1,'iActiveMouse');
astrctBehaviors = getappdata(handles.figure1,'astrctBehaviors');
sAction = astrctBehaviors{iActiveMouse}(iBehaviorIndex).m_strAction;
if sAction(1) == '-'
    sAction = sAction(2:end);
else
    sAction = ['-' sAction];
end
astrctBehaviors{iActiveMouse}(iBehaviorIndex).m_strAction = sAction;
fnUpdateBehaviorStruct(handles,astrctBehaviors);
setappdata(handles.figure1,'bDataChanged',1);
fnInvalidateRightPanel(handles);
return;

function fnGotoBehavior(handles,iBehaviorIndex)
iActiveMouse = getappdata(handles.figure1,'iActiveMouse');
astrctBehaviors = getappdata(handles.figure1,'astrctBehaviors');
iOtherMouse = astrctBehaviors{iActiveMouse}(iBehaviorIndex).m_iOtherMouse;
fnSetOperateOnMouse(handles, iOtherMouse);
iCurrFrame = astrctBehaviors{iActiveMouse}(iBehaviorIndex).m_iStart;
setappdata(handles.figure1,'iCurrFrame', iCurrFrame);
fnInvalidate(handles);
return;

function fnSetActiveFrame(handles,iNewFrame)
assert(iNewFrame>=1, 'fnSetActiveFrame called with iNewFrame=%d', iNewFrame);
iNewFrame = max(1, iNewFrame);
setappdata(handles.figure1,'iCurrFrame',iNewFrame);
fnInvalidate(handles)
drawnow expose
drawnow update
drawnow
return;

function fnStartPlayMovie(handles)
astrctVideoInfo = getappdata(handles.figure1,'astrctVideoInfo');

while (1)
    iMovieIncrement = getappdata(handles.figure1,'iMovieIncrement');
    bMoviePlaying = getappdata(handles.figure1,'bMoviePlaying');
    iMovieDirection = getappdata(handles.figure1,'iMovieDirection');
    iMovieFrame = getappdata(handles.figure1,'iMovieFrame');
    iMovieFrame = iMovieFrame + iMovieIncrement * iMovieDirection;
    if ~bMoviePlaying ||  iMovieFrame >= astrctVideoInfo.m_iNumFrames || iMovieFrame <= 1
        break;
    end;
    setappdata(handles.figure1,'iMovieFrame', iMovieFrame);
    
    fnSetActiveFrame(handles,round(iMovieFrame));
    
end
iCurrFrame = getappdata(handles.figure1,'iCurrFrame');
set(handles.hFrameSlider,'value',iCurrFrame);
setappdata(handles.figure1,'bMoviePlaying',0);
return;

function fnPlayRight(handles)
strctConfig = getappdata(handles.figure1,'strctConfig');

bMoviePlaying = getappdata(handles.figure1,'bMoviePlaying');
iMovieDirection = getappdata(handles.figure1,'iMovieDirection');
iMovieIncrement = getappdata(handles.figure1,'iMovieIncrement');
if bMoviePlaying && iMovieDirection == 1
    iMovieIncrement = 1.2*iMovieIncrement;
    setappdata(handles.figure1,'iMovieIncrement',iMovieIncrement);
else
    setappdata(handles.figure1,'iMovieIncrement',iMovieIncrement/2);
    setappdata(handles.figure1,'bMoviePlaying',1);
    setappdata(handles.figure1,'iMovieDirection',1);
    iCurrFrame = getappdata(handles.figure1,'iCurrFrame');
    setappdata(handles.figure1,'iMovieFrame', iCurrFrame);
    fnStartPlayMovie(handles);
end
return;
function fnPlayLeft(handles)
strctConfig = getappdata(handles.figure1,'strctConfig');


bMoviePlaying = getappdata(handles.figure1,'bMoviePlaying');
iMovieDirection = getappdata(handles.figure1,'iMovieDirection');
iMovieIncrement = getappdata(handles.figure1,'iMovieIncrement');
if bMoviePlaying && iMovieDirection == -1
    iMovieIncrement = 1.2*iMovieIncrement;
    setappdata(handles.figure1,'iMovieIncrement',iMovieIncrement);
else
    setappdata(handles.figure1,'iMovieIncrement',iMovieIncrement/2);
    setappdata(handles.figure1,'bMoviePlaying',1);
    setappdata(handles.figure1,'iMovieDirection',-1);
    iCurrFrame = getappdata(handles.figure1,'iCurrFrame');
    setappdata(handles.figure1,'iMovieFrame', iCurrFrame);
    fnStartPlayMovie(handles);
end
return;

function fnOpLeft(handles)
strctConfig = getappdata(handles.figure1,'strctConfig');

setappdata(handles.figure1,'bMoviePlaying',0);
iActiveOp = getappdata(handles.figure1,'iActiveOp');
switch iActiveOp
    case 1
        % Change active mouse
        iActiveMouse = getappdata(handles.figure1,'iActiveMouse');
        iActiveMouse = max(1,iActiveMouse - 1);
        fnSetActiveMouse(handles,iActiveMouse);
    case 2
        iActiveBehavior = getappdata(handles.figure1,'iActiveBehavior');
        iActiveBehavior = max(1,iActiveBehavior - 1);
        setappdata(handles.figure1,'iActiveBehavior',iActiveBehavior);
        fnAutoSetOperatedOnMouse(handles);
        fnInvalidateBottomPanel(handles);
        
    case 3
        
        iOpeartionOnMouse = getappdata(handles.figure1,'iOpeartionOnMouse');
        iActiveMouse = getappdata(handles.figure1,'iActiveMouse');
        iNumMice = getappdata(handles.figure1,'iNumMice');
        aiOtherMice = setdiff(1:iNumMice,iActiveMouse);
        iIndex = find(iOpeartionOnMouse == aiOtherMice);
        iOpeartionOnMouse = aiOtherMice(max(1,iIndex- 1));
        fnSetOperateOnMouse(handles,iOpeartionOnMouse);
        
end
return;

function fnSetActiveMouse(handles, iActiveMouse)
setappdata(handles.figure1,'iActiveMouse',iActiveMouse);
fnAutoSetOperatedOnMouse(handles);
fnInvalidateBottomPanel(handles);
fnInvalidateRightPanel(handles);
fnInvalidate(handles);

return;

function fnSetOperateOnMouse(handles,iOpeartionOnMouse)
setappdata(handles.figure1,'iOpeartionOnMouse',iOpeartionOnMouse);
fnInvalidateBottomPanel(handles);
fnInvalidate(handles);
return;

function fnAutoSetOperatedOnMouse(handles)
global g_strctExperiment
iCurrFrame = getappdata(handles.figure1,'iCurrFrame');
iActiveBehavior = getappdata(handles.figure1,'iActiveBehavior');
iActiveMouse = getappdata(handles.figure1,'iActiveMouse');
strctConfig = getappdata(handles.figure1,'strctConfig');
iNumMice = size(g_strctExperiment.m_a2fX,1);
if strctConfig.m_acBehaviors{iActiveBehavior}.m_afOperatedOnOtherMice == 1
    
    a2fPos = [g_strctExperiment.m_a2fX(:,iCurrFrame),g_strctExperiment.m_a2fY(:,iCurrFrame)];
    aiSetDiff = setdiff(1:iNumMice, iActiveMouse);
    [fDummy, iMinIndex] = min((a2fPos(aiSetDiff,1)-a2fPos(iActiveMouse,1)).^2 + (a2fPos(aiSetDiff,2)-a2fPos(iActiveMouse,2)).^2);
    fnSetOperateOnMouse(handles,aiSetDiff(iMinIndex));
end
return;


function fnOpRight(handles)
strctConfig = getappdata(handles.figure1,'strctConfig');

setappdata(handles.figure1,'bMoviePlaying',0);
iActiveOp = getappdata(handles.figure1,'iActiveOp');
switch iActiveOp
    case 1
        % Change active mouse
        iActiveMouse = getappdata(handles.figure1,'iActiveMouse');
        iNumMice = getappdata(handles.figure1,'iNumMice');
        iActiveMouse = min(iNumMice,iActiveMouse + 1);
        fnSetActiveMouse(handles,iActiveMouse);
    case 2
        iActiveBehavior = getappdata(handles.figure1,'iActiveBehavior');
        iActiveBehavior = min(length(strctConfig.m_acBehaviors), iActiveBehavior + 1);
        setappdata(handles.figure1,'iActiveBehavior',iActiveBehavior);
        fnAutoSetOperatedOnMouse(handles);
        fnInvalidateBottomPanel(handles);
    case 3
        iOpeartionOnMouse = getappdata(handles.figure1,'iOpeartionOnMouse');
        iActiveMouse = getappdata(handles.figure1,'iActiveMouse');
        iNumMice = getappdata(handles.figure1,'iNumMice');
        aiOtherMice = setdiff(1:iNumMice,iActiveMouse);
        iIndex = find(iOpeartionOnMouse == aiOtherMice);
        iOpeartionOnMouse = aiOtherMice(min(iNumMice-1,iIndex+ 1));
        fnSetOperateOnMouse(handles,iOpeartionOnMouse);
        
end

return;

function fnAddBehaviorAux(handles)
setappdata(handles.figure1,'bDataChanged',true);

setappdata(handles.figure1,'bAddingBehavior',0);
setappdata(handles.figure1,'bMoviePlaying',0);
iCurrFrame = getappdata(handles.figure1,'iCurrFrame');
iStartBehaviorFrame = getappdata(handles.figure1,'iStartBehaviorFrame');
fnAddNewBehavior(handles, iStartBehaviorFrame, iCurrFrame);
return;

function fnOpSpace(handles)
strctConfig = getappdata(handles.figure1,'strctConfig');

bAddingBehavior = getappdata(handles.figure1,'bAddingBehavior');
if bAddingBehavior
    % End frame of behavior
    % Add new behavior
    fnAddBehaviorAux(handles);
else
    % Start frame of behavior
    setappdata(handles.figure1,'bAddingBehavior',1);
    iCurrFrame = getappdata(handles.figure1,'iCurrFrame');
    setappdata(handles.figure1,'iStartBehaviorFrame',iCurrFrame);
    
    setappdata(handles.figure1,'bMoviePlaying',1);
    setappdata(handles.figure1,'iMovieDirection',1);
    setappdata(handles.figure1,'iMovieFrame', iCurrFrame);
    fnStartPlayMovie(handles);
end
return;
function fnOpUp(handles)
setappdata(handles.figure1,'bMoviePlaying',0);
iActiveOp = getappdata(handles.figure1,'iActiveOp');
iActiveOp = iActiveOp - 1;
if iActiveOp < 1
    iActiveOp = 1;
end
setappdata(handles.figure1,'iActiveOp',iActiveOp);
fnInvalidateBottomPanel(handles);

return;

function fnOpDown(handles)
strctConfig = getappdata(handles.figure1,'strctConfig');

setappdata(handles.figure1,'bMoviePlaying',0);
iActiveOp = getappdata(handles.figure1,'iActiveOp');
iActiveBehavior = getappdata(handles.figure1,'iActiveBehavior');
if ~(iActiveOp == 2 && strctConfig.m_acBehaviors{iActiveBehavior}.m_afOperatedOnOtherMice == 0)
    iActiveOp = iActiveOp + 1;
    if iActiveOp > 3
        iActiveOp = 1;
    end
end
setappdata(handles.figure1,'iActiveOp',iActiveOp);
fnInvalidateBottomPanel(handles);

return;

function fnIncreaseSpeed(handles)
iMovieIncrement = getappdata(handles.figure1,'iMovieIncrement');
iMovieIncrement = min(10000,1.2*iMovieIncrement);
setappdata(handles.figure1,'iMovieIncrement',iMovieIncrement);
return;

function fnDecreaseSpeed(handles)
iMovieIncrement = getappdata(handles.figure1,'iMovieIncrement');
iMovieIncrement = max(0.5,iMovieIncrement/1.2);
setappdata(handles.figure1,'iMovieIncrement',iMovieIncrement);
return;


function fnKeyDown(a,b,handles)
strctConfig = getappdata(handles.figure1,'strctConfig');


%setappdata(handles.figure1,'iActiveBehavior',1);
%setappdata(handles.figure1,'iOpeartionOnMouse',1);
%setappdata(handles.figure1,'iActiveMouse',1);

if isempty(b.Modifier)
    strMod = '';
else
    strMod = b.Modifier{1};
end;

bAddingBehavior = getappdata(handles.figure1,'bAddingBehavior');
if bAddingBehavior && ~strcmpi(b.Key,'space')
    fnAddBehaviorAux(handles);
end

switch b.Key
    case '1'
        fnSetActiveMouse(handles,1);
    case '2'
        fnSetActiveMouse(handles,2);
    case '3'
        fnSetActiveMouse(handles,3);
    case '4'
        fnSetActiveMouse(handles,4);
        
        
    case 'equal'
        fnIncreaseSpeed(handles);
    case 'add'
        fnIncreaseSpeed(handles)
    case 'subtract'
        fnDecreaseSpeed(handles)
    case 'hyphen'
        fnDecreaseSpeed(handles)
    case 'numpad6'
        fnPlayRight(handles);
    case 'numpad4'
        fnPlayLeft(handles);
        
    case 'uparrow'
        fnOpUp(handles);
    case 'downarrow'
        fnOpDown(handles)
    case 'rightarrow'
        if strcmp(strMod,'alt')
            fnPlayRight(handles);
        elseif strcmp(strMod,'shift')
            fnNextFrame(handles);
        else
            fnOpRight(handles);
        end;
    case 'leftarrow'
        if strcmp(strMod,'alt')
            fnPlayLeft(handles);
        elseif strcmp(strMod,'shift')
            fnPrevFrame(handles);
        else
            fnOpLeft(handles);
        end
    case 'space'
        fnOpSpace(handles);
        
    otherwise
        if isempty(b.Modifier)
            setappdata(handles.figure1,'bMoviePlaying',0);
        end
end
fprintf('%s %s Down\n',b.Key,strMod);
return;


function fnKeyUp(a,b,handles)
if isempty(b.Modifier)
    strMod = '';
else
    strMod = b.Modifier{1};
end;
fprintf('%s %s Up\n',b.Key,strMod);

return;

function fnLoadNewPositionFile(handles,strPositionFile)

strctConfig = getappdata(handles.figure1,'strctConfig');
setappdata(handles.figure1,'strPositionFile',strPositionFile);
fprintf('Loading positional info...');
strctTmp = load(strPositionFile);
fprintf('Done!\n');
if ~isfield(strctTmp,'astrctTrackers')
    errordlg('This is not a tracking results file');
    return;
end;

global g_strctExperiment
g_strctExperiment.m_a2fX = single(cat(1,strctTmp.astrctTrackers.m_afX));
g_strctExperiment.m_a2fY = single(cat(1,strctTmp.astrctTrackers.m_afY));
g_strctExperiment.m_a2fA = single(cat(1,strctTmp.astrctTrackers.m_afA));
g_strctExperiment.m_a2fB = single(cat(1,strctTmp.astrctTrackers.m_afB));
g_strctExperiment.m_a2fTheta = single(cat(1,strctTmp.astrctTrackers.m_afTheta));

g_strctExperiment.m_afTimeStamp = 0:1/30:(length(strctTmp.astrctTrackers(1).m_afX)-1)*(1/30);

fnSetNumMice(handles, size(g_strctExperiment.m_a2fX,1));

fnInvalidate(handles);

%fnInvalidateAnnotation(handles);
return;



function fnAddNewBehavior(handles, iStartBehaviorFrame, iCurrFrame)
global g_strctExperiment
iActiveBehavior = getappdata(handles.figure1,'iActiveBehavior');
iOpeartionOnMouse = getappdata(handles.figure1,'iOpeartionOnMouse');
strctConfig = getappdata(handles.figure1,'strctConfig');

iNumMice = size(g_strctExperiment.m_a2fX,1);

iActiveMouse = getappdata(handles.figure1,'iActiveMouse');
astrctBehaviors = getappdata(handles.figure1,'astrctBehaviors');
if isempty(astrctBehaviors)
    astrctBehaviors = cell(1,iNumMice);
end

strctBehavior.m_iMouse = iActiveMouse;
strctBehavior.m_iStart = iStartBehaviorFrame;
strctBehavior.m_iEnd = iCurrFrame;
strctBehavior.m_strAction = strctConfig.m_acBehaviors{iActiveBehavior}.m_strName;
if strctConfig.m_acBehaviors{iActiveBehavior}.m_afOperatedOnOtherMice
    strctBehavior.m_iOtherMouse = iOpeartionOnMouse;
else
    strctBehavior.m_iOtherMouse = 0;
end
strctBehavior.m_fScore = 0;

iNumBeahviors = length(astrctBehaviors{iActiveMouse});
if iNumBeahviors== 0
    astrctBehaviors{iActiveMouse} =strctBehavior;
else
    astrctBehaviors{iActiveMouse}(iNumBeahviors+1) = strctBehavior;
end
fnUpdateBehaviorStruct(handles,astrctBehaviors);
fnInvalidateRightPanel(handles);
return;


function hHandle = fnDrawRect(hAxes,aiCoord, aiCol,cmenu)
w = abs(aiCoord(2) - aiCoord(1));
h = abs(aiCoord(4) - aiCoord(3));
cx = min(aiCoord([1,2])) ;
cy = min(aiCoord([3,4])) ;
if w <= 0 || h <= 0
    hHandle = [];
else
    hHandle = rectangle('position',[cx,cy,w,h],'facecolor',aiCol,'UIContextMenu', cmenu,'parent',hAxes);
end
return;

function hHandle = fnDrawFrameRect(hAxes,aiCoord, aiCol,cmenu)
w = abs(aiCoord(2) - aiCoord(1));
h = abs(aiCoord(4) - aiCoord(3));
cx = min(aiCoord([1,2])) ;
cy = min(aiCoord([3,4])) ;
if cx <= 0 || cy <= 0
    hHandle = [];
else
    hHandle = rectangle('position',[cx,cy,w,h],'facecolor','none','edgecolor',aiCol,'UIContextMenu', cmenu,'parent',hAxes);
end
return;

function fnInvalidateRightPanel(handles)

global g_strctExperiment
hRightAxes = getappdata(handles.figure1,'hRightAxes');
if isempty(hRightAxes)
    hRightAxes = axes('parent',handles.uipanel22,'Xlim',[0 1],'ylim',[0 1],'Color',[0 0 0]);
    set(hRightAxes,'XtickLabel','','YTicklabel','','units','pixels');
    set(handles.uipanel22,'units','pixels');
    aiPos = get(handles.uipanel22,'position');
    set(hRightAxes,'Position',[1 1 aiPos(3:4)]);
    setappdata(handles.figure1,'hRightAxes',hRightAxes);
end;
aiPos = get(hRightAxes,'Position');
iHeight = aiPos(4);
iWidth = aiPos(3);
strctConfig = getappdata(handles.figure1,'strctConfig');
iNumBehaviors = length(strctConfig.m_acBehaviors);
acBehaveNames = getappdata(handles.figure1,'acBehaveNames');

iHeightPerBehavior = ceil(iHeight / (iNumBehaviors+1));
iCurrFrame = getappdata(handles.figure1,'iCurrFrame');
iActiveMouse = getappdata(handles.figure1,'iActiveMouse');


% Find all behaviors that are in this range...
delete(get(handles.hBehaviorAxes,'Children'))
iZoom = getappdata(handles.figure1,'iZoom');
if isempty(g_strctExperiment)
    return;
end;
iNumFrames = size(g_strctExperiment.m_a2fX,2);
%iLeftFrame = max(1,iCurrFrame - iZoom);
%iRightFrame = min(iNumFrames,iCurrFrame + iZoom);
iLeftFrame = iCurrFrame - iZoom;
iRightFrame =iCurrFrame + iZoom;

iWidth = iRightFrame-iLeftFrame+1;


astrctBehaviors = getappdata(handles.figure1,'astrctBehaviors');
delete(get(hRightAxes,'Children'));
%set(hRightAxes,'Color',[0 0 0]);

a2fColor = jet(iNumBehaviors);
cmenu = getappdata(handles.figure1,'cmenu');

if ~isempty(astrctBehaviors) && ~isempty(astrctBehaviors{iActiveMouse})
    
    %iNumBehaviors = length(astrctBehaviors{iActiveMouse});
    aiStart = cat(1,astrctBehaviors{iActiveMouse}.m_iStart);
    aiEnd= cat(1,astrctBehaviors{iActiveMouse}.m_iEnd);
    
    aiSelectedMouseBehaviors = find(aiStart <= iRightFrame & aiEnd >= iLeftFrame);
    acBehaveNames = getappdata(handles.figure1,'acBehaveNames');
    
    for k=1:length(aiSelectedMouseBehaviors)
        iLeft = max(iLeftFrame, astrctBehaviors{iActiveMouse}(aiSelectedMouseBehaviors(k)).m_iStart);
        iRight = min(iRightFrame, astrctBehaviors{iActiveMouse}(aiSelectedMouseBehaviors(k)).m_iEnd);
        if iRight == iLeft
            continue;
        end;
        [iOp, bAntiOp] = getActionIndex(acBehaveNames, astrctBehaviors{iActiveMouse}(aiSelectedMouseBehaviors(k)).m_strAction);
        % Scale to fit....
        fLeftX = (iLeft - iLeftFrame) / iWidth;
        fRightX = (iRight - iLeftFrame) / iWidth;
        
        fUpY = (iOp-1) / (iNumBehaviors+2) + 0.1 * 1/(iNumBehaviors+2);
        fDownY = fUpY + 1/(iNumBehaviors+2) - 0.1 * 1/(iNumBehaviors+2);
        
        cmenu = [];
        %        cmenu = uicontextmenu;
        %        item1 = uimenu(cmenu, 'Label', 'Delete', 'Callback', {@fnDeleteBehavior,handles,aiSelectedMouseBehaviors(k)});
        
        if bAntiOp
            fColor = 1 - a2fColor(iOp,:);
        else
            fColor  = a2fColor(iOp,:);
        end
        fnDrawRect(hRightAxes,[fLeftX fRightX fUpY fDownY], fColor,cmenu);
    end;
end;

bAddingBehavior = getappdata(handles.figure1,'bAddingBehavior');
if bAddingBehavior
    iActiveBehavior = getappdata(handles.figure1,'iActiveBehavior');
    iStartBehaviorFrame = getappdata(handles.figure1,'iStartBehaviorFrame');
    
    iLeft = max(iLeftFrame, iStartBehaviorFrame);
    iRight = min(iRightFrame, iCurrFrame);
    if iRight ~= iLeft
        % Scale to fit....
        fLeftX = (iLeft - iLeftFrame) / iWidth;
        fRightX = (iRight - iLeftFrame) / iWidth;
        
        
        fUpY = (iActiveBehavior-1) / (iNumBehaviors+2) + 0.1 * 1/(iNumBehaviors+2);
        fDownY = fUpY + 1/(iNumBehaviors+2) - 0.1 * 1/(iNumBehaviors+2);
        
        %   cmenu = uicontextmenu;
        %   item1 = uimenu(cmenu, 'Label', 'Delete', 'Callback', {@fnDeleteBehavior,handles,length(astrctBehaviors{iActiveMouse})+1});
        cmenu = [];
        
        fnDrawRect(hRightAxes,[fLeftX fRightX fUpY fDownY], a2fColor(iActiveBehavior,:),cmenu);
    end
end
hold(hRightAxes,'on');
plot(hRightAxes, ones(1,2)* (iCurrFrame - iLeftFrame) / iWidth,[0 0.9],'color',[1 1 1],'linestyle','--');

fnDrawRect(hRightAxes,[0.005 1-0.01 0.93 0.96], [0.5 0.5 0.5],[]);

fnDrawFrameRect(hRightAxes,[0.005+max(1,iLeftFrame) / iNumFrames 0.005+min(iNumFrames,iRightFrame) / iNumFrames 0.93 0.96], [1 0 0],[]);

%Frame



return;
%
%
%
% %global g_strctExperiment
% aiSelectedMouseBehaviors = find(g_strctBehaviors.m_aiMouseA == iCurrMouse);
% iNumFrames = getappdata(handles.figure1,'iNumFrames');
%
% cla(handles.hAxes);
% [afSelected, afUnSelected] = fnGetMiceColors(iCurrMouse);
% %hVelocityTrace = plot(handles.hAxes, 0.8 + 0.09*afVelNorm,'color',afUnSelected,'Linewidth',2);
% %hLowerBound = plot(handles.hAxes,[0 iNumFrames],[0.8 0.8],'--k','LineWidth',2);
% %hUpperBound = plot(handles.hAxes,[0 iNumFrames],[0.9 0.9],'--k','LineWidth',2);
%
% iZoomRangeY = getappdata(handles.figure1,'iZoomRangeY');
% iCurrY = getappdata(handles.figure1,'iCurrY');
% afYZoom = min(10,max(0,[iCurrY-iZoomRangeY,iCurrY+iZoomRangeY]));
%
% hCurrFrameIndicator = plot(handles.hAxes,[iCurrFrame iCurrFrame],[0 10],'--k');
% setappdata(handles.figure1,'hCurrFrameIndicator',hCurrFrameIndicator);
% axis(handles.hAxes,[iCurrFrame-iZoomRangeX iCurrFrame+iZoomRangeX afYZoom]);
% %set(handles.hAxes,'Xtick',[iCurrFrame-iZoomRangeX+1, iCurrFrame, iCurrFrame+iZoomRangeX-1])
% %hLowerBound = plot(handles.hAxes,[0 iNumFrames],[0.6 0.6],'--k','LineWidth',2);
% %hUpperBound = plot(handles.hAxes,[0 iNumFrames],[0.7 0.7],'--k','LineWidth',2);
% %hAngleVelocityTrace = plot(handles.hAxes, 0.6 + 0.09*afVelTheta,'color',afUnSelected,'Linewidth',2);
% % % % %
%
% cmenu = getappdata(handles.figure1,'cmenu');
%
% % at the moment, draw all, but if this becomes unreasonable, you should
% % only plot the ones inside the current zoom range... but then you need to
% % redraw this everytime you scroll to a differnet frame....
%
% aiStart = g_strctBehaviors.m_aiStart(aiSelectedMouseBehaviors);
% aiEnd =  g_strctBehaviors.m_aiEnd(aiSelectedMouseBehaviors);
%
% aiSelectedMouseBehaviors = aiSelectedMouseBehaviors(aiStart <= iCurrFrame-iZoomRangeX & aiEnd >= iCurrFrame-iZoomRangeX | ...
%     aiStart >= iCurrFrame-iZoomRangeX &  aiStart <= iCurrFrame+iZoomRangeX);
% axes(handles.hAxes);
%
% iNumMice = getappdata(handles.figure1,'iNumMice');
%
% a2fColors = fnGetBehaviorColor(g_strctBehaviors.m_aiMouseA(aiSelectedMouseBehaviors),...
%     g_strctBehaviors.m_aiMouseB(aiSelectedMouseBehaviors),...
%     g_strctBehaviors.m_aiType(aiSelectedMouseBehaviors),iNumMice);
%
% for k=1:length(aiSelectedMouseBehaviors)
%
%     g_strctBehaviors.m_ahDrawHandle(aiSelectedMouseBehaviors(k)) = ...
%         fnDrawRect([g_strctBehaviors.m_aiStart(aiSelectedMouseBehaviors(k)) ...
%         g_strctBehaviors.m_aiEnd(aiSelectedMouseBehaviors(k)) ...
%         g_strctBehaviors.m_aiStartY(aiSelectedMouseBehaviors(k)) ...
%         g_strctBehaviors.m_aiEndY(aiSelectedMouseBehaviors(k))] ...
%         ,a2fColors(:,k),cmenu);
% end;

% return;

%%


%%
%
% function fnCreateContextMenu(handles)
% cmenu = uicontextmenu;
% item1 = uimenu(cmenu, 'Label', 'Sleeping', 'Callback', {@fnChangeBehavior,handles,'Sleeping',''});
% item2 = uimenu(cmenu, 'Label', 'Grooming', 'Callback', {@fnChangeBehavior,handles,'Grooming',''});
% item3 = uimenu(cmenu, 'Label', 'Eating/Drinking', 'Callback', {@fnChangeBehavior,handles,'Eating/Drinking',''});
% item4 = uimenu(cmenu, 'Label', 'Exploring/Running', 'Callback', {@fnChangeBehavior,handles,'Exploring/Running',''});
% item5 = uimenu(cmenu, 'Label', 'Chasing');
% uimenu(item5, 'Label', 'Red','Callback', {@fnChangeBehavior,handles,'Chasing','Red'});
% uimenu(item5, 'Label', 'Green','Callback', {@fnChangeBehavior,handles,'Chasing','Green'});
% uimenu(item5, 'Label', 'Blue','Callback',  {@fnChangeBehavior,handles,'Chasing','Blue'});
% uimenu(item5, 'Label', 'Cyan','Callback',  {@fnChangeBehavior,handles,'Chasing','Cyan'});
% item6 = uimenu(cmenu, 'Label', 'Fighting');
% uimenu(item6, 'Label', 'Red','Callback', {@fnChangeBehavior,handles,'Fighting','Red'});
% uimenu(item6, 'Label', 'Green','Callback', {@fnChangeBehavior,handles,'Fighting','Green'});
% uimenu(item6, 'Label', 'Blue','Callback',  {@fnChangeBehavior,handles,'Fighting','Blue'});
% uimenu(item6, 'Label', 'Cyan','Callback',  {@fnChangeBehavior,handles,'Fighting','Cyan'});
%
% item7 = uimenu(cmenu, 'Label', 'Sniffing');
% uimenu(item7, 'Label', 'Red','Callback', {@fnChangeBehavior,handles,'Sniffing','Red'});
% uimenu(item7, 'Label', 'Green','Callback', {@fnChangeBehavior,handles,'Sniffing','Green'});
% uimenu(item7, 'Label', 'Blue','Callback',  {@fnChangeBehavior,handles,'Sniffing','Blue'});
% uimenu(item7, 'Label', 'Cyan','Callback',  {@fnChangeBehavior,handles,'Sniffing','Cyan'});
%
% item8 = uimenu(cmenu, 'Label', 'Courting');
% uimenu(item8, 'Label', 'Red','Callback', {@fnChangeBehavior,handles,'Courting','Red'});
% uimenu(item8, 'Label', 'Green','Callback', {@fnChangeBehavior,handles,'Courting','Green'});
% uimenu(item8, 'Label', 'Blue','Callback',  {@fnChangeBehavior,handles,'Courting','Blue'});
% uimenu(item8, 'Label', 'Cyan','Callback',  {@fnChangeBehavior,handles,'Courting','Cyan'});
%
% uimenu(cmenu, 'Label', 'Delete', 'Callback', {@fnChangeBehavior,handles,'Delete',''}, 'Separator','on');
% setappdata(handles.figure1,'cmenu',cmenu);
% return;
%
% function afColor = fnGetBehaviorColors(strBehavior,strAdditionalInfo)
% switch lower(strBehavior)
%     case 'sleeping'
%         iIndex = 1;
%     case 'grooming'
%         iIndex = 2;
%     case 'eating/drinking'
%         iIndex = 3;
%     case 'exploring/running'
%         iIndex = 4;
%     case 'chasing'
%         iIndex = 5;
%     case 'fighting'
%         iIndex = 6;
%     case 'sniffing'
%         iIndex = 7;
%     case 'courting'
%         iIndex = 8;
%     otherwise
%         iIndex = 9;
% end
% A=hsv;
% afColor = A(round(iIndex/9 * size(A,1)),:);
% return;

%
% function fnChangeBehavior(a,b,handles,strDescription,strAdditionalInfo)
% error('');
%
% strctMouseDown = getappdata(handles.figure1,'strctMouseDown');
% iCurrMouse = getappdata(handles.figure1,'iCurrMouse');
% acAnnotation = getappdata(handles.figure1,'acAnnotation');
%
% [iIndex] = fnGetSelectedInterval(handles,strctMouseDown);
%
% if isempty(iIndex)
%     fprintf('Critical error - no interval found?!?!?!\n');
%     return;
% end;
% if strcmpi(strDescription,'Delete')
%     delete(acAnnotation{iCurrMouse}(iIndex).m_hDrawHandle);
%     acAnnotation{iCurrMouse}(iIndex) = [];
% else
%     afColor = fnGetBehaviorColors(strDescription,strAdditionalInfo);
%     acAnnotation{iCurrMouse}(iIndex).m_strDescription = [strDescription,' ',strAdditionalInfo];
%     set(acAnnotation{iCurrMouse}(iIndex).m_hDrawHandle,'facecolor', afColor);
% end;
%
% setappdata(handles.figure1,'acAnnotation',acAnnotation);
% return;
%
%


% --- Outputs from this function are returned to the command line.
function varargout = NewAnnotationGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function fnSafeDelete(ahHandles)
for k=1:length(ahHandles)
    if ishandle(ahHandles(k))
        delete(ahHandles(k));
    end
end;
return;

function fnDrawTrackers(handles,iCurrFrame)
global g_strctExperiment
iNumMice = size(g_strctExperiment.m_a2fX,1);
ahHandles = getappdata(handles.figure1,'hTrackerHighlights');
fnSafeDelete(ahHandles);
for iMouseIter=1:iNumMice
    [afSelected, afUnSelected] = fnGetMiceColors(iMouseIter);
    strctTracker.m_fX = g_strctExperiment.m_a2fX(iMouseIter, iCurrFrame);
    strctTracker.m_fY = g_strctExperiment.m_a2fY(iMouseIter, iCurrFrame);
    strctTracker.m_fA = g_strctExperiment.m_a2fA(iMouseIter, iCurrFrame);
    strctTracker.m_fB = g_strctExperiment.m_a2fB(iMouseIter, iCurrFrame);
    strctTracker.m_fTheta = g_strctExperiment.m_a2fTheta(iMouseIter, iCurrFrame);
    
    %     if iMouseIter == iCurrMouse
    %         hHandle = fnDrawTracker(handles.hImageAxes,strctTracker,afSelected, 2,0);
    %     else
    hHandle = fnDrawTracker(handles.hImageAxes,strctTracker, afUnSelected, 1,0);
    %     end;
    ahHandles = [ahHandles;hHandle];
end;


iActiveBehavior = getappdata(handles.figure1,'iActiveBehavior');
iActiveMouse = getappdata(handles.figure1,'iActiveMouse');
strctConfig = getappdata(handles.figure1,'strctConfig');
iOpeartionOnMouse = getappdata(handles.figure1,'iOpeartionOnMouse');
if strctConfig.m_acBehaviors{iActiveBehavior}.m_afOperatedOnOtherMice == 1 && iOpeartionOnMouse > 0 
    afLineX = [g_strctExperiment.m_a2fX(iActiveMouse, iCurrFrame); g_strctExperiment.m_a2fX(iOpeartionOnMouse, iCurrFrame)];
    afLineY = [g_strctExperiment.m_a2fY(iActiveMouse, iCurrFrame); g_strctExperiment.m_a2fY(iOpeartionOnMouse, iCurrFrame)];
    ahHandles  = [ahHandles ; plot(handles.hImageAxes,afLineX',afLineY','m')];
end

setappdata(handles.figure1,'hTrackerHighlights',ahHandles);
return;



% function fnDrawAnnotation(handles,iCurrFrame,iCurrMouse)
% global g_strctExperiment
% iNumFrames = size(g_strctExperiment.m_a2fX,2);
% iNumMice = size(g_strctExperiment.m_a2fX,1);
% iZoomRangeX = getappdata(handles.figure1,'iZoomRangeX');
% iCurrMouse =  getappdata(handles.figure1,'iCurrMouse');
% delete(get(handles.hBehaviorAxes,'Children'))
% iLeftFrame = max(1,iCurrFrame - iZoomRangeX);
% iRightFrame = min(iCurrFrame + iZoomRangeX, iNumFrames);
% astrctBehaviors = getappdata(handles.figure1,'astrctBehaviors');
% if isempty(astrctBehaviors) || isempty(astrctBehaviors(iCurrMouse))
%     return;
% end;

%
% for k=1:length(aiSelectedMouseBehaviors)
%
%         fnDrawRect([g_strctBehaviors.m_aiStart(aiSelectedMouseBehaviors(k)) ...
%         g_strctBehaviors.m_aiEnd(aiSelectedMouseBehaviors(k)) ...
%         g_strctBehaviors.m_aiStartY(aiSelectedMouseBehaviors(k)) ...
%         g_strctBehaviors.m_aiEndY(aiSelectedMouseBehaviors(k))] ...
%         ,a2fColors(:,k),cmenu);
% end;
% \
%return;

%
%
% %global g_strctExperiment
% aiSelectedMouseBehaviors = find(g_strctBehaviors.m_aiMouseA == iCurrMouse);
% iNumFrames = getappdata(handles.figure1,'iNumFrames');
%
% cla(handles.hAxes);
% [afSelected, afUnSelected] = fnGetMiceColors(iCurrMouse);
% %hVelocityTrace = plot(handles.hAxes, 0.8 + 0.09*afVelNorm,'color',afUnSelected,'Linewidth',2);
% %hLowerBound = plot(handles.hAxes,[0 iNumFrames],[0.8 0.8],'--k','LineWidth',2);
% %hUpperBound = plot(handles.hAxes,[0 iNumFrames],[0.9 0.9],'--k','LineWidth',2);
%
% iZoomRangeY = getappdata(handles.figure1,'iZoomRangeY');
% iCurrY = getappdata(handles.figure1,'iCurrY');
% afYZoom = min(10,max(0,[iCurrY-iZoomRangeY,iCurrY+iZoomRangeY]));
%
% hCurrFrameIndicator = plot(handles.hAxes,[iCurrFrame iCurrFrame],[0 10],'--k');
% setappdata(handles.figure1,'hCurrFrameIndicator',hCurrFrameIndicator);
% axis(handles.hAxes,[iCurrFrame-iZoomRangeX iCurrFrame+iZoomRangeX afYZoom]);
% %set(handles.hAxes,'Xtick',[iCurrFrame-iZoomRangeX+1, iCurrFrame, iCurrFrame+iZoomRangeX-1])
% %hLowerBound = plot(handles.hAxes,[0 iNumFrames],[0.6 0.6],'--k','LineWidth',2);
% %hUpperBound = plot(handles.hAxes,[0 iNumFrames],[0.7 0.7],'--k','LineWidth',2);
% %hAngleVelocityTrace = plot(handles.hAxes, 0.6 + 0.09*afVelTheta,'color',afUnSelected,'Linewidth',2);
% % % % %
%
% cmenu = getappdata(handles.figure1,'cmenu');
%
% % at the moment, draw all, but if this becomes unreasonable, you should
% % only plot the ones inside the current zoom range... but then you need to
% % redraw this everytime you scroll to a differnet frame....
%
% aiStart = g_strctBehaviors.m_aiStart(aiSelectedMouseBehaviors);
% aiEnd =  g_strctBehaviors.m_aiEnd(aiSelectedMouseBehaviors);
%
% aiSelectedMouseBehaviors = aiSelectedMouseBehaviors(aiStart <= iCurrFrame-iZoomRangeX & aiEnd >= iCurrFrame-iZoomRangeX | ...
%     aiStart >= iCurrFrame-iZoomRangeX &  aiStart <= iCurrFrame+iZoomRangeX);
% axes(handles.hAxes);
%
% iNumMice = getappdata(handles.figure1,'iNumMice');
%
% a2fColors = fnGetBehaviorColor(g_strctBehaviors.m_aiMouseA(aiSelectedMouseBehaviors),...
%     g_strctBehaviors.m_aiMouseB(aiSelectedMouseBehaviors),...
%     g_strctBehaviors.m_aiType(aiSelectedMouseBehaviors),iNumMice);
%
% for k=1:length(aiSelectedMouseBehaviors)
%
%     g_strctBehaviors.m_ahDrawHandle(aiSelectedMouseBehaviors(k)) = ...
%         fnDrawRect([g_strctBehaviors.m_aiStart(aiSelectedMouseBehaviors(k)) ...
%         g_strctBehaviors.m_aiEnd(aiSelectedMouseBehaviors(k)) ...
%         g_strctBehaviors.m_aiStartY(aiSelectedMouseBehaviors(k)) ...
%         g_strctBehaviors.m_aiEndY(aiSelectedMouseBehaviors(k))] ...
%         ,a2fColors(:,k),cmenu);
% end;
%
% return;

function [a2fColor] = fnGetBehaviorColor(aiMouseA, aiMouseB, aiType,iNumMice)

% fStartY = iType + iMouseB;
% fEndY = fStartY + 0.1;
iNumBehaviors = 7;
a2iJet = jet(iNumMice*iNumMice*iNumBehaviors);
a2fColor = a2iJet(aiMouseA * iNumMice*iNumMice + aiMouseB * iNumMice + aiType,:)';
return;

function fnNextFrame(handles)
iCurrFrame = getappdata(handles.figure1,'iCurrFrame');
iCurrFrame = iCurrFrame + 1;
setappdata(handles.figure1,'iCurrFrame',iCurrFrame);
fnInvalidate(handles);
return;

function fnPrevFrame(handles)
iCurrFrame = getappdata(handles.figure1,'iCurrFrame');
iCurrFrame = max(1,iCurrFrame - 1);
setappdata(handles.figure1,'iCurrFrame',iCurrFrame);
fnInvalidate(handles);
return;



%
% function fnClearAnnotation(handles)
% global g_strctBehaviors
% g_strctBehaviors = [];
% fnInvalidateBehaviorList(handles);
% return;
%
% function fnClearPositionalInfo(handles)
% return;

function hLoadExperiment_Callback(hObject, eventdata, handles)
return;
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
setappdata(handles.figure1,'iNumFrames', size(g_strctExperiment.m_a2fX,2));
fnSetNumMice(handles, size(g_strctExperiment.m_a2fX,1));

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


set(handles.hFrameSlider,'Min',1,'Max',strctVideoInfo.m_iNumFrames,'Value',1,...
    'SliderStep',[1/strctVideoInfo.m_iNumFrames, 1/strctVideoInfo.m_iNumFrames*10]);

set(handles.figure1,'Name',strVideoFile);

%fnClearAnnotation(handles);
%fnClearPositionalInfo(handles);
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
%
% function fnSetActiveMouse(handles,iActiveMouse)
% iNumMice = getappdata(handles.figure1,'iNumMice');
% setappdata(handles.figure1,'iCurrMouse',iActiveMouse);
% strctID = getappdata(handles.figure1,'strctID');
% hIDImage = getappdata(handles.figure1,'hIDImage');
% set(hIDImage,'cdata',strctID.strctIdentityClassifier.m_a3fRepImages(:,:,iActiveMouse));
%
% %
% % %ahHandles = [handles.hSelectRedMouse, handles.hSelectGreenMouse, handles.hSelectBlueMouse, handles.hSelectCyanMouse];
% % setappdata(handles.figure1,'iCurrMouse',iActiveMouse);
% % for k=1:length(ahHandles)
% %     if k > iNumMice
% %         set(ahHandles(k),'enable','off');
% %         set(ahHandles(k),'BackgroundColor',[0.941176 0.941176 0.941176])
% %
% %     else
% %         set(ahHandles(k),'enable','on');
% %     end;
% %     [afSelected, afUnSelected] = fnGetMiceColors(k);
% %     if k == iActiveMouse
% %         set(ahHandles(k),'FontWeight','bold')
% %         set(ahHandles(k),'BackgroundColor',afSelected);
% %     else
% %         set(ahHandles(k),'FontWeight','normal')
% %         if k <= iNumMice
% %             set(ahHandles(k),'BackgroundColor',afUnSelected);
% %         end;
% %     end;
% % end;
% fnInvalidate(handles);
% %fnInvalidateAnnotation(handles);
% return;


function fnSetNumMice(handles, iNumMice)
setappdata(handles.figure1,'iNumMice',iNumMice);
str = ['All'; [repmat(['  '],iNumMice,1) num2str((1:iNumMice)')]];
set(handles.hFilterActiveMouse, 'String', str);
set(handles.hFilterOtherMouse, 'String', str);
fnInvalidateBottomPanel(handles);

function fnInvalidateBottomPanel(handles)
strctConfig = getappdata(handles.figure1,'strctConfig');
set(handles.hSelectionPanel,'Units','Pixels')
iNumMice = getappdata(handles.figure1,'iNumMice');
aiRect=get(handles.hSelectionPanel,'Position');

iActiveOp = getappdata(handles.figure1,'iActiveOp');
iActiveBehavior = getappdata(handles.figure1,'iActiveBehavior');
iOpeartionOnMouse = getappdata(handles.figure1,'iOpeartionOnMouse');
iActiveMouse = getappdata(handles.figure1,'iActiveMouse');


set(handles.hSelectionAxes,'xLim',aiRect([1,3]),'yLim',aiRect([2,4]))
delete(get(handles.hSelectionAxes,'Children'))
text(20, 120,'Mouse','Color','w','parent',handles.hSelectionAxes);
a2iMouseSelRect= zeros(iNumMice,4);
a2iMouseColor = [0.5 0 0;
    0 0.5 0
    0  0  0.5
    0 0.5 0.5
    0.5 0.5 0
    0.5 0 0.5];
for j=1:iNumMice
    a2iMouseSelRect(j,:) = [120+120*(j-1) 110 100 20];
    if j==iActiveMouse
        rectangle('Position', a2iMouseSelRect(j,:),'FaceColor',2*a2iMouseColor(j,:),'Curvature',1,'parent',handles.hSelectionAxes);
        rectangle('Position',a2iMouseSelRect(j,:) ,'FaceColor','none','EdgeColor','w','Curvature',1,'LineWidth',2,'parent',handles.hSelectionAxes);
        
    else
        rectangle('Position', a2iMouseSelRect(j,:),'FaceColor',a2iMouseColor(j,:),'Curvature',1,'parent',handles.hSelectionAxes);
    end
end

text(20, 90,'    is ','Color','w','parent',handles.hSelectionAxes);

% Draw behaviors
iNumBehaviors=length(strctConfig.m_acBehaviors);
a2iBehaviorSelRect = zeros(iNumBehaviors,4);

a2fColor = jet(iNumBehaviors);


if iActiveBehavior > 7
    aiBehaviorInd = iActiveBehavior-6:iActiveBehavior;
else
    aiBehaviorInd = 1:7;
end
for k=1:length(aiBehaviorInd)
    a2iBehaviorSelRect(k,:) = [110+110*(k-1) 90 100 20];
    if aiBehaviorInd(k) == iActiveBehavior
        text(a2iBehaviorSelRect(k,1),a2iBehaviorSelRect(k,2),strctConfig.m_acBehaviors{aiBehaviorInd(k)}.m_strName,'Color',a2fColor(k,:),'parent',handles.hSelectionAxes,'FontWeight','bold');
        rectangle('Position', a2iBehaviorSelRect(k,:) + [-10 -13 4 3],'FaceColor','none','EdgeColor','w','Curvature',1,'LineWidth',2,'parent',handles.hSelectionAxes);
        
    else
        text(a2iBehaviorSelRect(k,1),a2iBehaviorSelRect(k,2),strctConfig.m_acBehaviors{aiBehaviorInd(k)}.m_strName,'Color',a2fColor(k,:)/2,'parent',handles.hSelectionAxes);
    end
end

if strctConfig.m_acBehaviors{iActiveBehavior}.m_afOperatedOnOtherMice == 1
    text(20, 60,'    Mouse','Color','w','parent',handles.hSelectionAxes);
    for j=1:iNumMice
        a2iMouseSelRect(j,:) = [120+120*(j-1) 50 100 20];
        if j==iOpeartionOnMouse
            rectangle('Position', a2iMouseSelRect(j,:),'FaceColor',a2iMouseColor(j,:),'Curvature',1,'parent',handles.hSelectionAxes);
            rectangle('Position',a2iMouseSelRect(j,:) ,'FaceColor','none','EdgeColor','w','Curvature',1,'LineWidth',2,'parent',handles.hSelectionAxes);
        else
            rectangle('Position', a2iMouseSelRect(j,:),'FaceColor',0.5*a2iMouseColor(j,:),'Curvature',1,'parent',handles.hSelectionAxes);
        end
    end
end

switch iActiveOp
    case 3
        rectangle('Position',[15    45   580    30],'FaceColor','none','EdgeColor','y','Curvature',1,'parent',handles.hSelectionAxes);
    case 2
        rectangle('Position',[15    75  880    30],'FaceColor','none','EdgeColor','y','Curvature',1,'parent',handles.hSelectionAxes);
    case 1
        rectangle('Position',[15    106   580    30],'FaceColor','none','EdgeColor','y','Curvature',1,'parent',handles.hSelectionAxes);
end

return;




% function fnInvalidateAnnotation(handles)
% iCurrMouse = getappdata(handles.figure1,'iCurrMouse');
% iCurrFrame = getappdata(handles.figure1,'iCurrFrame');
% %fnDrawAnnotation(handles,iCurrFrame,iCurrMouse);
% return;

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
strResultsFolder = getappdata(handles.figure1,'strResultsFolder');
[strFile,strPath] = uigetfile([strResultsFolder,'*.mat']);
if strFile(1) == 0
    return;
end;
strPositionFile = [strPath,strFile];
fnLoadNewPositionFile(handles,strPositionFile);

updateLastLoadedFileNames('strTrackingResultsFileName', strPositionFile);

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
% if ~isempty(strctMouseDown) && strcmpi(strctMouseDown.m_strButton,'right') && strcmpi(strctMouseOp.m_strWindow,'Bottom')
%     % Either add new behavior, or change behavior type
%
%
%     iIndex = fnGetSelectedInterval(handles,strctMouseDown);
%     if isempty(iIndex)
%         % add new behavior
%         iNumFrames = getappdata(handles.figure1,'iNumFrames');
%         iCurrMouse = getappdata(handles.figure1,'iCurrMouse');
%         bRightwardDrag = strctMouseOp.m_pt2fPos(1) > strctMouseDown.m_pt2fPos(1);
%
%         iStartFrame = min(round(strctMouseDown.m_pt2fPos(1)),round(strctMouseOp.m_pt2fPos(1)));
%         iEndFrame = max(round(strctMouseDown.m_pt2fPos(1)),round(strctMouseOp.m_pt2fPos(1)));
%
%         if iEndFrame > iStartFrame  && iStartFrame >= 1 && iEndFrame >= 1 && iStartFrame < iNumFrames && iEndFrame <= iNumFrames
%             % crop start and end frames to the nearest position, and make sure
%             % there are no overlaps!
%             aiSelected = find(g_strctBehaviors.m_aiMouseA == iCurrMouse);
%
%             if bRightwardDrag
%                 iNext = find(g_strctBehaviors.m_aiStart(aiSelected) >= iStartFrame,1,'first');
%                 if ~isempty(iNext)
%                     iStartNext = g_strctBehaviors.m_aiStart(aiSelected(iNext));
%                     iEndFrame = min(iEndFrame, iStartNext - 1);
%                 end;
%             else
%                 % leftward drag
%                 iPrev = find(g_strctBehaviors.m_aiEnd(aiSelected) <= iEndFrame,1,'last');
%
%                 if ~isempty(iPrev)
%                     iEndPrev = g_strctBehaviors.m_aiEnd(aiSelected(iPrev));
%                     iStartFrame = max(iStartFrame, iEndPrev+ 1);
%                 end;
%             end;
%             fprintf('Adding new behavior to mouse %d between %d - %d\n',iCurrMouse, iStartFrame, iEndFrame);
%             fnAddNewBehavior(handles, iStartFrame, iEndFrame, iCurrMouse);
%         end;
%     else
%
%     end;
% end;
%
%
% setappdata(handles.figure1,'strctMouseCurr',strctMouseOp);
setappdata(handles.figure1,'strctMouseUp',strctMouseOp);


return;

function [hAxes,strActiveWindow] = fnGetActiveWindow(handles)
hRightAxes = getappdata(handles.figure1,'hRightAxes');
if fnIsInside(hRightAxes)
    hAxes = hRightAxes;
    strActiveWindow = 'Right';
    return;
end
if fnIsInside(handles.hImageAxes)
    hAxes = handles.hImageAxes;
    strActiveWindow = 'Top';
    return;
end
if fnIsInside(handles.hSelectionAxes)
    hAxes = handles.hSelectionAxes;
    strActiveWindow = 'Bottom';
    return;
end
hAxes = [];
strActiveWindow= [];
return;


function fnMouseScroll(obj,eventdata,handles)
fDelta = eventdata.VerticalScrollCount;
[hAxes,strActiveWindow] = fnGetActiveWindow(handles);
if isempty(hAxes)
    return;
end;

if strcmpi(strActiveWindow,'Top')
    iCurrFrame = getappdata(handles.figure1,'iCurrFrame');
    iNumFrames = getappdata(handles.figure1,'iNumFrames');
    iCurrFrame = min(iNumFrames,max(1,iCurrFrame + fDelta));
    set(handles.hFrameSlider,'value',iCurrFrame);
    setappdata(handles.figure1,'iCurrFrame',iCurrFrame);
    fnInvalidate(handles);
end


if strcmpi(strActiveWindow,'Right')
    
    iZoom = getappdata(handles.figure1,'iZoom');
    iZoom = min(10000,max(10,iZoom * (1+ -fDelta/5)));
    setappdata(handles.figure1,'iZoom',iZoom);
    fnInvalidateRightPanel(handles);
end


%fnInvalidateAnnotation(handles);


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
function bInside = fnIsInside(hAxes)
pt2iCurrPoint = get(hAxes,'CurrentPoint');
aiAxis = axis(hAxes);
bInside =  pt2iCurrPoint(1) >= aiAxis(1) &&  pt2iCurrPoint(1) <= aiAxis(2) && ...
    pt2iCurrPoint(3) >= aiAxis(3) &&  pt2iCurrPoint(3) <= aiAxis(4);
return;

function fnPrintMouseOp(strctMouseOp)
fprintf('%s %s in %s window, Pos [%.2f %.2f]\n',...
    strctMouseOp.m_strButton, strctMouseOp.m_strAction, ...
    strctMouseOp.m_strWindow,strctMouseOp.m_pt2fPos(1),strctMouseOp.m_pt2fPos(2));
return;
%set(handles.figure1,'Pointer','watch');


function fnToggleAutoZoom(handles)
bAutoZoom = getappdata(handles.figure1,'bAutoZoom');
bAutoZoom = ~bAutoZoom;
setappdata(handles.figure1,'bAutoZoom',bAutoZoom);
fnInvalidate(handles);

return;


function fnMouseDown(obj,eventdata,handles)
strMouseMoveMode = getappdata(handles.figure1,'strMouseMoveMode');
setappdata(handles.figure1,'bMouseDown',1);
strctMouseOp.m_strButton = fnGetClickType(handles.figure1);
strctMouseOp.m_strAction = 'Down';
[strctMouseOp.m_hAxes, strctMouseOp.m_strWindow] = fnGetActiveWindow(handles);
strctMouseOp.m_pt2fPos = fnGetMouseCoordinate(strctMouseOp.m_hAxes);
strctMouseOp.m_strModeWhenDown = strMouseMoveMode;
strctMouseOp.m_iActiveMouse = getappdata(handles.figure1,'iActiveMouse');
[strctMouseOp.m_iIndex,strctMouseOp.m_strAction,...
    strctMouseOp.m_iOrigLeft,strctMouseOp.m_iOrigRight] =...
    fnGetSelectedInterval(handles,strctMouseOp);

if strcmp(strctMouseOp.m_strButton,'DoubleClick') && ~isempty(strctMouseOp.m_iIndex)
    fnDeleteBehavior(handles,strctMouseOp.m_iIndex);
end

if strcmp(strctMouseOp.m_strButton,'Right') && ~isempty(strctMouseOp.m_iIndex)
    fnGotoBehavior(handles,strctMouseOp.m_iIndex);
end

if ~isempty(strctMouseOp.m_hAxes)
    %     if strcmp(strctMouseOp.m_strButton,'DoubleClick') && strctMouseOp.m_hAxes == handles.hImageAxes
    %         fnToggleAutoZoom(handles);
    %     end
    direction = strcmp(strctMouseOp.m_strButton,'Right') - strcmp(strctMouseOp.m_strButton,'Left');
    if strctMouseOp.m_hAxes == handles.hImageAxes
        fnGotoNextEvent(handles, direction);
    end
    if strctMouseOp.m_hAxes == handles.hSelectionAxes
        if abs(strctMouseOp.m_pt2fPos(2)-120) < 10
            iSelectedMouse = floor(strctMouseOp.m_pt2fPos(1)/120);
            fnGotoNextEvent(handles, direction, iSelectedMouse);
        elseif abs(strctMouseOp.m_pt2fPos(2)-60) < 10
            iOtherMouse = floor(strctMouseOp.m_pt2fPos(1)/120);
            fnGotoNextEvent(handles, direction, 0, iOtherMouse);
        end
    end
end


%[strctMouseOp.m_iMinLeft, strctMouseOp.m_iMaxRight] = fnGetPossibleIntervalChanges(handles, strctMouseOp.m_iIndex);

% if ~isempty(strctMouseOp.m_iIndex)
%     set(handles.hBehaviorList,'value',strctMouseOp.m_iIndex)
% end
%fnPrintMouseOp(strctMouseOp);

setappdata(handles.figure1,'strctMouseDown',strctMouseOp);
setappdata(handles.figure1,'strctMouseCurr',strctMouseOp);
%fnHandleMouseDownEvent(strctMouseOp,handles);

return;


function f=getDumyFrame(direction)
if direction>0
    f =  1e10;
else
    f = -1;
end

function fnGotoNextEvent(handles, direction, iSelectedMouse, iOtherMouse)
%
iCurrFrame = getappdata(handles.figure1, 'iCurrFrame');
astrctBehaviors = getappdata(handles.figure1, 'astrctBehaviors');
aiMice = 1:length(astrctBehaviors);
if isempty(astrctBehaviors) || (nargin==3 && all(aiMice~=iSelectedMouse)) || (nargin==4 && all(aiMice~=iOtherMouse))
    return;
end
if nargin==3
    aiMice = iSelectedMouse;
end
for iMouseInd=aiMice
    aiOtherMouseInd(iMouseInd) = mod(iMouseInd, length(astrctBehaviors)) + 1;
    if ~isempty(astrctBehaviors{iMouseInd})
        aiFrames = direction*[cat(1,astrctBehaviors{iMouseInd}.m_iStart); cat(1,astrctBehaviors{iMouseInd}.m_iEnd)];
        aiOtherMice = [cat(1,astrctBehaviors{iMouseInd}.m_iOtherMouse); cat(1,astrctBehaviors{iMouseInd}.m_iOtherMouse)];
        i = find(aiFrames > direction*iCurrFrame);
        if nargin==4
            j = find(aiOtherMice(i) == iOtherMouse);
            i = i(j);
        end
        if ~isempty(i)
            [aiNewFrame(iMouseInd), j] = min(aiFrames(i));
            aiOtherMouseInd(iMouseInd) =  aiOtherMice(i(j));
        else
            aiNewFrame(iMouseInd) = getDumyFrame(direction);
        end
    else
        aiNewFrame(iMouseInd) = getDumyFrame(direction);
    end
end
if length(aiMice) > 1
    [iNewFrame, iMouseInd] = min(aiNewFrame);
else
    iMouseInd = aiMice;
    iNewFrame = aiNewFrame(iMouseInd);
end
iNewFrame = direction*iNewFrame;
if iNewFrame < 1e10
    fnSetActiveMouse(handles, iMouseInd);
    fnSetOperateOnMouse(handles, aiOtherMouseInd(iMouseInd))
    fnSetActiveFrame(handles, iNewFrame);
end

function fnMouseMove(obj,eventdata,handles)
bMouseDown = getappdata(handles.figure1,'bMouseDown');
strctMouseOp.m_strButton = fnGetClickType(handles.figure1);
strctMouseOp.m_strAction = 'Move';
[strctMouseOp.m_hAxes, strctMouseOp.m_strWindow] = fnGetActiveWindow(handles);
strctMouseOp.m_pt2fPos = fnGetMouseCoordinate(strctMouseOp.m_hAxes);
strctPrevMouseOp = getappdata(handles.figure1,'strctMouseCurr');
setappdata(handles.figure1,'strctMouseCurr', strctMouseOp);
strctMouseDown = getappdata(handles.figure1,'strctMouseDown');
hRightAxes = getappdata(handles.figure1,'hRightAxes');
if hRightAxes == strctMouseOp.m_hAxes
    [iIndex,strAction,iStart,iEnd,strBehavior] = fnGetSelectedInterval(handles,strctMouseOp);
else
    iIndex = [];
end


if ~isempty(iIndex)
    astrctBehaviors = getappdata(handles.figure1,'astrctBehaviors');
    iActiveMouse = getappdata(handles.figure1,'iActiveMouse');
    strctBehavior = astrctBehaviors{iActiveMouse}(iIndex);
    
    
    set(handles.uipanel22,'Title',sprintf('Mouse %d is %s on %d',strctBehavior.m_iMouse,strctBehavior.m_strAction,strctBehavior.m_iOtherMouse));
    if strcmpi(strAction,'LeftDrag')
        set(handles.figure1,'Pointer','left');
    elseif strcmpi(strAction,'RightDrag')
        set(handles.figure1,'Pointer','right');
    else
        set(handles.figure1,'Pointer','fleur');
    end;
else
    set(handles.uipanel22,'Title','');
    set(handles.figure1,'Pointer','arrow');
end

%(iCurrFrame - iLeftFrame) / (2*iZoom+1)

if bMouseDown > 0 && ~isempty(strctMouseOp.m_hAxes) && ~isempty(strctMouseDown) && ~isempty(strctMouseDown.m_hAxes) && ...
        strctMouseOp.m_hAxes == strctMouseDown.m_hAxes
    fnHandleMouseMoveWhileDown(strctPrevMouseOp, strctMouseOp, handles);
end;
return;



function [iIndex,strAction, iStart,iEnd,strBehavior] = fnGetSelectedInterval(handles,strctMouseDown)
global g_strctExperiment
astrctBehaviors = getappdata(handles.figure1,'astrctBehaviors');

iIndex = [];
strAction= [];
iStart = [];
iEnd = [];
strBehavior = '';

if isempty(astrctBehaviors) || isempty(g_strctExperiment)
    return;
end;

iActiveMouse = getappdata(handles.figure1,'iActiveMouse');
iCurrFrame=  getappdata(handles.figure1,'iCurrFrame');
iZoom = getappdata(handles.figure1,'iZoom');
iNumFrames = size(g_strctExperiment.m_a2fX,2);
iLeftFrame = iCurrFrame - iZoom; %max(1,iCurrFrame - iZoom);
iRightFrame = iCurrFrame + iZoom; %min(iNumFrames,iCurrFrame + iZoom);
iWidth = iRightFrame-iLeftFrame+1;
if isempty(astrctBehaviors{iActiveMouse})
    return;
end;
aiStart = cat(1,astrctBehaviors{iActiveMouse}.m_iStart);
aiEnd= cat(1,astrctBehaviors{iActiveMouse}.m_iEnd);

aiSelectedMouseBehaviors = find(aiStart <= iRightFrame & aiEnd >= iLeftFrame);


acBehaveNames = getappdata(handles.figure1,'acBehaveNames');
iNumBehaviors= length(acBehaveNames)/2;
for k=1:length(aiSelectedMouseBehaviors)
    iLeft = max(iLeftFrame, astrctBehaviors{iActiveMouse}(aiSelectedMouseBehaviors(k)).m_iStart);
    iRight = min(iRightFrame, astrctBehaviors{iActiveMouse}(aiSelectedMouseBehaviors(k)).m_iEnd);
    if iRight == iLeft
        continue;
    end;
    iOp = getActionIndex(acBehaveNames, astrctBehaviors{iActiveMouse}(aiSelectedMouseBehaviors(k)).m_strAction);
    fLeftX = (iLeft - iLeftFrame) / iWidth;
    fRightX = (iRight - iLeftFrame) / iWidth ;
    fUpY = (iOp-1) / (iNumBehaviors+2) + 0.1 * 1/(iNumBehaviors+2);
    fDownY = fUpY + 1/(iNumBehaviors+2) - 0.1 * 1/(iNumBehaviors+2);
    if strctMouseDown.m_pt2fPos(1) >= fLeftX && strctMouseDown.m_pt2fPos(1) <= fRightX && ...
            strctMouseDown.m_pt2fPos(2) >= fUpY && strctMouseDown.m_pt2fPos(2) <= fDownY
        
        strBehavior = astrctBehaviors{iActiveMouse}(aiSelectedMouseBehaviors(k)).m_strAction;
        
        iStart=  astrctBehaviors{iActiveMouse}(aiSelectedMouseBehaviors(k)).m_iStart;
        iEnd =astrctBehaviors{iActiveMouse}(aiSelectedMouseBehaviors(k)).m_iEnd;
        iIndex =aiSelectedMouseBehaviors(k);
        
        if (strctMouseDown.m_pt2fPos(1) - fLeftX) / (fRightX-fLeftX) < 0.2 && iLeft == astrctBehaviors{iActiveMouse}(aiSelectedMouseBehaviors(k)).m_iStart
            strAction= 'LeftDrag';
        elseif (strctMouseDown.m_pt2fPos(1) - fLeftX) / (fRightX-fLeftX) > 0.8 && iRight == astrctBehaviors{iActiveMouse}(aiSelectedMouseBehaviors(k)).m_iEnd
            strAction= 'RightDrag';
        else
            strAction= 'CenterDrag';
            end
            
            return;
            
        end
        
end


return;


function fnHandleMouseMoveWhileDown(strctPrevMouseOp, strctMouseOp, handles)
%fnPrintMouseOp(strctMouseOp);
strctMouseDown = getappdata(handles.figure1,'strctMouseDown');
hRightAxes = getappdata(handles.figure1,'hRightAxes');
if  strctMouseOp.m_hAxes == hRightAxes
    if strcmp(strctMouseOp.m_strButton ,'Right') && isempty(strctMouseDown.m_iIndex)
        % Draw the new interval that is being generated...
    end;
    iActiveMouse = getappdata(handles.figure1,'iActiveMouse');
    if strcmp(strctMouseOp.m_strButton ,'Left')
        iCurrFrame = getappdata(handles.figure1,'iCurrFrame');
        iNumFrames = getappdata(handles.figure1,'iNumFrames');
        
        astrctBehaviors = getappdata(handles.figure1,'astrctBehaviors');
        iZoom = getappdata(handles.figure1,'iZoom');
        
        iLeftFrame = iCurrFrame - iZoom; %max(1,iCurrFrame - iZoom);
        iRightFrame = iCurrFrame + iZoom; %min(iNumFrames,iCurrFrame + iZoom);
        iWidth = iRightFrame-iLeftFrame+1;
        
        iMouseFrame = round(iLeftFrame + strctMouseOp.m_pt2fPos(1) * iWidth);
        iMouseFrameDown = round(iLeftFrame + strctMouseDown.m_pt2fPos(1) * iWidth);
        iFrameDiff =  iMouseFrameDown-iMouseFrame;
        
        iMouseFrame = round(iLeftFrame + strctMouseOp.m_pt2fPos(1) * iWidth);
        iMouseFramePrev = round(iLeftFrame + strctPrevMouseOp.m_pt2fPos(1) * iWidth);
        
        if isempty(strctMouseDown.m_iIndex)
            % Pan the entire window
            iCurrFrame = min(iNumFrames,max(1, iCurrFrame  + iMouseFramePrev-iMouseFrame ));
            setappdata(handles.figure1,'iCurrFrame', iCurrFrame);
            fnInvalidate(handles);
            fnInvalidateRightPanel(handles);
        else
            % Shift the selected interval...
            if strcmpi(strctMouseDown.m_strAction,'LeftDrag')
                
                astrctBehaviors{iActiveMouse}(strctMouseDown.m_iIndex).m_iStart= ...
                    max(1,min( astrctBehaviors{iActiveMouse}(strctMouseDown.m_iIndex).m_iEnd-2, iMouseFrame));
            elseif strcmpi(strctMouseDown.m_strAction,'RightDrag')
                astrctBehaviors{iActiveMouse}(strctMouseDown.m_iIndex).m_iEnd= ...
                    min(iNumFrames,max( astrctBehaviors{iActiveMouse}(strctMouseDown.m_iIndex).m_iStart, iMouseFrame));
            else
                iNewLeft = min(iNumFrames,max(1,strctMouseDown.m_iOrigLeft -iFrameDiff));
                iNewRight = min(iNumFrames,max(1,strctMouseDown.m_iOrigRight - iFrameDiff));
                astrctBehaviors{iActiveMouse}(strctMouseDown.m_iIndex).m_iStart = iNewLeft;
                astrctBehaviors{iActiveMouse}(strctMouseDown.m_iIndex).m_iEnd= iNewRight;
            end;
            fnUpdateBehaviorStruct(handles,astrctBehaviors);
            fnInvalidateRightPanel(handles);
        end;
        %    fnInvalidateAnnotation(handles);
        
    end;
end

return;
%
% function fnAddNewBehavior(handles, iStartFrame, iEndFrame, iCurrMouse)
% global g_strctBehaviors
% cmenu = getappdata(handles.figure1,'cmenu');
% iNumMice = getappdata(handles.figure1,'iNumMice');
%
% iDefaultType = 1;
%
% g_strctBehaviors.m_aiStart =  [iStartFrame; g_strctBehaviors.m_aiStart];
% g_strctBehaviors.m_aiEnd =    [iEndFrame; g_strctBehaviors.m_aiEnd ];
% g_strctBehaviors.m_aiType =   [iDefaultType; g_strctBehaviors.m_aiType ];
% g_strctBehaviors.m_aiMouseA = [iCurrMouse; g_strctBehaviors.m_aiMouseA];
% g_strctBehaviors.m_aiMouseB = [0; g_strctBehaviors.m_aiMouseB ];
% g_strctBehaviors.m_aiStartY = [iDefaultType ; g_strctBehaviors.m_aiStartY];
% g_strctBehaviors.m_aiEndY =   [iDefaultType + 1/(iNumMice+1); g_strctBehaviors.m_aiEndY];
%
% afColors = fnGetBehaviorColor(iCurrMouse, 0, iDefaultType,iNumMice);
% hDrawHandle = ...
%     fnDrawRect([iStartFrame, iEndFrame, iDefaultType,iDefaultType + 1/(iNumMice+1)],afColors,cmenu);
%
% g_strctBehaviors.m_ahDrawHandle = hDrawHandle;
%
% %fnInvalidateAnnotation(handles);
%
% return;
%

function fnSaveAnnotations(handles)
strAnnotationFileName = getappdata(handles.figure1,'strAnnotationFileName');
if ~isempty(strAnnotationFileName)
    fnSaveAnnotationsToFile(handles, strAnnotationFileName)
else
    fnSaveAnnotationAs(handles);
end;

return;


function fnSaveAnnotationsToFile(handles, strFileName)
astrctBehaviors = getappdata(handles.figure1,'astrctBehaviors');
strMovieFileName = getappdata(handles.figure1,'strMovieFileName');
% strPositionFile = getappdata(handles.figure1,'strMovieFileName');
setappdata(handles.figure1,'bDataChanged',false);
display(['Saving annotation to ' strFileName]);
% save(strFileName,'astrctBehaviors','strMovieFileName','strPositionFile');%,'strVideoFile','strTrackingResultsFile','iNumMice','fStartTime','fEndTime');
save(strFileName,'astrctBehaviors','strMovieFileName');
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
fprintf('Loading annotation file...');

if exist(strFullFileName,'file')
    strctTmp = load(strFullFileName);
    fnUpdateBehaviorStruct(handles,strctTmp.astrctBehaviors);
    setappdata(handles.figure1,'strAnnotationFileName',strFullFileName);
    fnInvalidateRightPanel(handles);
    fprintf('Done!\n');
end
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
updateLastLoadedFileNames('strAnnotationFileName', strFullFileName);

%strVideoFile = getappdata(handles.figure1,'strVideoFile');
%strTrackingResultsFile = getappdata(handles.figure1,'strTrackingResultsFile');
%fprintf('Saving annotation...');
%save([strPath,strFile],'acAnnotation','strVideoFile','strTrackingResultsFile');
%fprintf('Done!\n');

% fnUpdateBehaviorStruct(handles,strctTmp.astrctBehaviors);
% setappdata(handles.figure1,'strAnnotationFileName',strFullFileName);
fnInvalidateRightPanel(handles);
return;

% --------------------------------------------------------------------
function hResetAnnotation_Callback(hObject, eventdata, handles)
astrctBehaviors = getappdata(handles.figure1,'astrctBehaviors');
fnUpdateBehaviorStruct(handles, cell(size(astrctBehaviors)));
fnInvalidateRightPanel(handles);
return;

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
%fnInvalidateAnnotation(handles);
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
    % set(handles.hAllBeahviorsList,'string','');
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

% function hSortPanel_SelectionChangeFcn(hObject, eventdata, handles)
% strSortOption = get(hObject,'String');
% switch  strSortOption
%     case 'Frames'
%         iType = 0;
%     otherwise
%         iType = fnBehaviorStringToNumber(strSortOption);
% end;
% fnReorderBehaviorList(handles, iType);
% return;

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
    %    fnInvalidateAnnotation(handles);
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
return;

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


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function hFrameSlider_Callback(hObject, eventdata, handles)
iNewFrame = round(get(hObject,'value'));
bMoviePlaying = getappdata(handles.figure1,'bMoviePlaying');
if bMoviePlaying
    setappdata(handles.figure1,'iMovieFrame',iNewFrame);
end
fnSetActiveFrame(handles,iNewFrame)
return;

% --- Executes during object creation, after setting all properties.
function hFrameSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hFrameSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function hFrameScaleSlider_Callback(hObject, eventdata, handles)
% hObject    handle to hFrameScaleSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function hFrameScaleSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hFrameScaleSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in hIdentityListBox.
function hIdentityListBox_Callback(hObject, eventdata, handles)

fnSetActiveMouse(handles,get(hObject,'value'));

% --- Executes during object creation, after setting all properties.
function hIdentityListBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hIdentityListBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in hCurrBehaviorList.
function hCurrBehaviorList_Callback(hObject, eventdata, handles)
% hObject    handle to hCurrBehaviorList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns hCurrBehaviorList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from hCurrBehaviorList


% --- Executes during object creation, after setting all properties.
function hCurrBehaviorList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hCurrBehaviorList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function fnSetActiveBehavior(handles,iSelectedBehavior);
dbg = 1;


% --- Executes on selection change in hAllBeahviorsList.
function hAllBeahviorsList_Callback(hObject, eventdata, handles)
fnSetActiveBehavior(handles,get(hObject,'value'));


% --- Executes during object creation, after setting all properties.
function hAllBeahviorsList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hAllBeahviorsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in hRunCurrBehaviorDetector.
function hRunCurrBehaviorDetector_Callback(hObject, eventdata, handles)
% hObject    handle to hRunCurrBehaviorDetector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu5.
function popupmenu5_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu5 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu5


% --- Executes during object creation, after setting all properties.
function popupmenu5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --------------------------------------------------------------------
function fnDetectUsingClassifier(handles, strClassifierFileName)
%
global g_strctExperiment
for k=1:4
    astrctTrackers(k).m_afX = g_strctExperiment.m_a2fX(k,:);
    astrctTrackers(k).m_afY = g_strctExperiment.m_a2fY(k,:);
    astrctTrackers(k).m_afA = g_strctExperiment.m_a2fA(k,:);
    astrctTrackers(k).m_afB = g_strctExperiment.m_a2fB(k,:);
    astrctTrackers(k).m_afTheta = g_strctExperiment.m_a2fTheta(k,:);
end
clear g_strctExperiment;
iNumMice = length(astrctTrackers);
iNumFrames = length(astrctTrackers(1).m_afX);
astrctBehaviors = getappdata(handles.figure1, 'astrctBehaviors');
if nargin==1
    [strFile,strPath] = uigetfile('*.mat','Select Classifier File');
    if strFile==0
        return;
    end
    strClassifierFileName = [strPath, strFile];
    set(handles.hClassifierListDirText,'String', strPath);
    fnFillClassifierListbox(strPath, handles);
end
load(strClassifierFileName);
if length(astrctBehaviors) < iNumMice
    astrctBehaviors = cell(iNumMice, 1);
else
    astrctBehaviors = fnResetBehavior(astrctBehaviors, sBehaviorType);
end
if exist('strctClassifier')==1 && ~isempty(strctClassifier)
    iBatchFrames = 10000;
    iBatchNum = ceil(iNumFrames/iBatchFrames);
    for iBatch=1:iBatchNum
        fprintf('Start detecting behavior on batch %d out of %d\n',iBatch,iBatchNum);
        astrctBehaviorsBatch = fnCutBehaviorStruct(astrctBehaviors, (iBatch-1)*iBatchFrames+1, iBatch*iBatchFrames);
        astrctTrackersBatch = fnCutTrackerStruct(astrctTrackers, (iBatch-1)*iBatchFrames+1, iBatch*iBatchFrames);
        astrctBehaviorsBatch = fnOferEntryPoint(astrctBehaviorsBatch, astrctTrackersBatch, strctClassifier, BCparams, 15, (iBatch-1)*iBatchFrames+1);
        for iMouse=1:iNumMice
            if ~isempty(astrctBehaviors{iMouse}) && ~isfield(astrctBehaviors{iMouse}(1), 'm_fScore')
                astrctBehaviors = fnAddFieldToStructArray(astrctBehaviors, 'm_fScore', 0)
            end
            astrctBehaviors{iMouse} = [astrctBehaviors{iMouse} astrctBehaviorsBatch{iMouse}];
        end
        %display(['Finished detecting behavior on batch ' num2str(iBatch)]);
    end
    fnUpdateBehaviorStruct(handles,astrctBehaviors);
    fnInvalidateRightPanel(handles);
else
    errordlg([strClassifierFileName ' does not contain a classifier struct "strctClassifier"']);
end
display(['Detect Using Classifier Done.']);
strVideoFile = get(handles.figure1, 'Name');
S = fnBehaviorSummary(astrctBehaviors, sBehaviorType, strVideoFile);


% --------------------------------------------------------------------
function hDetectUsingClassifier_Callback(hObject, eventdata, handles)
%
fnDetectUsingClassifier(handles);

% --------------------------------------------------------------------
function hLearnBehavior_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
global g_strctExperiment
astrctBehaviors = getappdata(handles.figure1,'astrctBehaviors');

for k=1:4
    astrctTrackers(k).m_afX = g_strctExperiment.m_a2fX(k,:);
    astrctTrackers(k).m_afY = g_strctExperiment.m_a2fY(k,:);
    astrctTrackers(k).m_afA = g_strctExperiment.m_a2fA(k,:);
    astrctTrackers(k).m_afB = g_strctExperiment.m_a2fB(k,:);
    astrctTrackers(k).m_afTheta = g_strctExperiment.m_a2fTheta(k,:);
end
%%%%
% acBehaviorType = {'Head Sniffing',  'Following',  'Eating'};
global globalBCparams;
strctClassifier =  fnOferEntryPointLearning(astrctTrackers, astrctBehaviors);
if ~isempty(strctClassifier)
    % generate file names for annotation, param, and classifier files
    [strFile,strPath]=uiputfile('BehaviorClassifier.mat');
    sBehaviorType = globalBCparams.sBehaviorType;
    strMovieFileName = getappdata(handles.figure1,'strMovieFileName');
    BCparams = globalBCparams;
    if strFile~=0
        save([strPath,strFile],'strctClassifier', 'sBehaviorType', 'strMovieFileName', 'BCparams');
        set(handles.hClassifierListDirText,'String', strPath);
        fnFillClassifierListbox(strPath, handles);
    end
end
clear globalBCparams g_strctExperiment;
%%%%
fnInvalidateRightPanel(handles)


% --- Executes on mouse press over axes background.
function hSelectionAxes_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to hSelectionAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --------------------------------------------------------------------
function hClassificationParams_Callback(hObject, eventdata, handles)
% hObject    handle to hParameters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if exist('./Config/globalBCparams.mat','file')
    load './Config/globalBCparams.mat';
    acBehaviorTypes = get(handles.hPopBehaviorFilter, 'String');
    BehaviorClassificationParamsGUI(acBehaviorTypes(2:end));
    clear globalBCparams;
end

% --------------------------------------------------------------------
function hReloadAnnotation_Callback(hObject, eventdata, handles)
% hObject    handle to hReloadAnnotation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if exist('./Config/lastLoadedFileNames.mat','file')
    load './Config/lastLoadedFileNames.mat';
    if ~exist('strAnnotationFileName')
        display(['./Config/lastLoadedFileNames.mat does NOT contain strAnnotationFileName'])
        return;
    end;
    display(['Loading Annotation File: ' strAnnotationFileName])
    fnLoadAnnotation(handles, strAnnotationFileName);
    fnInvalidateRightPanel(handles);
end


% --------------------------------------------------------------------
function hReloadMicePosition_Callback(hObject, eventdata, handles)
% hObject    handle to hReloadMicePosition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% --------------------------------------------------------------------

if exist('./Config/lastLoadedFileNames.mat', 'file')
    load './Config/lastLoadedFileNames.mat';
    if ~exist('strTrackingResultsFileName')
        display(['./Config/lastLoadedFileNames.mat does not contain strTrackingResultsFileName'])
        return;
    end;
    display(['loading tracking file: ' strTrackingResultsFileName])
    fnLoadNewPositionFile(handles, strTrackingResultsFileName);
end

return;

function updateLastLoadedFileNames(varName, varVal)
if exist('./Config/lastLoadedFileNames.mat','file')
    load './Config/lastLoadedFileNames.mat';
    eval([varName ' =  varVal']);
    clear varName varVal;
    save './Config/lastLoadedFileNames.mat';
end


% --------------------------------------------------------------------
function hGetBatch_Callback(hObject, eventdata, handles)
% hObject    handle to GetBatch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fnGetBatch(handles, false);

% --------------------------------------------------------------------
function hGetBatchUnannotated_Callback(hObject, eventdata, handles)
% hObject    handle to hGetBatchUnannotated (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fnGetBatch(handles, true);

% --------------------------------------------------------------------
function fnGetBatch(handles, bUseOnlyUnannotated)
%
global g_strctExperiment

for k=1:4
    astrctTrackers(k).m_afX = g_strctExperiment.m_a2fX(k,:);
    astrctTrackers(k).m_afY = g_strctExperiment.m_a2fY(k,:);
    astrctTrackers(k).m_afA = g_strctExperiment.m_a2fA(k,:);
    astrctTrackers(k).m_afB = g_strctExperiment.m_a2fB(k,:);
    astrctTrackers(k).m_afTheta = g_strctExperiment.m_a2fTheta(k,:);
end

astrctBehaviorsOrig = getappdata(handles.figure1,'astrctBehaviors');
setappdata(handles.figure1, 'astrctBehaviorsOrig', astrctBehaviorsOrig);

iMaxIntervalNum = 10;

astrctBehaviorsBatch = fnChooseBootstapIntervals(astrctBehaviorsOrig, astrctTrackers, iMaxIntervalNum, bUseOnlyUnannotated);
setappdata(handles.figure1,'astrctBehaviorsBatch', astrctBehaviorsBatch);
fnUpdateBehaviorStruct(handles, astrctBehaviorsBatch);
fnInvalidateRightPanel(handles)
display(['Bootstrap batch is ready for editing']);

% --------------------------------------------------------------------
function hMerge_Callback(hObject, eventdata, handles)
% hObject    handle to MergeBatch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

astrctBehaviorsOrig = getappdata(handles.figure1,'astrctBehaviorsOrig');
astrctBehaviorsBatch1 = getappdata(handles.figure1,'astrctBehaviors');
astrctBehaviorsBatch0 = getappdata(handles.figure1,'astrctBehaviorsBatch');
global globalBCparams;
operator = '& ~';
astrctBehaviors = fnCombineAnnotation(astrctBehaviorsOrig, astrctBehaviorsBatch0, globalBCparams.sBehaviorType, operator);
operator = '|';
astrctBehaviors = fnCombineAnnotation(astrctBehaviors, astrctBehaviorsBatch1, globalBCparams.sBehaviorType, operator);
operator = '& ~';
astrctNegativeBehaviors = fnCombineAnnotation(astrctBehaviorsBatch0, astrctBehaviorsBatch1, globalBCparams.sBehaviorType, operator);
astrctBehaviors = fnSetNegativeBehavior(astrctBehaviors, astrctNegativeBehaviors, globalBCparams.sBehaviorType);

fnUpdateBehaviorStruct(handles, astrctBehaviors);
display(['Merge Completed'])


% --------------------------------------------------------------------
function hDetectUsingThresholds_Callback(hObject, eventdata, handles)
% hObject    handle to hDetectUsingThresholds (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

display(['Detect Using Thresholds']);
display(['Preparing Features']);

global g_strctExperiment
% astrctBehaviors = getappdata(handles.figure1,'astrctBehaviors');

for k=1:4
    astrctTrackers(k).m_afX = g_strctExperiment.m_a2fX(k,:);
    astrctTrackers(k).m_afY = g_strctExperiment.m_a2fY(k,:);
    astrctTrackers(k).m_afA = g_strctExperiment.m_a2fA(k,:);
    astrctTrackers(k).m_afB = g_strctExperiment.m_a2fB(k,:);
    astrctTrackers(k).m_afTheta = g_strctExperiment.m_a2fTheta(k,:);
end
clear g_strctExperiment;
%%%%
iNumMice = length(astrctTrackers);
astrctBehaviors = cell(iNumMice, 1);

%%
global globalThresholdsParams;
if isempty(globalThresholdsParams)
  if exist('./Config/globalThresholdsParams.mat','file')
    load './Config/globalThresholdsParams.mat';
  else
    fprintf('Failed to found global threshold param file...');
    return;
  end
end
clear globalThresholdsParams;
iNumFrames = length(astrctTrackers(1).m_afX);
iNumMice = length(astrctTrackers);

astrctBehaviors = getappdata(handles.figure1,'astrctBehaviors');
astrctBehaviorsOut = cell(iNumMice,1);
iBatchFrames =3100;
iBatchNum = ceil(iNumFrames/iBatchFrames);
for iBatch=1:iBatchNum
    display(['Start detecting behavior using thresholds on batch ' num2str(iBatch)]);
    astrctBehaviorsBatch = fnCutBehaviorStruct(astrctBehaviors, (iBatch-1)*iBatchFrames+1, iBatch*iBatchFrames);
    astrctTrackersBatch = fnCutTrackerStruct(astrctTrackers, (iBatch-1)*iBatchFrames+1, iBatch*iBatchFrames);
    astrctBehaviorsBatch = fnDetectUsingThresholds(astrctBehaviorsBatch, astrctTrackersBatch,  (iBatch-1)*iBatchFrames+1);
    for iMouse=1:iNumMice
        astrctBehaviorsOut{iMouse} = [astrctBehaviorsOut{iMouse} astrctBehaviorsBatch{iMouse}];
    end
    display(['Finished detecting behavior  using thresholds on batch ' num2str(iBatch)]);
end
fnUpdateBehaviorStruct(handles,astrctBehaviorsOut);
fnInvalidateRightPanel(handles);
display(['Detect Using Thresholds Done.']);

global globalThresholdsParams;
strVideoFile = get(handles.figure1, 'Name');
S = fnBehaviorSummary(astrctBehaviorsOut, globalThresholdsParams.sBehaviorType, strVideoFile);
clear globalThresholdsParams;


function astrctBehaviors = fnDetectUsingThresholds(astrctBehaviors, astrctTrackers, iStartFrame)
%
iNumMice = length(astrctTrackers);
global globalThresholdsParams;
[iNumPairs, a2iPairs, a2iPairInd]=getSetIndices(~globalThresholdsParams.Features.bMousePair, iNumMice);

%% calc features
aFeatures = [];
for iMouseInd=1:iNumMice
    aFullFeatures = fnCalcMouseFeatures(iMouseInd, astrctTrackers, globalThresholdsParams);
    aFeatures = [aFeatures fnCutRelevantFeatureSegments(aFullFeatures, globalThresholdsParams)];
end
iNumFrames = length(astrctTrackers(1).m_afX);
N1 = sum([globalThresholdsParams.MousePOIs{1}.aPointsNum]);
N2 = sum([globalThresholdsParams.MousePOIs{2}.aPointsNum]);
N = N1 * N2;
M = N1+N2+N;
%% Run algorithm to detect  behaviors...
display(['Actual Detection']);
fMouse1Speed = max(aFeatures(1:N1,:),[],1)/globalThresholdsParams.Features.iSelfTimeScale;
fMouse2Speed = max(aFeatures(N1+1:N1+N2,:),[],1)/globalThresholdsParams.Features.iSelfTimeScale;
fDistance = min(aFeatures(N1+N2+1:M,:),[],1);
fRelativeSpeed = min(aFeatures(M+N1+N2+1:2*M,:),[],1)/globalThresholdsParams.Features.aTimeScales(1);

% setappdata(handles.figure1, 'fMouse1Speed', fMouse1Speed);
% setappdata(handles.figure1, 'fMouse2Speed', fMouse2Speed);
% setappdata(handles.figure1, 'fRelativeSpeed', fRelativeSpeed);
% setappdata(handles.figure1, 'fDistance', fDistance);

bMouse1Speed = fMouse1Speed>=globalThresholdsParams.Thresholds.fMinMouse1Speed & fMouse1Speed<=globalThresholdsParams.Thresholds.fMaxMouse1Speed;
bMouse2Speed = fMouse2Speed>=globalThresholdsParams.Thresholds.fMinMouse2Speed & fMouse2Speed<=globalThresholdsParams.Thresholds.fMaxMouse2Speed;
bDistance = fDistance>=globalThresholdsParams.Thresholds.iMinDistance & fDistance<=globalThresholdsParams.Thresholds.iMaxDistance;
bRelativeSpeed = fRelativeSpeed>=globalThresholdsParams.Thresholds.fMinRelativeSpeed & fRelativeSpeed<=globalThresholdsParams.Thresholds.fMaxRelativeSpeed;

a2bBehaviorPos = reshape((bMouse1Speed & bMouse2Speed & bRelativeSpeed & bDistance)', iNumFrames, iNumPairs)';
iTimeScale = max([globalThresholdsParams.Features.aTimeScales]);
a2bBehaviorPos(:,1:iTimeScale) = 0;

% if astrctBehaviors is not empty, use threshold to filter out unwanted  behaviors
if ~isempty(astrctBehaviors)
    for i=1:length(astrctBehaviors)
        if ~isempty(astrctBehaviors{i})
            abBehaviors = fnConvertBehaviorStructToMatrix(astrctBehaviors, globalThresholdsParams.sBehaviorType, iNumFrames, a2iPairInd, iStartFrame);
            a2bBehaviorPos = a2bBehaviorPos & abBehaviors;
            astrctBehaviors = cell(size(astrctBehaviors)); %reset behaviors before preparing output
            break;
        end
    end
end;

%% format output
display(['Formating Output']);
a2bBehaviorPos(:,[1 iNumFrames]) = 0;
for iPair=1:iNumPairs
    abBehavior = a2bBehaviorPos(iPair,:);
    m = a2iPairs(iPair,:);
    astrctBehaviorsPair= fnConvertVectorToBehaviorStruct(abBehavior, m(2), globalThresholdsParams.sBehaviorType, m(1), false, 3, iStartFrame);
    astrctBehaviors{m(1)} = [astrctBehaviors{m(1)} astrctBehaviorsPair];
end

clear globalThresholdsParams;


% --- Executes during object creation, after setting all properties.
function hBehaviorAxes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hBehaviorAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate hBehaviorAxes

% --------------------------------------------------------------------
function hBootstrap_Callback(hObject, eventdata, handles)
% hObject    handle to hBootstrap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function SetThresholds_Callback(hObject, eventdata, handles)
% hObject    handle to SetThresholds (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if exist('./Config/globalThresholdsParams.mat','file')
    load './Config/globalThresholdsParams.mat';
    acBehaviorTypes = get(handles.hPopBehaviorFilter, 'String');
    ThresholdsParams(acBehaviorTypes(2:end));
    clear globalThresholdsParams;
end

% --------------------------------------------------------------------
% function SubtractAnnotation_Callback(hObject, eventdata, handles)
% strResultsFolder = 'C:\MouseTrack\Data\Results\10.04.19.390_cropped_120-175\'; % getappdata(handles.figure1,'strResultsFolder');
% [strFile,strPath] = uigetfile([strResultsFolder,'Annotation.mat']);
% if strFile(1) == 0
%     return;
% end;
% strFullFileName = [strPath,strFile];
% strctTmp = load(strFullFileName);
% astrctBehaviorsToSub = strctTmp.astrctBehaviors;
% astrctBehaviors = getappdata(handles.figure1, 'astrctBehaviors');
% global globalBCparams;
% astrctBehaviors = fnCombineAnnotation(astrctBehaviors, astrctBehaviorsToSub, globalBCparams.sBehaviorType, '& ~', 3);
% clear globalBCparams;
% 
% fnUpdateBehaviorStruct(handles,astrctBehaviors);
% fnInvalidateRightPanel(handles);
% return;


% --- Executes on button press in hZoom.
function hZoom_Callback(hObject, eventdata, handles)
% hObject    handle to hZoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fnToggleAutoZoom(handles);
return;

% -----------------------------------------------------------------------
function updateIntervalListBox(handles)
%
astrctBehaviors = getappdata(handles.figure1,'astrctBehaviors');
if isempty(astrctBehaviors)
    return;
end;

index = get(handles.hIntervalListBox, 'Value');
aiIntervalListMouseInd = getappdata(handles.figure1, 'aiIntervalListMouseInd');
aiIntervalListIntInd = getappdata(handles.figure1, 'aiIntervalListIntInd');
if ~isempty(aiIntervalListMouseInd) && ~isempty(aiIntervalListIntInd) && index>0 && index<=length(aiIntervalListMouseInd)
    iMouseInd = aiIntervalListMouseInd(index);
    iIntervalInd = aiIntervalListIntInd(index);
end;

strctIntervalListboxConfig = getappdata(handles.figure1, 'strctIntervalListboxConfig');
aiMice = strctIntervalListboxConfig.iSelectedMouse;
if isempty(aiMice) || aiMice==0
    aiMice = 1:length(astrctBehaviors);
end
aiOtherMice = strctIntervalListboxConfig.iOtherMouse;
if isempty(aiOtherMice) || aiOtherMice==0
    aiOtherMice = 1:length(astrctBehaviors);
end
sBehaviorType = strctIntervalListboxConfig.sBehaviorType;
intInd = 0;
iValue = 1;
for i=aiMice
    for j=1:length(astrctBehaviors{i})
        if isempty(sBehaviorType) || isBehaviorType(astrctBehaviors{i}(j).m_strAction, sBehaviorType)
            if any(astrctBehaviors{i}(j).m_iOtherMouse==aiOtherMice)
                intInd = intInd + 1;
                aiIntLen(intInd) = astrctBehaviors{i}(j).m_iEnd - astrctBehaviors{i}(j).m_iStart + 1;
                aiIntStart(intInd) = astrctBehaviors{i}(j).m_iStart;
                aiIntervalListMouseInd(intInd) = i;
                aiIntervalListIntInd(intInd) = j;
                acIntervals{intInd} = sprintf('%5d %5d  %1d %1d  %s',  astrctBehaviors{i}(j).m_iStart, aiIntLen(intInd) , ...
                                                                                                                                            i, astrctBehaviors{i}(j).m_iOtherMouse, ...
                                                                                                                                            astrctBehaviors{i}(j).m_strAction);
                if exist('iMouseInd','var') && exist('iIntervalInd','var') && i==iMouseInd && j==iIntervalInd
                    iValue = intInd;
                end
            end
        end
    end
end
if intInd > 0
    acIntervals = acIntervals';
    sortPerm = 1:length(aiIntLen);
    if strctIntervalListboxConfig.bSortLength
        [L, sortPerm] = sort(aiIntLen, 'descend');
    else
        [S, sortPerm] = sort(aiIntStart, 'ascend');
    end
    acIntervals = acIntervals(sortPerm);
    aiIntervalListMouseInd = aiIntervalListMouseInd(sortPerm);
    aiIntervalListIntInd = aiIntervalListIntInd(sortPerm);
    aiIntStart = aiIntStart(sortPerm);
    setappdata(handles.figure1, 'aiIntervalListMouseInd', aiIntervalListMouseInd);
    setappdata(handles.figure1, 'aiIntervalListIntInd', aiIntervalListIntInd);
    setappdata(handles.figure1, 'aiIntervalListStartFrame', aiIntStart);
    set(handles.hIntervalListBox,'String',acIntervals, 'Value', find(sortPerm==iValue));
else
    setappdata(handles.figure1, 'aiIntervalListMouseInd', 0);
    setappdata(handles.figure1, 'aiIntervalListIntInd', 0);
    setappdata(handles.figure1, 'aiIntervalListStartFrame', 0);
    set(handles.hIntervalListBox,'String',{''});
end
guidata(handles.hIntervalListBox, handles);
drawnow expose
drawnow update
drawnow

% --- Executes on selection change in hIntervalListBox.
function hIntervalListBox_Callback(hObject, eventdata, handles)
% hObject    handle to hIntervalListBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns hIntervalListBox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from hIntervalListBox

index = get(hObject, 'Value');
aiIntervalListMouseInd = getappdata(handles.figure1, 'aiIntervalListMouseInd');
if isempty(aiIntervalListMouseInd)
    return;
end;

aiIntervalListIntInd = getappdata(handles.figure1, 'aiIntervalListIntInd');
iMouseInd = aiIntervalListMouseInd(index);
iIntervalInd = aiIntervalListIntInd(index);
astrctBehaviors = getappdata(handles.figure1,'astrctBehaviors');
if isempty(astrctBehaviors) || iMouseInd == 0
    return;
end;
iCurrFrame = astrctBehaviors{iMouseInd}(iIntervalInd).m_iStart;
iOtherMouse = astrctBehaviors{iMouseInd}(iIntervalInd).m_iOtherMouse;
fnSetActiveMouse(handles, iMouseInd);
fnSetOperateOnMouse(handles, iOtherMouse);
fnSetActiveFrame(handles, iCurrFrame);

% --- Executes on key press with focus on hIntervalListBox and none of its controls.
function hIntervalListBox_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to hIntervalListBox (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

index = get(hObject, 'Value');
aiIntervalListMouseInd = getappdata(handles.figure1, 'aiIntervalListMouseInd');
if isempty(aiIntervalListMouseInd)
    return;
end;

aiIntervalListIntInd = getappdata(handles.figure1, 'aiIntervalListIntInd');
iMouseInd = aiIntervalListMouseInd(index);
iIntervalInd = aiIntervalListIntInd(index);
astrctBehaviors = getappdata(handles.figure1,'astrctBehaviors');
if isempty(astrctBehaviors) || iMouseInd == 0
    return;
end;
c = get(handles.figure1, 'CurrentCharacter');
if  double(c) == 127
    fnDeleteBehavior(handles,iIntervalInd);
    updateIntervalListBox(handles);
elseif c == '-'
    fnNegateBehavior(handles,iIntervalInd);
    updateIntervalListBox(handles);
end

% --- Executes during object creation, after setting all properties.
function hIntervalListBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hIntervalListBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hThresholdsBehavior_Callback(hObject, eventdata, handles)
% hObject    handle to hFilterBehavior (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hFilterBehavior as text
%        str2double(get(hObject,'String')) returns contents of hFilterBehavior as a double

strctIntervalListboxConfig = getappdata(handles.figure1, 'strctIntervalListboxConfig');
strctIntervalListboxConfig.sBehaviorType = get(hObject,'String');
setappdata(handles.figure1, 'strctIntervalListboxConfig', strctIntervalListboxConfig);

% --- Executes during object creation, after setting all properties.
function hFilterBehavior_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hFilterBehavior (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% function [var1,var2] = get_var_names(handles)
% list_entries = get(handles.listbox1,'String');
% index_selected = get(handles.listbox1,'Value');
% if length(index_selected) ~= 2
%  errordlg('You must select two variables',...
%    'Incorrect Selection','modal')
% else
%  var1 = list_entries{index_selected(1)};
%  var2 = list_entries{index_selected(2)};
% end


% --------------------------------------------------------------------
function Untitled_6_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when selected object is changed in hSortPanel.
function hSortPanel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in hSortPanel
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

strctIntervalListboxConfig = getappdata(handles.figure1, 'strctIntervalListboxConfig');
switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'hSortStart'
        strctIntervalListboxConfig.bSortLength = false;
    case 'hSortLength'
        strctIntervalListboxConfig.bSortLength = true;
    otherwise
        % Code for when there is no match.
end
setappdata(handles.figure1, 'strctIntervalListboxConfig', strctIntervalListboxConfig);
updateIntervalListBox(handles);


% --- Executes during object creation, after setting all properties.
function hSortPanel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hSortPanel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on selection change in hPopBehaviorFilter.
function hPopBehaviorFilter_Callback(hObject, eventdata, handles)
% hObject    handle to hPopBehaviorFilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns hPopBehaviorFilter contents as cell array
%        contents{get(hObject,'Value')} returns selected item from hPopBehaviorFilter

contents = cellstr(get(hObject,'String'));
index = get(hObject, 'Value');
strctIntervalListboxConfig = getappdata(handles.figure1, 'strctIntervalListboxConfig');
if index > 1
    strctIntervalListboxConfig.sBehaviorType = contents(index);
else
    strctIntervalListboxConfig.sBehaviorType = '';
end
setappdata(handles.figure1, 'strctIntervalListboxConfig', strctIntervalListboxConfig);
updateIntervalListBox(handles);

% --- Executes during object creation, after setting all properties.
function hPopBehaviorFilter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hPopBehaviorFilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in hFilterActiveMouse.
function hFilterActiveMouse_Callback(hObject, eventdata, handles)
% hObject    handle to hFilterActiveMouse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns hFilterActiveMouse contents as cell array
%        contents{get(hObject,'Value')} returns selected item from hFilterActiveMouse

strctIntervalListboxConfig = getappdata(handles.figure1, 'strctIntervalListboxConfig');
strctIntervalListboxConfig.iSelectedMouse = get(hObject, 'Value') - 1;
setappdata(handles.figure1, 'strctIntervalListboxConfig', strctIntervalListboxConfig);
updateIntervalListBox(handles);

% --- Executes during object creation, after setting all properties.
function hFilterActiveMouse_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hFilterActiveMouse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in hFilterOtherMouse.
function hFilterOtherMouse_Callback(hObject, eventdata, handles)
% hObject    handle to hFilterOtherMouse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns hFilterOtherMouse contents as cell array
%        contents{get(hObject,'Value')} returns selected item from hFilterOtherMouse

strctIntervalListboxConfig = getappdata(handles.figure1, 'strctIntervalListboxConfig');
strctIntervalListboxConfig.iOtherMouse = get(hObject, 'Value') - 1;
setappdata(handles.figure1, 'strctIntervalListboxConfig', strctIntervalListboxConfig);
updateIntervalListBox(handles);


% --- Executes during object creation, after setting all properties.
function hFilterOtherMouse_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hFilterOtherMouse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when uipanel22 is resized.
function uipanel22_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to uipanel22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function [filename, isMat] = fnGetClassifierFileName(handles)
%
index_selected = get(handles.hClassifierList, 'Value');
file_list = get(handles.hClassifierList, 'String');
if isempty(file_list)
    filename = [];
    isMat = false;
    return;
end;
filename = file_list{index_selected};
[path,name,ext,ver] = fileparts(filename);
isMat = strcmp(ext, '.mat');
if exist('.\Config\lastLoadedFileNames.mat','file')
    load('.\Config\lastLoadedFileNames.mat');
    filename = [strClassifierListDirName '\' filename];
else
    filename = [];
end



% --- Executes on selection change in hClassifierList.
function hClassifierList_Callback(hObject, eventdata, handles)
% hObject    handle to hClassifierList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns hClassifierList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from hClassifierList

SelectionType = get(handles.figure1, 'SelectionType');
if strcmp(SelectionType, 'open')
    [filename, isMat] = fnGetClassifierFileName(handles);
    if  isMat
        fnDetectUsingClassifier(handles, filename);
    else
        if exist('.\Config\lastLoadedFileNames.mat','file')
            load('.\Config\lastLoadedFileNames.mat');
            currDir = pwd;
            cd (strClassifierListDirName);
            cd(filename);
            strClassifierListDirName = pwd;
            cd(currDir);
            updateLastLoadedFileNames('strClassifierListDirName', strClassifierListDirName);
            fnFillClassifierListbox(strClassifierListDirName, handles);
        end
    end
end

% --- Executes during object creation, after setting all properties.
function hClassifierList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hClassifierList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% ------------------------------------------------------------
function fnFillClassifierListbox(strClassifierListDirName, handles)
%
strctDir = dir(strClassifierListDirName);
strctDir = [strctDir(find([strctDir.isdir]));dir([strClassifierListDirName '\*.mat'])];
[sorted_names,sorted_index] = sortrows({strctDir.name}');
set(handles.hClassifierList,'String', sorted_names, 'Value', 1)
set(handles.hClassifierListDirText,'String', strClassifierListDirName)
updateLastLoadedFileNames('strClassifierListDirName', strClassifierListDirName);


% --- Executes on button press in hApplyClassifier.
function hApplyClassifier_Callback(hObject, eventdata, handles)
% hObject    handle to hApplyClassifier (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, isMat] = fnGetClassifierFileName(handles);
if  isMat
    fnDetectUsingClassifier(handles, filename);
end

% --- Executes during object creation, after setting all properties.
function hClassifierListDirText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hClassifierListDirText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --------------------------------------------------------------------
function hCombineAnnotations_Callback(hObject, eventdata, handles)
% hObject    handle to hCombineAnnotations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function hDifference_Callback(hObject, eventdata, handles)
% hObject    handle to hDifference (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

strResultsFolder = getappdata(handles.figure1,'strResultsFolder');
[strFile,strPath] = uigetfile([strResultsFolder,'Annotation.mat']);
if strFile(1) == 0
    return;
end;
strFullFileName = [strPath,strFile];
strctTmp = load(strFullFileName);
astrctBehaviors2= strctTmp.astrctBehaviors;
astrctBehaviors1 = getappdata(handles.figure1, 'astrctBehaviors');
global globalBCparams;
astrctBehaviors = fnCombineAnnotation(astrctBehaviors1, astrctBehaviors2, globalBCparams.sBehaviorType, '& ~');
astrctBehaviorsRev = fnCombineAnnotation(astrctBehaviors2, astrctBehaviors1, globalBCparams.sBehaviorType, '& ~');
astrctBehaviorsRev = fnNegateAnnotation(astrctBehaviorsRev, globalBCparams.sBehaviorType);
astrctBehaviors = fnCombineAnnotation(astrctBehaviors, astrctBehaviorsRev, globalBCparams.sBehaviorType, '|');
clear globalBCparams;

fnUpdateBehaviorStruct(handles,astrctBehaviors);
fnInvalidateRightPanel(handles);
return;


% --------------------------------------------------------------------
function hSubtractAnnotation_Callback(hObject, eventdata, handles)
% hObject    handle to hSubtractAnnotation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

strResultsFolder = getappdata(handles.figure1,'strResultsFolder');
[strFile,strPath] = uigetfile([strResultsFolder,'Annotation.mat']);
if strFile(1) == 0
    return;
end;
strFullFileName = [strPath,strFile];
strctTmp = load(strFullFileName);
astrctBehaviorsToSub = strctTmp.astrctBehaviors;
astrctBehaviors = getappdata(handles.figure1, 'astrctBehaviors');
global globalBCparams;
astrctBehaviors = fnCombineAnnotation(astrctBehaviors, astrctBehaviorsToSub, globalBCparams.sBehaviorType, '& ~', 3);
clear globalBCparams;

fnUpdateBehaviorStruct(handles,astrctBehaviors);
fnInvalidateRightPanel(handles);
return;

% --------------------------------------------------------------------
function hAddAnnotation_Callback(hObject, eventdata, handles)
% hObject    handle to hAddAnnotation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

strResultsFolder = getappdata(handles.figure1,'strResultsFolder');
[strFile,strPath] = uigetfile([strResultsFolder,'Annotation.mat']);
if strFile(1) == 0
    return;
end;
if length(strFile)>5 && strcmp(strFile(end-5:end), '.mat.mat')
    strFile(end-2:end) = [];
end
strFullFileName = [strPath,strFile];
strctTmp = load(strFullFileName);
astrctBehaviorsToAdd = strctTmp.astrctBehaviors;
astrctBehaviors = getappdata(handles.figure1, 'astrctBehaviors');
global globalBCparams;
astrctBehaviors = fnCombineAnnotation(astrctBehaviors, astrctBehaviorsToAdd, globalBCparams.sBehaviorType, '|');
clear globalBCparams;

fnUpdateBehaviorStruct(handles,astrctBehaviors);
fnInvalidateRightPanel(handles);
display(['Add Annotation Done']);
return;


% --------------------------------------------------------------------
function hImportOnlyOtherBehaviors_Callback(hObject, eventdata, handles)
% hObject    handle to hImportOnlyOtherBehaviors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

strResultsFolder = getappdata(handles.figure1,'strResultsFolder');
[strFile,strPath] = uigetfile([strResultsFolder,'Annotation.mat']);
if strFile(1) == 0
    return;
end;
strFullFileName = [strPath,strFile];
strctTmp = load(strFullFileName);
astrctBehaviorsToImport = strctTmp.astrctBehaviors;
astrctBehaviors = getappdata(handles.figure1, 'astrctBehaviors');
if length(astrctBehaviorsToImport)<length(astrctBehaviors)
    astrctBehaviorsToImport = [astrctBehaviorsToImport cell(1,length(astrctBehaviors)-length(astrctBehaviorsToImport))];
elseif length(astrctBehaviors)<length(astrctBehaviorsToImport)
    astrctBehaviors = [astrctBehaviors cell(1,length(astrctBehaviorsToImport)-length(astrctBehaviors))];
end
astrctBehaviors = fnSetOtherBehaviors(astrctBehaviors, astrctBehaviorsToImport, globalBCparams.sBehaviorType);
clear globalBCparams;

fnUpdateBehaviorStruct(handles,astrctBehaviors);
fnInvalidateRightPanel(handles);
return;

% --------------------------------------------------------------------
function hImportSelectedBehavior_Callback(hObject, eventdata, handles)
% hObject    handle to hImportSelectedBehavior (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

strResultsFolder = getappdata(handles.figure1,'strResultsFolder');
[strFile,strPath] = uigetfile([strResultsFolder,'Annotation.mat']);
if strFile(1) == 0
    return;
end;
strFullFileName = [strPath,strFile];
strctTmp = load(strFullFileName);
astrctBehaviorsToImport = strctTmp.astrctBehaviors;
astrctBehaviors = getappdata(handles.figure1, 'astrctBehaviors');
global globalBCparams;
if length(astrctBehaviorsToImport)<length(astrctBehaviors)
    astrctBehaviorsToImport = [astrctBehaviorsToImport cell(1,length(astrctBehaviors)-length(astrctBehaviorsToImport))];
elseif length(astrctBehaviors)<length(astrctBehaviorsToImport)
    astrctBehaviors = [astrctBehaviors cell(1,length(astrctBehaviorsToImport)-length(astrctBehaviors))];
end
astrctBehaviors = fnSetSelectedBehaviors(astrctBehaviors, astrctBehaviorsToImport, globalBCparams.sBehaviorType);
clear globalBCparams;

fnUpdateBehaviorStruct(handles,astrctBehaviors);
fnInvalidateRightPanel(handles);
return;


% --------------------------------------------------------------------
function hNegateExtras_Callback(hObject, eventdata, handles)
% hObject    handle to hNegateExtras (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

strResultsFolder = getappdata(handles.figure1,'strResultsFolder');
[strFile,strPath] = uigetfile([strResultsFolder,'Annotation.mat']);
if strFile(1) == 0
    return;
end;
strFullFileName = [strPath,strFile];
strctTmp = load(strFullFileName);
astrctBehaviorsBase = strctTmp.astrctBehaviors;
astrctBehaviors = getappdata(handles.figure1, 'astrctBehaviors');
global globalBCparams;
astrctBehaviors = fnCombineAnnotation(astrctBehaviors, astrctBehaviorsBase, globalBCparams.sBehaviorType, '& ~');
astrctBehaviors = fnAddAnnotatedFalses(astrctBehaviorsBase, astrctBehaviors, globalBCparams.sBehaviorType);
clear globalBCparams;

fnUpdateBehaviorStruct(handles,astrctBehaviors);
fnInvalidateRightPanel(handles);
return;


function fnUpdateBehaviorStruct(handles, astrctBehaviors)
%
setappdata(handles.figure1, 'astrctBehaviors', astrctBehaviors);
updateIntervalListBox(handles);


% --------------------------------------------------------------------
function hNegate_Callback(hObject, eventdata, handles)
% hObject    handle to hNegate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

astrctBehaviors = getappdata(handles.figure1, 'astrctBehaviors');
global globalBCparams;
astrctBehaviors = fnNegateAnnotation(astrctBehaviors, globalBCparams.sBehaviorType);
clear globalBCparams;

fnUpdateBehaviorStruct(handles,astrctBehaviors);
fnInvalidateRightPanel(handles);
return;


% --------------------------------------------------------------------
function hBehaviorSummary_Callback(hObject, eventdata, handles)
% hObject    handle to hBehaviorSummary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

astrctBehaviors = getappdata(handles.figure1, 'astrctBehaviors');
global globalBCparams;
iNumMice = length(astrctBehaviors);
iNumFrames = getappdata(handles.figure1,'iNumFrames');
strVideoFile = get(handles.figure1,'Name');
S = fnBehaviorSummary(astrctBehaviors, globalBCparams.sBehaviorType, strVideoFile);

% [iNumPairs, a2iPairs, a2iPairInd]=getSetIndices(~globalBCparams.Features.bMousePair, iNumMice);
% y = fnConvertBehaviorStructToMatrix(astrctBehaviors, globalBCparams.sBehaviorType, iNumFrames, a2iPairInd);
% sy = sum(y');
% aSy = zeros(iNumMice);
% for k=1:iNumPairs
%     aSy(a2iPairs(k,1), a2iPairs(k,2)) = sy(k);
% end
% display(['aSy = ']);
% display(aSy);
% t = 600;
% w = ones(1,t)/t;
% freq = conv2(double(y), w, 'full');
% freq = freq(:, 1:length(y));
% freq(:, 1:t) = t * bsxfun(@rdivide, freq(:, 1:t), (1:t));
% figure(2);
% N = iNumMice-1;
% for iMouse=1:iNumMice
%     subplot(iNumMice, 1, iMouse), plot(freq((iMouse-1)*N+1:iMouse*N,:)');
%     axis([1 iNumFrames 0 1]);
% end
% 

function afScores = fnBehaviorSummary(astrctBehaviors, sBehaviorType, strVideoFile)
%
afScores = fnAccumulateScores(astrctBehaviors, sBehaviorType);
display(['afScores = ']);
display(afScores);
% slash = findstr(strVideoFile, '\');
% strVideoFile = strVideoFile(slash(end)+1:slash(end)+8);
% strVideoFile(findstr(strVideoFile, '.')) = '_';
% eval(['global afScores_' sBehaviorType strVideoFile ';']);
% eval(['afScores_' sBehaviorType strVideoFile ' = afScores;']);
% eval(['save afScores_' sBehaviorType strVideoFile ' afScores;']);
% 

% --------------------------------------------------------------------
function hCropAnnotation_Callback(hObject, eventdata, handles)
% hObject    handle to hCropAnnotation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

astrctBehaviors = getappdata(handles.figure1, 'astrctBehaviors');
global globalBCparams;
astrctBehaviors = fnCropAnnotation(astrctBehaviors, globalBCparams.sBehaviorType, globalBCparams.aiIntervals);
clear globalBCparams;
fnUpdateBehaviorStruct(handles,astrctBehaviors);
fnInvalidateRightPanel(handles);
return;


% --------------------------------------------------------------------
function hComparisonReport_Callback(hObject, eventdata, handles)
% hObject    handle to hComparisonReport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

strResultsFolder = getappdata(handles.figure1,'strResultsFolder');
[strFile,strPath] = uigetfile([strResultsFolder,'Annotation.mat']);
if strFile(1) == 0
    return;
end;
strFullFileName = [strPath,strFile];
strctTmp = load(strFullFileName);
astrctBehaviors2= strctTmp.astrctBehaviors;
astrctBehaviors1 = getappdata(handles.figure1, 'astrctBehaviors');
iNumFrames = getappdata(handles.figure1,'iNumFrames');
global globalBCparams;
fnCompareBehaviorAnnotationToGroundTruth(astrctBehaviors1, astrctBehaviors2, globalBCparams.sBehaviorType, iNumFrames)
clear globalBCparams;
