function varargout = ThresholdsParams(varargin)
% THRESHOLDSPARAMS M-file for ThresholdsParams.fig
%      THRESHOLDSPARAMS, by itself, creates a new THRESHOLDSPARAMS or raises the existing
%      singleton*.
%
%      H = THRESHOLDSPARAMS returns the handle to a new THRESHOLDSPARAMS or the handle to
%      the existing singleton*.
%
%      THRESHOLDSPARAMS('CALLBACK',hObject,eventData,handles,...) calls the
%      local
%      function named CALLBACK in THRESHOLDSPARAMS.M with the given input arguments.
%
%      THRESHOLDSPARAMS('Property','Value',...) creates a new THRESHOLDSPARAMS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ThresholdsParams_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ThresholdsParams_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ThresholdsParams

% Last Modified by GUIDE v2.5 08-Jul-2010 22:30:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ThresholdsParams_OpeningFcn, ...
                   'gui_OutputFcn',  @ThresholdsParams_OutputFcn, ...
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


% --- Executes just before ThresholdsParams is made visible.
function ThresholdsParams_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ThresholdsParams (see VARARGIN)

% Choose default command line output for ThresholdsParams
handles.output = hObject;

% load ../Configuration/globalThresholdsParams.mat

setappdata(handles.figure1, 'acBehaviors', varargin{1});
fnMergeBehaviors(varargin{1});
global globalThresholdsParams;
set(handles.hBehaviorPop, 'String', fieldnames(globalThresholdsParams.Features.strctBehaviors));
clear globalThresholdsParams

fnResetThresholdsParams(handles);

set(handles.figure1,'WindowButtonDownFcn',{@fnMouseDown,handles});

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ThresholdsParams wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ThresholdsParams_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function fnRefresh(handles)
%
fnMergeBehaviors(getappdata(handles.figure1, 'acBehaviors'));
setGuiToglobalThresholdsParams(handles);

function fnMergeBehaviors(acBehaviors)
%
global globalThresholdsParams;
if ~isfield(globalThresholdsParams.Features, 'strctBehaviors') || ~isstruct(globalThresholdsParams.Features.strctBehaviors)
    acMissing = acBehaviors;
    globalThresholdsParams.Features.strctBehaviors = struct;
else
    acMissing = acBehaviors(~isfield(globalThresholdsParams.Features.strctBehaviors, acBehaviors));
end
default = struct('bElapsedFrames',false, 'bFrequency', false, 'iFreqTimeScale',[]);
for i=1:length(acMissing)
    sMissing = acMissing{i};
    sMissing(sMissing==' ') = '_';
    if ~isfield(globalThresholdsParams.Features.strctBehaviors, sMissing)
        globalThresholdsParams.Features.strctBehaviors = setfield(globalThresholdsParams.Features.strctBehaviors, sMissing, default);
    end
end
clear globalThresholdsParams;


function fMinMouse1Speed_Callback(hObject, eventdata, handles)
% hObject    handle to fMinMouse1Speed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fMinMouse1Speed as text
%        str2double(get(hObject,'String')) returns contents of
%        fMinMouse1Speed as a double

global globalThresholdsParams
globalThresholdsParams.Thresholds.fMinMouse1Speed = str2double(get(hObject,'String'));
clear globalThresholdsParams

% --- Executes during object creation, after setting all properties.
function fMinMouse1Speed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fMinMouse1Speed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fMinMouse2Speed_Callback(hObject, eventdata, handles)
% hObject    handle to fMinMouse2Speed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fMinMouse2Speed as text
%        str2double(get(hObject,'String')) returns contents of fMinMouse2Speed as a double

global globalThresholdsParams
globalThresholdsParams.Thresholds.fMinMouse2Speed = str2double(get(hObject,'String'));
clear globalThresholdsParams

% --- Executes during object creation, after setting all properties.
function fMinMouse2Speed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fMinMouse2Speed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fMinRelativeSpeed_Callback(hObject, eventdata, handles)
% hObject    handle to fMinRelativeSpeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fMinRelativeSpeed as text
%        str2double(get(hObject,'String')) returns contents of fMinRelativeSpeed as a double

