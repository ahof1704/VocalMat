function varargout = BackgroundDiffGUI(varargin)
% BACKGROUNDDIFFGUI M-file for BackgroundDiffGUI.fig
%      BACKGROUNDDIFFGUI, by itself, creates a new BACKGROUNDDIFFGUI or raises the existing
%      singleton*.
%
%      H = BACKGROUNDDIFFGUI returns the handle to a new BACKGROUNDDIFFGUI or the handle to
%      the existing singleton*.
%
%      BACKGROUNDDIFFGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BACKGROUNDDIFFGUI.M with the given input arguments.
%
%      BACKGROUNDDIFFGUI('Property','Value',...) creates a new BACKGROUNDDIFFGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BackgroundDiffGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BackgroundDiffGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help BackgroundDiffGUI

% Last Modified by GUIDE v2.5 27-Jan-2011 11:45:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @BackgroundDiffGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @BackgroundDiffGUI_OutputFcn, ...
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


% --- Executes just before BackgroundDiffGUI is made visible.
function BackgroundDiffGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BackgroundDiffGUI (see VARARGIN)

% Choose default command line output for BackgroundDiffGUI
global g_strctGlobalParam
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
strctMovInfo = varargin{1};
strResultsFolder=varargin{2};
setappdata(handles.figure1,'strResultsFolder',strResultsFolder);
setappdata(handles.figure1,'strctMovInfo',strctMovInfo);
set(handles.figure1,'Name',strctMovInfo.m_strFileName);
I=fnReadFrameFromVideo(strctMovInfo,1);
hImage = image([], [], I, 'BusyAction', 'cancel', 'Parent', handles.axes1, 'Interruptible', 'off','CDataMapping', 'scaled');
hImage2 = image([], [], I, 'BusyAction', 'cancel', 'Parent', handles.axes3, 'Interruptible', 'off','CDataMapping', 'scaled');
hImage3 = image([], [], I, 'BusyAction', 'cancel', 'Parent', handles.axes4, 'Interruptible', 'off','CDataMapping', 'scaled');
hImage4 = image([], [], I, 'BusyAction', 'cancel', 'Parent', handles.axes6, 'Interruptible', 'off','CDataMapping', 'scaled');
hold(handles.axes6,'on')
colormap gray
setappdata(handles.figure1,'hImage',hImage);
setappdata(handles.figure1,'hImage2',hImage2);
setappdata(handles.figure1,'hImage3',hImage3);
setappdata(handles.figure1,'hImage4',hImage4);
colormap gray
set(handles.axes1,'visible','off')
set(handles.axes3,'visible','off')
set(handles.axes4,'visible','off')
set(handles.axes6,'visible','off')

set(handles.axes1,'units','pixels');
set(handles.slider1, 'min',1,'max',strctMovInfo.m_iNumFrames,'sliderstep',[1/strctMovInfo.m_iNumFrames 10/strctMovInfo.m_iNumFrames], 'value',1);

set(handles.hSubmit,'enable','off');



strctBackground.m_strMethod = 'FrameDiff_v6';
strctBackground.m_fMotionThreshold = g_strctGlobalParam.m_strctBackgroundSubtraction.m_fMotionThreshold;  % Larger than this frame difference
strctBackground.m_fIntensityThresholdInFloor = 0.3; % Lower than this intensity

strctBackground.m_iStartFrame = 1;
strctBackground.m_iEndFrame = strctMovInfo.m_iNumFrames;
strctBackground.m_iNumImagesForBuffer = 50;

strctBackground.m_fMotionThresholdOut =  g_strctGlobalParam.m_strctBackgroundSubtraction.m_fMotionThresholdOut;
strctBackground.m_fIntensityThresholdOutsideFloor =g_strctGlobalParam.m_strctBackgroundSubtraction.m_fIntensityThresholdOutsideFloor;
strctBackground.m_fMoreMult = 1.16;
strctBackground.m_fDilation = 8;
strctBackground.m_fLargeCC= 100;
set(handles.hMotionThreshold,'String',num2str(strctBackground.m_fMotionThreshold));
set(handles.hMotionThresholdOutside,'String',num2str(strctBackground.m_fMotionThresholdOut));
set(handles.hThresholdInside,'String',num2str(strctBackground.m_fIntensityThresholdInFloor));
set(handles.hThresholdOutside,'String',num2str(strctBackground.m_fIntensityThresholdOutsideFloor));
set(handles.hIntensityMult,'String',num2str(strctBackground.m_fMoreMult));
set(handles.hLargeCC,'String',num2str(strctBackground.m_fLargeCC));
set(handles.hDilationEdit,'String',num2str(strctBackground.m_fDilation));


