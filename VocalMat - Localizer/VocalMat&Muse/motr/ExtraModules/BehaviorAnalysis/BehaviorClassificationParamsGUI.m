function varargout = BehaviorClassificationParamsGUI(varargin)
% BEHAVIORCLASSIFICATIONPARAMSGUI M-file for BehaviorClassificationParamsGUI.fig
%      BEHAVIORCLASSIFICATIONPARAMSGUI, by itself, creates a new BEHAVIORCLASSIFICATIONPARAMSGUI or raises the existing
%      singleton*.
%
%      H = BEHAVIORCLASSIFICATIONPARAMSGUI returns the handle to a new BEHAVIORCLASSIFICATIONPARAMSGUI or the handle to
%      the existing singleton*.
%
%      BEHAVIORCLASSIFICATIONPARAMSGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BEHAVIORCLASSIFICATIONPARAMSGUI.M with the given input arguments.
%
%      BEHAVIORCLASSIFICATIONPARAMSGUI('Property','Value',...) creates a new BEHAVIORCLASSIFICATIONPARAMSGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BehaviorClassificationParamsGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to
%      BehaviorClassificationParamsGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help BehaviorClassificationParamsGUI

% Last Modified by GUIDE v2.5 22-Jul-2010 21:33:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @BehaviorClassificationParamsGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @BehaviorClassificationParamsGUI_OutputFcn, ...
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


% --- Executes just before BehaviorClassificationParamsGUI is made visible.
function BehaviorClassificationParamsGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BehaviorClassificationParamsGUI (see VARARGIN)

% Choose default command line output for BehaviorClassificationParamsGUI
handles.output = hObject;

setappdata(handles.figure1, 'acOtherBehaviors', varargin{1});
fnMergeOtherBehaviors(varargin{1});

global globalBCparams
set(handles.hBehaviorPop, 'String', fieldnames(globalBCparams.Features.strctOtherBehaviors));
set(handles.hOtherBehaviorPop, 'String', fieldnames(globalBCparams.Features.strctOtherBehaviors));
clear globalBCparams

fnResetBCparams(handles);

set(handles.figure1,'WindowButtonDownFcn',{@fnMouseDown,handles});

uistack(handles.Mouse1Axes, 'top');
uistack(handles.Mouse2Axes, 'top');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes BehaviorClassificationParamsGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function fnRefresh(handles)
%
fnMergeOtherBehaviors(getappdata(handles.figure1, 'acOtherBehaviors'));
setGuiToglobalBCparams(handles);


function fnMergeOtherBehaviors(acOtherBehaviors)
%
global globalBCparams;
if ~isfield(globalBCparams.Features, 'strctOtherBehaviors') || ~isstruct(globalBCparams.Features.strctOtherBehaviors)
    acMissing = acOtherBehaviors;
    globalBCparams.Features.strctOtherBehaviors = struct;
else
    acMissing = acOtherBehaviors(~isfield(globalBCparams.Features.strctOtherBehaviors, acOtherBehaviors));
end
default = struct('bElapsedFrames',false, 'bFrequency', false, 'iFreqTimeScale',[]);
for i=1:length(acMissing)
    sMissing = acMissing{i};
    sMissing(sMissing==' ') = '_';
    if ~isfield(globalBCparams.Features.strctOtherBehaviors, sMissing)
        globalBCparams.Features.strctOtherBehaviors = setfield(globalBCparams.Features.strctOtherBehaviors, sMissing, default);
    end
end
clear globalBCparams;


function fnDrawPOIs(hAxes, iMouse)
%
afTheta = linspace(0,2*pi,500);
apt2f =  [cos(afTheta); 2*sin(afTheta)];
plot(hAxes,apt2f(1,:), apt2f(2,:), '.bl', 'MarkerSize', 2);
hold(hAxes, 'on');
afTheta = linspace(1.5*pi,1.75*pi,500);
apt2f =  bsxfun(@times, sqrt(afTheta-1.5*pi)+0.99, [cos(afTheta); 2*sin(afTheta)]);
plot(hAxes,apt2f(1,:), apt2f(2,:), '.bl', 'MarkerSize', 2);

global globalBCparams;
POIs = globalBCparams.MousePOIs{iMouse};
clear globalBCparams;
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
global globalBCparams
globalBCparams.Features.bMouseFrame = get(hObject,'Value');
clear globalBCparams