global globalThresholdsParams
globalThresholdsParams.Thresholds.fMinRelativeSpeed = str2double(get(hObject,'String'));
clear globalThresholdsParams

% --- Executes during object creation, after setting all properties.
function fMinRelativeSpeed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fMinRelativeSpeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function iMinDistance_Callback(hObject, eventdata, handles)
% hObject    handle to iMinDistance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of iMinDistance as text
%        str2double(get(hObject,'String')) returns contents of iMinDistance as a double

global globalThresholdsParams
globalThresholdsParams.Thresholds.iMinDistance = str2double(get(hObject,'String'));
clear globalThresholdsParams

% --- Executes during object creation, after setting all properties.
function iMinDistance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to iMinDistance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fMaxMouse1Speed_Callback(hObject, eventdata, handles)
% hObject    handle to fMaxMouse1Speed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fMaxMouse1Speed as text
%        str2double(get(hObject,'String')) returns contents of fMaxMouse1Speed as a double

global globalThresholdsParams
globalThresholdsParams.Thresholds.fMaxMouse1Speed = str2double(get(hObject,'String'));
clear globalThresholdsParams

% --- Executes during object creation, after setting all properties.
function fMaxMouse1Speed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fMaxMouse1Speed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fMaxMouse2Speed_Callback(hObject, eventdata, handles)
% hObject    handle to fMaxMouse2Speed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fMaxMouse2Speed as text
%        str2double(get(hObject,'String')) returns contents of fMaxMouse2Speed as a double

global globalThresholdsParams
globalThresholdsParams.Thresholds.fMaxMouse2Speed = str2double(get(hObject,'String'));
clear globalThresholdsParams

% --- Executes during object creation, after setting all properties.
function fMaxMouse2Speed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fMaxMouse2Speed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fMaxRelativeSpeed_Callback(hObject, eventdata, handles)
% hObject    handle to fMaxRelativeSpeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fMaxRelativeSpeed as text
%        str2double(get(hObject,'String')) returns contents of fMaxRelativeSpeed as a double

global globalThresholdsParams
globalThresholdsParams.Thresholds.fMaxRelativeSpeed = str2double(get(hObject,'String'));
clear globalThresholdsParams

% --- Executes during object creation, after setting all properties.
function fMaxRelativeSpeed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fMaxRelativeSpeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function iMaxDistance_Callback(hObject, eventdata, handles)
% hObject    handle to iMaxDistance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of iMaxDistance as text
%        str2double(get(hObject,'String')) returns contents of iMaxDistance as a double

global globalThresholdsParams
globalThresholdsParams.Thresholds.iMaxDistance = str2double(get(hObject,'String'));
clear globalThresholdsParams

% --- Executes during object creation, after setting all properties.
function iMaxDistance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to iMaxDistance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Reset.
function Reset_Callback(hObject, eventdata, handles)
% hObject    handle to Reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fnResetThresholdsParams(handles);

function fnResetThresholdsParams(handles)
%
load './Config/globalThresholdsParams.mat';
fnRefresh(handles);
clear globalThresholdsParams;