set(handles.hStartFrameEdit,'String',num2str(strctBackground.m_iStartFrame));
set(handles.hEndFrameEdit,'String',num2str(strctBackground.m_iEndFrame));
set(handles.hNumFramesEdit,'String',num2str(strctBackground.m_iNumImagesForBuffer));


setappdata(handles.figure1,'strctBackground',strctBackground);
setappdata(handles.figure1,'iCurrFrame',1);

uiwait(handles.figure1);
return;

function fnInvalidate(handles)
strctBackground = getappdata(handles.figure1,'strctBackground');
strctMovInfo = getappdata(handles.figure1,'strctMovInfo');
iCurrFrame = getappdata(handles.figure1,'iCurrFrame');

a2fFrame = fnReadFrameFromVideo(strctMovInfo, iCurrFrame);
strctAdditionalInfo.strctBackground = strctBackground;
hImage = getappdata(handles.figure1,'hImage');
hImage2 = getappdata(handles.figure1,'hImage2');
hImage3 = getappdata(handles.figure1,'hImage3');
hImage4 = getappdata(handles.figure1,'hImage4');

set(handles.uipanel2,'Title',num2str(iCurrFrame));
set(hImage,'cdata',a2fFrame);
set(hImage4,'cdata',a2fFrame);
if isfield(strctBackground,'m_a2fMedian')
    set(hImage3,'cdata',strctBackground.m_a2fMedian);
    
    [a2iOnlyMouse,iNumBlobs] = fnSegmentForeground2(double(a2fFrame)/255, strctAdditionalInfo);
    
    set(hImage2,'cdata',a2iOnlyMouse > 0);
    
else
    
end;
if isfield(strctBackground,'m_a2bFloor') && ~isempty(strctBackground.m_a2bFloor)
    hFloorArea = getappdata(handles.figure1,'hFloorArea');
    if ishandle(hFloorArea)
        delete(hFloorArea)
    end;
    C=bwboundaries(strctBackground.m_a2bFloor);
    hFloorArea = plot(handles.axes6,C{1}(:,2),C{1}(:,1),'b');
    setappdata(handles.figure1,'hFloorArea',hFloorArea);
end

return;

% --- Outputs from this function are returned to the command line.
function varargout = BackgroundDiffGUI_OutputFcn(hObject, eventdata, handles) 
global TMP
varargout{1} = TMP;
TMP = [];
return;


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
fValue = round(get(hObject,'value'));
setappdata(handles.figure1,'iCurrFrame',fValue);
fnInvalidate(handles);
return;



% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
return;


function hMotionThreshold_Callback(hObject, eventdata, handles)
strctBackground = getappdata(handles.figure1,'strctBackground');
strctBackground.m_fMotionThreshold = str2num(get(hObject,'String'));
setappdata(handles.figure1,'strctBackground',strctBackground);
fnInvalidate(handles);
return;


% --- Executes during object creation, after setting all properties.
function hMotionThreshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hMotionThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function hThresholdInside_Callback(hObject, eventdata, handles)
strctBackground = getappdata(handles.figure1,'strctBackground');
strctBackground.m_fIntensityThresholdInFloor = str2num(get(hObject,'String'));
setappdata(handles.figure1,'strctBackground',strctBackground);
fnInvalidate(handles);
return;