% --- Executes on button press in bMousePair.
function bMousePair_Callback(hObject, eventdata, handles)
% hObject    handle to bMousePair (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of bMousePair
global globalBCparams
globalBCparams.Features.bMousePair = get(hObject,'Value');
clear globalBCparams

% --- Executes on button press in bCoordinates.
function bCoordinates_Callback(hObject, eventdata, handles)
% hObject    handle to bCoordinates (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of bCoordinates
global globalBCparams
globalBCparams.Features.bCoordinates = get(hObject,'Value');
clear globalBCparams

% --- Executes on button press in bDistances.
function bDistances_Callback(hObject, eventdata, handles)
% hObject    handle to bDistances (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of bDistances
global globalBCparams
globalBCparams.Features.bDistances = get(hObject,'Value');
clear globalBCparams


% --- Executes on button press in hCdiff.
function hCdiff_Callback(hObject, eventdata, handles)
% hObject    handle to hCdiff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hCdiff

global globalBCparams
globalBCparams.Features.bCdiff = get(hObject,'Value');
clear globalBCparams

% --- Executes on button press in hDdiff.
function hDdiff_Callback(hObject, eventdata, handles)
% hObject    handle to hDdiff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hDdiff

global globalBCparams
globalBCparams.Features.bDdiff = get(hObject,'Value');
clear globalBCparams

% --- Executes on button press in hThresholdLike.
function hThresholdLike_Callback(hObject, eventdata, handles)
% hObject    handle to hThresholdLike (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hThresholdLike

global globalBCparams
globalBCparams.Features.bThresholdLike = get(hObject,'Value');
clear globalBCparams

function aTimeScales_Callback(hObject, eventdata, handles)
% hObject    handle to aTimeScales (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of aTimeScales as text
%        str2double(get(hObject,'String')) returns contents of aTimeScales as a double

str = get(hObject,'String');
if isempty(str)
   str = '0';
end
global globalBCparams
globalBCparams.Features.aTimeScales = str2num(str);
clear globalBCparams

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
global globalBCparams
str = get(hObject,'String');
if isstrprop(str(str~=' ' & str~=',' & str~='.'), 'digit')
    globalBCparams.MousePOIs{1}.aPointsNum = str2num(str);
    fnDrawPOIs(handles.Mouse1Axes, 1);
end
clear globalBCparams

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
global globalBCparams
str = get(hObject,'String');
if isstrprop(str(str~=' ' & str~=',' & str~='.'), 'digit')
    globalBCparams.MousePOIs{2}.aPointsNum = str2num(str);
    fnDrawPOIs(handles.Mouse2Axes, 2);
end
clear globalBCparams

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

global globalBCparams
str = get(hObject,'String');
if isstrprop(str(str~=' ' & str~=',' & str~='.'), 'digit')
    globalBCparams.MousePOIs{1}.aNormRadii = str2num(str);
    fnDrawPOIs(handles.Mouse1Axes, 1);
end
clear globalBCparams

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
global globalBCparams
str = get(hObject,'String');
if isstrprop(str(str~=' ' & str~=',' & str~='.'), 'digit')
    globalBCparams.MousePOIs{2}.aNormRadii = str2num(str);
    fnDrawPOIs(handles.Mouse2Axes, 2);
end
clear globalBCparams

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



function FramePOIsX_Callback(hObject, eventdata, handles)
% hObject    handle to FramePOIsX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FramePOIsX as text
%        str2double(get(hObject,'String')) returns contents of FramePOIsX as a double
global globalBCparams
globalBCparams.FramePOIs.aX= str2num(get(hObject,'String'));
clear globalBCparams

% --- Executes during object creation, after setting all properties.
function FramePOIsX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FramePOIsX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FramePOIsY_Callback(hObject, eventdata, handles)
% hObject    handle to FramePOIsY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FramePOIsY as text
%        str2double(get(hObject,'String')) returns contents of FramePOIsY as a double
global globalBCparams
globalBCparams.FramePOIs.aY= str2num(get(hObject,'String'));
clear globalBCparams

% --- Executes during object creation, after setting all properties.
function FramePOIsY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FramePOIsY (see GCBO)
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

fnResetBCparams(handles);


function fnResetBCparams(handles)
%
load './Config/globalBCparams.mat';
fnRefresh(handles);
clear globalBCparams;

% --- Executes on button press in SetAsDefault.
function SetAsDefault_Callback(hObject, eventdata, handles)
% hObject    handle to SetAsDefault (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global globalBCparams;
save './Config/globalBCparams.mat' globalBCparams;
clear globalBCparams;

% --- Executes on button press in Load.
function Load_Callback(hObject, eventdata, handles)
% hObject    handle to Load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

strDefaultPath = '..\Data\Results\10.04.19.390_cropped_120-175\';
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

strDefaultPath = '..\Data\Results\10.04.19.390_cropped_120-175\';
[strFile,strPath] = uiputfile([strDefaultPath,'globalBCparams.mat']);
if strFile(1) == 0
    return;
end;
strParamFile = [strPath,strFile];
global globalBCparams;
save(strParamFile, 'globalBCparams');
clear globalBCparams;

%
function setGuiToglobalBCparams(handles)
%
global globalBCparams;

acBehaviors = cellstr(get(handles.hBehaviorPop, 'String'));
for i=1:length(acBehaviors)
    sBehaviorNoSpaces = globalBCparams.sBehaviorType;
    sBehaviorNoSpaces(sBehaviorNoSpaces==' ') = '_';
    if strcmp(acBehaviors{i}, globalBCparams.sBehaviorType) || strcmp(acBehaviors{i}, sBehaviorNoSpaces)
        set(handles.hBehaviorPop,  'Value', i);
        break;
    end
end

intervals = globalBCparams.aiIntervals;
intervals = intervals';
intervals = num2str(intervals(:)');
if strcmp(intervals(end-1:end), ' 0')
    intervals = [intervals(1:end-1) ' End'];
end
set(handles.hIntervals, 'String', intervals);

set(handles.iMaxNrounds, 'String', num2str(globalBCparams.Boosting.iMaxNrounds));
set(handles.fLookNoFurtherError, 'String', num2str(globalBCparams.Boosting.fLookNoFurtherError));
set(handles.fNegPosRatio, 'String', num2str(globalBCparams.Boosting.fNegPosRatio));
set(handles.GapLengthEdit, 'String', num2str(globalBCparams.Boosting.iGapLength));
set(handles.NegativeSandwich, 'Value', globalBCparams.Boosting.bNegativeSandwich);
set(handles.RandomNegative, 'Value', globalBCparams.Boosting.bRandomNegative);
set(handles.hMaxMissRate, 'String', num2str(100*globalBCparams.Boosting.fMaxMissRate));
set(handles.hMaxIterations, 'String', num2str(globalBCparams.Boosting.iMaxIterations));
set(handles.hWeightSchemeSlider, 'Value', globalBCparams.Boosting.fWeightScheme);

set(handles.bMouseFrame, 'Value', globalBCparams.Features.bMouseFrame);
set(handles.bMousePair, 'Value', globalBCparams.Features.bMousePair);
set(handles.bCoordinates, 'Value', globalBCparams.Features.bCoordinates);
set(handles.bDistances, 'Value', globalBCparams.Features.bDistances);
set(handles.hCdiff, 'Value', globalBCparams.Features.bCdiff);
set(handles.hDdiff, 'Value', globalBCparams.Features.bDdiff);
set(handles.hThresholdLike, 'Value', globalBCparams.Features.bThresholdLike);

set(handles.iSelfTimeScale, 'String', num2str(globalBCparams.Features.iSelfTimeScale));
set(handles.aTimeScales, 'String', num2str(globalBCparams.Features.aTimeScales));

sOtherBehavior = fnGetCurrentOtherBehavior(handles);
strctOtherBehavior = getfield(globalBCparams.Features.strctOtherBehaviors, sOtherBehavior);
set(handles.hElapsedFrames, 'Value', strctOtherBehavior.bElapsedFrames);
set(handles.hFrequency, 'Value', strctOtherBehavior.bFrequency);
set(handles.hFreqTimeScale, 'String', num2str(strctOtherBehavior.iFreqTimeScale));

set(handles.Mouse1PointsNum, 'String', num2str(globalBCparams.MousePOIs{1}.aPointsNum));
set(handles.Mouse1NormRadii, 'String', num2str(globalBCparams.MousePOIs{1}.aNormRadii));
set(handles.Mouse2PointsNum, 'String', num2str(globalBCparams.MousePOIs{2}.aPointsNum));
set(handles.Mouse2NormRadii, 'String', num2str(globalBCparams.MousePOIs{2}.aNormRadii));

set(handles.FramePOIsX, 'String', num2str(globalBCparams.FramePOIs.aX));
set(handles.FramePOIsY, 'String', num2str(globalBCparams.FramePOIs.aY));

fnDrawPOIs(handles.Mouse1Axes, 1);
fnDrawPOIs(handles.Mouse2Axes, 2);

clear globalBCparams;


% --- Executes during object creation, after setting all properties.
function Mouse1Axes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Mouse1Axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate Mouse1Axes

% --- Executes during object creation, after setting all properties.
function Mouse2Axes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Mouse2Axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate Mouse2Axes



function iMaxNrounds_Callback(hObject, eventdata, handles)
% hObject    handle to iMaxNrounds (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of iMaxNrounds as text
%        str2double(get(hObject,'String')) returns contents of iMaxNrounds as a double

global globalBCparams;
globalBCparams.Boosting.iMaxNrounds = str2double(get(hObject,'String'));
clear globalBCparams;

% --- Executes during object creation, after setting all properties.
function iMaxNrounds_CreateFcn(hObject, eventdata, handles)
% hObject    handle to iMaxNrounds (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fLookNoFurtherError_Callback(hObject, eventdata, handles)
% hObject    handle to fLookNoFurtherError (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fLookNoFurtherError as text
%        str2double(get(hObject,'String')) returns contents of fLookNoFurtherError as a double

global globalBCparams;
globalBCparams.Boosting.fLookNoFurtherError = str2double(get(hObject,'String'));
clear globalBCparams;


% --- Executes during object creation, after setting all properties.
function fLookNoFurtherError_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fLookNoFurtherError (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function fNegPosRatio_Callback(hObject, eventdata, handles)
% hObject    handle to fNegPosRatio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fNegPosRatio as text
%        str2double(get(hObject,'String')) returns contents of fNegPosRatio as a double

global globalBCparams;
globalBCparams.Boosting.fNegPosRatio = str2double(get(hObject,'String'));
clear globalBCparams;


% --- Executes during object creation, after setting all properties.
function fNegPosRatio_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fNegPosRatio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GapLengthEdit_Callback(hObject, eventdata, handles)
% hObject    handle to GapLengthEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GapLengthEdit as text
%        str2double(get(hObject,'String')) returns contents of GapLengthEdit as a double

global globalBCparams;
globalBCparams.Boosting.iGapLength = str2double(get(hObject,'String'));
clear globalBCparams;


% --- Executes during object creation, after setting all properties.
function GapLengthEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GapLengthEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in NegativeSandwich.
function NegativeSandwich_Callback(hObject, eventdata, handles)
% hObject    handle to NegativeSandwich (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of NegativeSandwich

global globalBCparams;
globalBCparams.Boosting.bNegativeSandwich = get(hObject,'Value');
clear globalBCparams;


% --- Executes on button press in RandomNegative.
function RandomNegative_Callback(hObject, eventdata, handles)
% hObject    handle to RandomNegative (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RandomNegative

global globalBCparams;
globalBCparams.Boosting.bRandomNegative = get(hObject,'Value');
clear globalBCparams;



function iSelfTimeScale_Callback(hObject, eventdata, handles)
% hObject    handle to iSelfTimeScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of iSelfTimeScale as text
%        str2double(get(hObject,'String')) returns contents of iSelfTimeScale as a double

str = get(hObject,'String');
if isempty(str)
   str = '0';
end
global globalBCparams
globalBCparams.Features.iSelfTimeScale = str2num(str);
clear globalBCparams

% --- Executes during object creation, after setting all properties.
function iSelfTimeScale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to iSelfTimeScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function hBehaviorPop_Callback(hObject, eventdata, handles)
% hObject    handle to hBehaviorPop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hBehaviorPop as text
%        str2double(get(hObject,'String')) returns contents of hBehaviorPop as a double

global globalBCparams;
globalBCparams.sBehaviorType = fnGetCurrentBehaviorType(handles);
clear globalBCparams;

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



function hMaxMissRate_Callback(hObject, eventdata, handles)
% hObject    handle to hMaxMissRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hMaxMissRate as text
%        str2double(get(hObject,'String')) returns contents of hMaxMissRate as a double

global globalBCparams;
globalBCparams.Boosting.fMaxMissRate = str2double(get(hObject,'String'))/100;
clear globalBCparams;

% --- Executes during object creation, after setting all properties.
function hMaxMissRate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hMaxMissRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hMaxIterations_Callback(hObject, eventdata, handles)
% hObject    handle to hMaxIterations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hMaxIterations as text
%        str2double(get(hObject,'String')) returns contents of hMaxIterations as a double

global globalBCparams;
globalBCparams.Boosting.iMaxIterations = str2double(get(hObject,'String'));
clear globalBCparams;

% --- Executes during object creation, after setting all properties.
function hMaxIterations_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hMaxIterations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in hOtherBehaviorPop.
function hOtherBehaviorPop_Callback(hObject, eventdata, handles)
% hObject    handle to hOtherBehaviorPop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns hOtherBehaviorPop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from hOtherBehaviorPop

setGuiToglobalBCparams(handles);

% --- Executes during object creation, after setting all properties.
function hOtherBehaviorPop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hOtherBehaviorPop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on SetAsDefault and none of its controls.
function SetAsDefault_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to SetAsDefault (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

function sBehaviorType = fnGetCurrentBehaviorType(handles)
%
acBehaviors = cellstr(get(handles.hBehaviorPop, 'String'));
sBehaviorType = acBehaviors{get(handles.hBehaviorPop,'Value')};

function sOtherBehavior = fnGetCurrentOtherBehavior(handles)
%
acOtherBehaviors = cellstr(get(handles.hOtherBehaviorPop, 'String'));
sOtherBehavior = acOtherBehaviors{get(handles.hOtherBehaviorPop,'Value')};

function fnUpdateCurrentOtherBehavior(sFeature, handles)
%
sOtherBehavior = fnGetCurrentOtherBehavior(handles);
global globalBCparams;
strctOtherBehavior = getfield(globalBCparams.Features.strctOtherBehaviors, sOtherBehavior);
if strcmp(eval(['get(handles.h'  sFeature(2:end) ',''Style'')']), 'edit')
    value = str2num(eval(['get(handles.h'  sFeature(2:end) ',''String'')']));
else
    value = eval(['get(handles.h'  sFeature(2:end) ',''Value'')']);
end
strctOtherBehavior = setfield(strctOtherBehavior, sFeature, value);
globalBCparams.Features.strctOtherBehaviors = setfield(globalBCparams.Features.strctOtherBehaviors, sOtherBehavior, strctOtherBehavior);
clear globalBCparams;


% --- Executes on button press in hElapsedFrames.
function hElapsedFrames_Callback(hObject, eventdata, handles)
% hObject    handle to hElapsedFrames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hElapsedFrames

fnUpdateCurrentOtherBehavior('bElapsedFrames', handles);
% global globalBCparams;
% sOtherBehavior = fnGetCurrentOtherBehavior(handles);
% strctOtherBehavior = getfield(globalBCparams.Features.strctOtherBehaviors, sOtherBehavior);
% strctOtherBehavior.bElapsedFrames = get(hObject, 'Value');
% globalBCparams.Features.strctOtherBehaviors = setfield(globalBCparams.Features.strctOtherBehaviors, sOtherBehavior, strctOtherBehavior);
% clear globalBCparams;

% --- Executes on button press in hFrequency.
function hFrequency_Callback(hObject, eventdata, handles)
% hObject    handle to hFrequency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hFrequency

fnUpdateCurrentOtherBehavior('bFrequency', handles);


function hFreqTimeScale_Callback(hObject, eventdata, handles)
% hObject    handle to hFreqTimeScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hFreqTimeScale as text
%        str2double(get(hObject,'String')) returns contents of hFreqTimeScale as a double

fnUpdateCurrentOtherBehavior('iFreqTimeScale', handles);


% --- Executes during object creation, after setting all properties.
function hFreqTimeScale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hFreqTimeScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function hIntervals_Callback(hObject, eventdata, handles)
% hObject    handle to hIntervals (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hIntervals as text
%        str2double(get(hObject,'String')) returns contents of hIntervals as a double

global globalBCparams;
str = get(hObject,'String');
if isempty(str)
    globalBCparams.aiIntervals = 1;
end
if isstrprop(str(str~=' ' & str~=','), 'digit')
    intervals = round(str2num(str));
    if mod(length(intervals),2)==1
        intervals = [intervals 0];
    end
    globalBCparams.aiIntervals = reshape(intervals', 2, [])'; 
end
clear globalBCparams;
setGuiToglobalBCparams(handles);

% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


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
fRadiusRes = 1/8;
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
global globalBCparams;
POIs = globalBCparams.MousePOIs{iMouse};
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
    globalBCparams.MousePOIs{iMouse} = POIs;
    fnDrawPOIs(hAxes, iMouse);
    set(PointsNumEdit, 'String', num2str(POIs.aPointsNum));
    set(NormRadiiEdit, 'String', num2str(POIs.aNormRadii, '% 4.3g'));
end
clear globalBCparams;


% --- Executes on slider movement.
function hWeightSchemeSlider_Callback(hObject, eventdata, handles)
% hObject    handle to hWeightSchemeSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

global globalBCparams;
globalBCparams.Boosting.fWeightScheme = get(hObject,'Value');
clear globalBCparams;


% --- Executes during object creation, after setting all properties.
function hWeightSchemeSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hWeightSchemeSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function hPosNegWeight_Callback(hObject, eventdata, handles)
% hObject    handle to hPosNegWeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

global globalBCparams;
globalBCparams.Boosting.fPosNegWeight = get(hObject,'Value');
clear globalBCparams;

% --- Executes during object creation, after setting all properties.
function hPosNegWeight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hPosNegWeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