% --- Executes on button press in SetAsDefault.
function SetAsDefault_Callback(hObject, eventdata, handles)
% hObject    handle to SetAsDefault (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global globalThresholdsParams;
save './Config/globalThresholdsParams.mat' globalThresholdsParams;
clear globalThresholdsParams;

% --- Executes on button press in Load.
function Load_Callback(hObject, eventdata, handles)
% hObject    handle to Load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

strDefaultPath = '.\Config\Thresholds';
[strFile,strPath] = uigetfile([strDefaultPath,'*.mat']);
if strFile(1) == 0
    return;
end;
strParamFile = [strPath,strFile];
load(strParamFile);
fnRefresh(handles);

% --- Executes on button press in Save.
function Save_Callback(hObject, eventdata, handles)
% hObject    handle to Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

strDefaultPath = '.\Config\Thresholds';
[strFile,strPath] = uiputfile([strDefaultPath,'globalThresholdsParams.mat']);
if strFile(1) == 0
    return;
end;
strParamFile = [strPath,strFile];
global globalThresholdsParams;
save(strParamFile, 'globalThresholdsParams');
clear globalThresholdsParams;


% --- Executes during object creation, after setting all properties.
function Mouse1PointsNum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Mouse1PointsNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function Mouse2PointsNum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Mouse2PointsNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Mouse1NormRadii_Callback(hObject, eventdata, handles)
% hObject    handle to Mouse1NormRadii (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Mouse1NormRadii as text
%        str2double(get(hObject,'String')) returns contents of Mouse1NormRadii as a double

global globalThresholdsParams
str = get(hObject,'String');
if isstrprop(str(str~=' ' & str~=',' & str~='.'), 'digit')
    globalThresholdsParams.MousePOIs{1}.aNormRadii = str2num(str);
    fnDrawPOIs(handles.Mouse1Axes, 1);
end
clear globalThresholdsParams

% --- Executes during object creation, after setting all properties.
function Mouse1NormRadii_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Mouse1NormRadii (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Mouse2NormRadii_Callback(hObject, eventdata, handles)
% hObject    handle to Mouse2NormRadii (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Mouse2NormRadii as text
%        str2double(get(hObject,'String')) returns contents of Mouse2NormRadii as a double

global globalThresholdsParams
str = get(hObject,'String');
if isstrprop(str(str~=' ' & str~=',' & str~='.'), 'digit')
    globalThresholdsParams.MousePOIs{2}.aNormRadii = str2num(str);
    fnDrawPOIs(handles.Mouse2Axes, 2);
end
clear globalThresholdsParams

% --- Executes during object creation, after setting all properties.
function Mouse2NormRadii_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Mouse2NormRadii (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function setGuiToglobalThresholdsParams(handles)
%
global globalThresholdsParams;

acBehaviors = cellstr(get(handles.hBehaviorPop, 'String'));
for i=1:length(acBehaviors)
    sBehaviorNoSpaces = globalThresholdsParams.sBehaviorType;
    sBehaviorNoSpaces(sBehaviorNoSpaces==' ') = '_';
    if strcmp(acBehaviors{i}, globalThresholdsParams.sBehaviorType) || strcmp(acBehaviors{i}, sBehaviorNoSpaces)
        set(handles.hBehaviorPop,  'Value', i);
        break;
    end
end

set(handles.Mouse1PointsNum, 'String', num2str(globalThresholdsParams.MousePOIs{1}.aPointsNum));
set(handles.Mouse1NormRadii, 'String', num2str(globalThresholdsParams.MousePOIs{1}.aNormRadii));
set(handles.Mouse2PointsNum, 'String', num2str(globalThresholdsParams.MousePOIs{2}.aPointsNum));
set(handles.Mouse2NormRadii, 'String', num2str(globalThresholdsParams.MousePOIs{2}.aNormRadii));

set(handles.fMinMouse1Speed, 'String', num2str(globalThresholdsParams.Thresholds.fMinMouse1Speed));
set(handles.fMinMouse2Speed, 'String', num2str(globalThresholdsParams.Thresholds.fMinMouse2Speed));
set(handles.fMaxMouse1Speed, 'String', num2str(globalThresholdsParams.Thresholds.fMaxMouse1Speed));
set(handles.fMaxMouse2Speed, 'String', num2str(globalThresholdsParams.Thresholds.fMaxMouse2Speed));
set(handles.fMinRelativeSpeed, 'String', num2str(globalThresholdsParams.Thresholds.fMinRelativeSpeed));
set(handles.fMaxRelativeSpeed, 'String', num2str(globalThresholdsParams.Thresholds.fMaxRelativeSpeed));
set(handles.iMinDistance, 'String', num2str(globalThresholdsParams.Thresholds.iMinDistance));
set(handles.iMaxDistance, 'String', num2str(globalThresholdsParams.Thresholds.iMaxDistance));

fnDrawPOIs(handles.Mouse1Axes, 1);
fnDrawPOIs(handles.Mouse2Axes, 2);

clear globalThresholdsParams;


function fnDrawPOIs(hAxes, iMouse)
%
afTheta = linspace(0,2*pi,500);
apt2f =  [cos(afTheta); 2*sin(afTheta)];
plot(hAxes,apt2f(1,:), apt2f(2,:), '.bl', 'MarkerSize', 2);
hold(hAxes, 'on');
afTheta = linspace(1.5*pi,1.75*pi,500);
apt2f =  bsxfun(@times, sqrt(afTheta-1.5*pi)+0.99, [cos(afTheta); 2*sin(afTheta)]);
plot(hAxes,apt2f(1,:), apt2f(2,:), '.bl', 'MarkerSize', 2);

global globalThresholdsParams;
POIs = globalThresholdsParams.MousePOIs{iMouse};
clear globalThresholdsParams;
N = min(length(POIs.aPointsNum), length(POIs.aNormRadii));
for iLevel=1:N
    if POIs.aPointsNum(iLevel) == 1
        afTheta = 0.5*pi;
        if isfield(POIs, 'aTheta') && length(POIs.aTheta)>=iLevel
            afTheta = 0.5*pi + POIs.aTheta(iLevel);
        end
    else
        afTheta = linspace(0.5*pi,2.5*pi,POIs.aPointsNum(iLevel)+1);
        afTheta = afTheta(1:end-1);
    end
    apt2f = POIs.aNormRadii(iLevel) * [cos(afTheta); 2*sin(afTheta)];
    plot(hAxes,apt2f(1,:), apt2f(2,:), '*r');
end
axis(hAxes,'off');
axis(hAxes, [-1.5 1.5 -3 2]);
axis(hAxes, 'equal');
hold(hAxes, 'off');

% --- Outputs from this function are returned to the command line.
function varargout = BehaviorClassificationParamsGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in bMouseFrame.
function bMouseFrame_Callback(hObject, eventdata, handles)
% hObject    handle to bMouseFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of bMouseFrame
global globalThresholdsParams
globalThresholdsParams.Features.bMouseFrame = get(hObject,'Value');
clear globalThresholdsParams

% --- Executes on button press in bMousePair.
function bMousePair_Callback(hObject, eventdata, handles)
% hObject    handle to bMousePair (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of bMousePair
global globalThresholdsParams
globalThresholdsParams.Features.bMousePair = get(hObject,'Value');
clear globalThresholdsParams

% --- Executes on button press in bCoordinates.
function bCoordinates_Callback(hObject, eventdata, handles)
% hObject    handle to bCoordinates (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of bCoordinates
global globalThresholdsParams
globalThresholdsParams.Features.bCoordinates = get(hObject,'Value');
clear globalThresholdsParams

% --- Executes on button press in bDistances.
function bDistances_Callback(hObject, eventdata, handles)
% hObject    handle to bDistances (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of bDistances
global globalThresholdsParams
globalThresholdsParams.Features.bDistances = get(hObject,'Value');
clear globalThresholdsParams

function aTimeScales_Callback(hObject, eventdata, handles)
% hObject    handle to aTimeScales (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of aTimeScales as text
%        str2double(get(hObject,'String')) returns contents of aTimeScales as a double
global globalThresholdsParams
globalThresholdsParams.Features.aTimeScales = str2num(get(hObject,'String'));
clear globalThresholdsParams

% --- Executes during object creation, after setting all properties.
function aTimeScales_CreateFcn(hObject, eventdata, handles)
% hObject    handle to aTimeScales (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Mouse1PointsNum_Callback(hObject, eventdata, handles)
% hObject    handle to Mouse1PointsNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Mouse1PointsNum as text
%        str2double(get(hObject,'String')) returns contents of Mouse1PointsNum as a double
global globalThresholdsParams
str = get(hObject,'String');
if isstrprop(str(str~=' ' & str~=','), 'digit')
    globalThresholdsParams.MousePOIs{1}.aPointsNum = str2num(str);
    fnDrawPOIs(handles.Mouse1Axes, 1);
end
clear globalThresholdsParams

% --- Executes during object creation, after setting all properties.
function Mouse1PointsNum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Mouse1PointsNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Mouse2PointsNum_Callback(hObject, eventdata, handles)
% hObject    handle to Mouse2PointsNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Mouse2PointsNum as text
%        str2double(get(hObject,'String')) returns contents of Mouse2PointsNum as a double
global globalThresholdsParams
str = get(hObject,'String');
if isstrprop(str(str~=' ' & str~=','), 'digit')
    globalThresholdsParams.MousePOIs{2}.aPointsNum = str2num(str);
    fnDrawPOIs(handles.Mouse2Axes, 2);
end
clear globalThresholdsParams


function sBehaviorType = fnGetCurrentBehaviorType(handles)
%
acBehaviors = cellstr(get(handles.hBehaviorPop, 'String'));
sBehaviorType = acBehaviors{get(handles.hBehaviorPop,'Value')};


function hBehaviorPop_Callback(hObject, eventdata, handles)
% hObject    handle to hBehaviorPop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hBehaviorPop as text
%        str2double(get(hObject,'String')) returns contents of hBehaviorPop as a double

global globalThresholdsParams
globalThresholdsParams.sBehaviorType = fnGetCurrentBehaviorType(handles);
clear globalThresholdsParams

% --- Executes during object creation, after setting all properties.
function hBehaviorPop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hBehaviorPop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

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

function fnMouseDown(obj,eventdata,handles)
%
fRadiusRes = 0.2;
if fnIsInside(handles.Mouse1Axes)
    iMouse = 1;
    hAxes = handles.Mouse1Axes;
elseif fnIsInside(handles.Mouse2Axes)
    iMouse = 2;
    hAxes = handles.Mouse2Axes;
else
    return;
end
pt2fMouseDownPosition = fnGetMouseCoordinate(hAxes);
if abs(pt2fMouseDownPosition(2)) < 0.005
    fTheta = pi/2;
else
    fTheta = atan(2*abs(pt2fMouseDownPosition(1)/pt2fMouseDownPosition(2)));
end
if pt2fMouseDownPosition(2) > 0
    if pt2fMouseDownPosition(1) > 0
        fTheta = 2*pi - fTheta;
    end
else
    if pt2fMouseDownPosition(1) > 0
        fTheta = pi + fTheta;
    else
        fTheta = pi - fTheta;
    end
end
fNormRadius = fRadiusRes * round(sqrt(pt2fMouseDownPosition(1)^2 + pt2fMouseDownPosition(2)^2/4) / fRadiusRes);
fAngleRes = pi/round(pi/(fRadiusRes/max(0.5/pi*fRadiusRes, fNormRadius)));
fTheta = fAngleRes * round(fTheta / fAngleRes);
fnTogglePOI(handles, iMouse, hAxes, fTheta, fNormRadius, fRadiusRes, fAngleRes);


function fnTogglePOI(handles, iMouse, hAxes, fTheta, fNormRadius, fRadiusRes, fAngleRes)
%
global globalThresholdsParams;
POIs = globalThresholdsParams.MousePOIs{iMouse};
eval(['PointsNumEdit = handles.Mouse' num2str(iMouse) 'PointsNum;']);
eval(['NormRadiiEdit = handles.Mouse' num2str(iMouse) 'NormRadii;']);
aiLeyer = find(abs(POIs.aNormRadii-fNormRadius) < 0.6*fRadiusRes);
status = 0;
for i=1:length(aiLeyer)
    iLeyer = aiLeyer(i);
    if POIs.aPointsNum(iLeyer)==1 && isfield(POIs, 'aTheta') && length(POIs.aTheta)>=iLeyer && ...
            (abs(POIs.aTheta(iLeyer)-fTheta)<0.6*fAngleRes || abs(abs(POIs.aTheta(iLeyer)-fTheta)-2*pi)<0.6*fAngleRes)
        POIs.aNormRadii(iLeyer) = [];
        POIs.aPointsNum(iLeyer) = [];
        POIs.aTheta(iLeyer) = [];
        status = 1;
        break;
    end
end
if status==0
    if ~isfield(POIs, 'aTheta')
        POIs.aTheta = zeros(size(POIs.aPointsNum));
    end
    POIs.aPointsNum = [POIs.aPointsNum 1];
    POIs.aNormRadii = [POIs.aNormRadii fNormRadius];
    POIs.aTheta = [POIs.aTheta fTheta];
    status = 1;
end
if status==1
    globalThresholdsParams.MousePOIs{iMouse} = POIs;
    fnDrawPOIs(hAxes, iMouse);
    set(PointsNumEdit, 'String', num2str(POIs.aPointsNum));
    set(NormRadiiEdit, 'String', num2str(POIs.aNormRadii, '% 4.3g'));
end
clear globalThresholdsParams;