% --- Executes during object creation, after setting all properties.
function hThresholdInside_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hThresholdInside (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function hThresholdOutside_Callback(hObject, eventdata, handles)
strctBackground = getappdata(handles.figure1,'strctBackground');
strctBackground.m_fIntensityThresholdOutsideFloor = str2num(get(hObject,'String'));
setappdata(handles.figure1,'strctBackground',strctBackground);
fnInvalidate(handles);
return;


% --- Executes during object creation, after setting all properties.
function hThresholdOutside_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hThresholdOutside (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function hIntensityMult_Callback(hObject, eventdata, handles)
strctBackground = getappdata(handles.figure1,'strctBackground');
strctBackground.m_fMoreMult = str2num(get(hObject,'String'));
setappdata(handles.figure1,'strctBackground',strctBackground);
fnInvalidate(handles);
return;

% --- Executes during object creation, after setting all properties.
function hIntensityMult_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hIntensityMult (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hLargeCC_Callback(hObject, eventdata, handles)
strctBackground = getappdata(handles.figure1,'strctBackground');
strctBackground.m_fLargeCC = str2num(get(hObject,'String'));
setappdata(handles.figure1,'strctBackground',strctBackground);
fnInvalidate(handles);
return;

% --- Executes during object creation, after setting all properties.
function hLargeCC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hLargeCC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function hDilationEdit_Callback(hObject, eventdata, handles)
strctBackground = getappdata(handles.figure1,'strctBackground');
strctBackground.m_fDilation = str2num(get(hObject,'String'));
setappdata(handles.figure1,'strctBackground',strctBackground);
fnInvalidate(handles);
return;


% --- Executes during object creation, after setting all properties.
function hDilationEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hDilationEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function hMotionThresholdOutside_Callback(hObject, eventdata, handles)
strctBackground = getappdata(handles.figure1,'strctBackground');
strctBackground.m_fMotionThresholdOut = str2num(get(hObject,'String'));
setappdata(handles.figure1,'strctBackground',strctBackground);
fnInvalidate(handles);
return;


% --- Executes during object creation, after setting all properties.
function hMotionThresholdOutside_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hMotionThresholdOutside (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function hSaveResult_Callback(hObject, eventdata, handles)
strResultsFolder=getappdata(handles.figure1,'strResultsFolder');
if ~exist(strResultsFolder,'dir')
    try
        mkdir(strResultsFolder)
    catch
    end;
end;
strctBackground = getappdata(handles.figure1,'strctBackground');
[strFile,strPath]=uiputfile([strResultsFolder,'Background.mat']);
if strFile(1) == 0
    return;
end;
save([strPath,strFile],'strctBackground');
return;


% --------------------------------------------------------------------
function hLoadBackground_Callback(hObject, eventdata, handles)
strResultsFolder=getappdata(handles.figure1,'strResultsFolder');
if ~exist(strResultsFolder,'dir')
    try
        mkdir(strResultsFolder)
    catch
    end;
end;

[strFile,strPath]=uigetfile([strResultsFolder,'Background.mat']);
if strFile(1) == 0
    return;
end;
strctTmp = load([strPath,strFile]);
if ~isfield(strctTmp,'strctBackground')
    errordlg('Wrong file selected');
    return;
end;

strctBackground = strctTmp.strctBackground;
setappdata(handles.figure1,'strctBackground',strctBackground);
set(handles.hSubmit,'enable','on');
setappdata(handles.figure1,'bBackgroundComputed',1);
fnInvalidate(handles);
return;


% --- Executes on button press in hLearnBackground.
function hLearnBackground_Callback(hObject, eventdata, handles)
% hObject    handle to hLearnBackground (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fnLearn(handles);
return;




% --- Executes on button press in hFinish.
function hFinish_Callback(hObject, eventdata, handles)
global TMP
strctFloor= getappdata(handles.figure1,'strctFloor');
if isempty(strctFloor)
    msgbox('Please mark floor.');
    return;
end;
strctBackground = getappdata(handles.figure1,'strctBackground');
TMP = strctBackground;
delete(handles.figure1);
return;


function hStartFrameEdit_Callback(hObject, eventdata, handles)
strctBackground = getappdata(handles.figure1,'strctBackground');
strctBackground.m_iStartFrame = str2num(get(hObject,'String'));
setappdata(handles.figure1,'strctBackground',strctBackground);
fnInvalidate(handles);
return;


% --- Executes during object creation, after setting all properties.
function hStartFrameEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hStartFrameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hEndFrameEdit_Callback(hObject, eventdata, handles)
strctBackground = getappdata(handles.figure1,'strctBackground');
strctBackground.m_iEndFrame = str2num(get(hObject,'String'));
setappdata(handles.figure1,'strctBackground',strctBackground);
fnInvalidate(handles);
return;


% --- Executes during object creation, after setting all properties.
function hEndFrameEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hEndFrameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hNumFramesEdit_Callback(hObject, eventdata, handles)
strctBackground = getappdata(handles.figure1,'strctBackground');
strctBackground.m_iNumImagesForBuffer = str2num(get(hObject,'String'));
setappdata(handles.figure1,'strctBackground',strctBackground);
fnInvalidate(handles);
return;



% --- Executes during object creation, after setting all properties.
function hNumFramesEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hNumFramesEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function Untitled_2_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function hReRun_Callback(hObject, eventdata, handles)
fnLearn(handles);


% --- Executes on button press in hSubmit.
function hSubmit_Callback(hObject, eventdata, handles)
global TMP
bBackgroundComputed = getappdata(handles.figure1,'bBackgroundComputed');
strctMovInfo = getappdata(handles.figure1,'strctMovInfo');
strctBackground = getappdata(handles.figure1,'strctBackground');

if bBackgroundComputed
    TMP = strctBackground;
    delete(handles.figure1);
    return;
end
return;



% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function fnLearn(handles)
global TMP
strctMovInfo = getappdata(handles.figure1,'strctMovInfo');
strctBackground = getappdata(handles.figure1,'strctBackground');

if ~isfield(strctBackground,'m_a2bFloor')
    hMarkFloor_Callback([], [], handles);
    strctBackground = getappdata(handles.figure1,'strctBackground');
end;
% 
iStartFrame = strctBackground.m_iStartFrame;
iEndFrame = strctBackground.m_iEndFrame;
iNumImagesForBuffer = strctBackground.m_iNumImagesForBuffer;
% iEndFrame = str2num(answer{2});
% iNumImagesForBuffer = str2num(answer{3});

aiValidIntervals = iStartFrame:iEndFrame;
aiIndices = round(linspace(iStartFrame,iEndFrame,iNumImagesForBuffer)); %
aiIndices = aiValidIntervals(round( rand(1,iNumImagesForBuffer) * (length(aiValidIntervals)-1) + 1));
a3iBuffer = zeros(strctMovInfo.m_iHeight,strctMovInfo.m_iWidth, iNumImagesForBuffer,'uint8');
drawnow
fprintf('Collecting random images, please wait...');
for k=1:iNumImagesForBuffer
    fprintf('*');
    a3iBuffer(:,:,k) = fnReadFrameFromVideo(strctMovInfo,aiIndices(k));
end
fprintf('\nDone!\n');

fprintf('Computing Median, please wait...');
a2fMedian = double(median(a3iBuffer,3))/255;
fprintf('Done!\n');

%% Find floor area
% try
%     [aiClass, afCenter]=kmeans(a2iMedian(:),2);
% [fDummy,iIndexCenter]=max(afCenter);
% a2bI = reshape(aiClass == iIndexCenter,size(a2iMedian));
% strctBackground.m_fFloorThreshold =afCenter(iIndexCenter);
% 
% catch
%%
% strctBackground.m_fFloorThreshold = 0.9*median(a2iMedian(:));
% a2bI = a2iMedian>=strctBackground.m_fFloorThreshold;
% %     
% % end
% 
% a2bI(1:24,1:176)=0;
% 
% a2iL = bwlabel(a2bI);
% aiHist = fnLabelsHist(a2iL);
% [fDummy,iIndex]=max(aiHist(2:end));
% a2bBackground = a2iL == iIndex;
% [aiY,aiX]=find(a2bBackground);
% aiYRange = min(aiY):max(aiY);
% iNumYLines = length(aiYRange);
% afFoundXStart = zeros(1,iNumYLines );
% afFoundXEnd = zeros(1,iNumYLines );
% for iYIter=1:length(aiYRange)
%     aiLineX = find(a2bBackground(aiYRange(iYIter),:));
%     afFoundXStart(iYIter) = aiLineX(1);
%     afFoundXEnd(iYIter) = aiLineX(end);
% end


strctBackground.m_a2fMedian = a2fMedian;
setappdata(handles.figure1,'strctBackground',strctBackground);
%set(handles.hLearnBackground,'String','Continue with submit process');
set(handles.hSubmit,'enable','on');
setappdata(handles.figure1,'bBackgroundComputed',1);
fnInvalidate(handles);
return;


% --- Executes on button press in hMakeStartFrame.
function hMakeStartFrame_Callback(hObject, eventdata, handles)
strctBackground = getappdata(handles.figure1,'strctBackground');
iCurrFrame = getappdata(handles.figure1,'iCurrFrame');
strctBackground.m_iStartFrame = iCurrFrame;
setappdata(handles.figure1,'strctBackground',strctBackground);
fnInvalidate(handles);
set(handles.hStartFrameEdit,'String',num2str(strctBackground.m_iStartFrame));


% --- Executes on button press in hMakeEndFrame.
function hMakeEndFrame_Callback(hObject, eventdata, handles)
strctBackground = getappdata(handles.figure1,'strctBackground');
iCurrFrame = getappdata(handles.figure1,'iCurrFrame');
strctBackground.m_iEndFrame = iCurrFrame;
setappdata(handles.figure1,'strctBackground',strctBackground);
fnInvalidate(handles);
set(handles.hEndFrameEdit,'String',num2str(strctBackground.m_iEndFrame));


% --- Executes on button press in hMarkFloor.
function hMarkFloor_Callback(hObject, eventdata, handles)
% hObject    handle to hMarkFloor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
strctMovInfo = getappdata(handles.figure1,'strctMovInfo');
iCurrFrame = getappdata(handles.figure1,'iCurrFrame');
a2fFrame = fnReadFrameFromVideo(strctMovInfo, iCurrFrame);
axes(handles.axes6);
[a2bMask] = roipoly(double(a2fFrame)/255);
if ~isempty(a2bMask)
    strctBackground = getappdata(handles.figure1,'strctBackground');
    strctBackground.m_a2bFloor = a2bMask;
    setappdata(handles.figure1,'strctBackground',strctBackground);
    fnInvalidate(handles);
end
return;

