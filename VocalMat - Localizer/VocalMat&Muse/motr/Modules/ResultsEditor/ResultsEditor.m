function varargout = ResultsEditor(varargin)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology. 
% This file is a part of a free software. you can redistribute it and/or
% modify it under the terms of the GNU General Public License as published
% by the Free Software Foundation (see GPL.txt)

% Begin initialization code - DO NOT EDIT
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  1, ...
                   'gui_OpeningFcn', @ResultsEditor_OpeningFcn, ...
                   'gui_OutputFcn',  @ResultsEditor_OutputFcn, ...
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


% --- Executes just before ResultsEditor is made visible.
function ResultsEditor_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ResultsEditor (see VARARGIN)

% Choose default command line output for ResultsEditor
handles.output = hObject;


% varargin{1} is used internally by the GUIDE framework stuff
strJobFolder = varargin{2};
strResultFolder = varargin{3};
strIDFolder = varargin{4};
strIDFile = varargin{5};
strAVIfilename = varargin{6};
if length(varargin)>=7
    strBaseSequence = varargin{7};
else
    strBaseSequence = [];
end

setappdata(handles.figure1,'strJobFolder',strJobFolder);
setappdata(handles.figure1,'strIDFolder',strIDFolder);
setappdata(handles.figure1,'strIDFile',strIDFile);
setappdata(handles.figure1,'strAVIfilename',strAVIfilename);
setappdata(handles.figure1,'strResultFolder',strResultFolder);
setappdata(handles.figure1,'strBaseSequence',strBaseSequence);

fnFirstInvalidate(handles);
if ~isempty(strBaseSequence)
   fnLoadSequence(handles, strBaseSequence);
   fnInvalidate(handles);
end
% Update handles structure
set(handles.figure1,'CloseRequestFcn',@my_closereq);
[dummy,bn,ext]=fileparts(strAVIfilename);
set(handles.figure1,'Name',[bn ext]);
% setappdata(handles.figure1,'hJobsWindow',hJobsWindow);
guidata(hObject, handles);
return;

function my_closereq(src,evnt)
hJobsWindow = getappdata(src,'hJobsWindow');
if isfield(hJobsWindow, 'figure1') && ishandle(hJobsWindow.figure1)
    delete(hJobsWindow.figure1);
end;
delete(src);
return;

function fnFirstInvalidate(handles)
strAVIfilename = getappdata(handles.figure1,'strAVIfilename');
strctMovieInfo = fnReadVideoInfo(strAVIfilename);
setappdata(handles.figure1,'bMouseDown',0);
setappdata(handles.figure1,'strctMovieInfo',strctMovieInfo);
setappdata(handles.figure1,'iLeftFrame', 1);
setappdata(handles.figure1,'iPlaySpeed',1);
setappdata(handles.figure1,'bHighlights', 1);
setappdata(handles.figure1,'iCurrMouse', 1);
setappdata(handles.figure1,'bMoviePlaying',0);
setappdata(handles.figure1,'strMouseMoveMode','Scroll');

astrctTrackers = [];
setappdata(handles.figure1,'astrctTrackers',astrctTrackers);
set(handles.hPlaySpeed,'Min',1,'Max',100,'Value',1);

% set(handles.hLeftSlider,'Min',1,'Max',strctMovieInfo.m_iNumFrames,'Value',1,...
%     'SliderStep',[1/strctMovieInfo.m_iNumFrames, 1/strctMovieInfo.m_iNumFrames*10]);
n_frame=strctMovieInfo.m_iNumFrames;
set(handles.hLeftSlider, ...
    'Min',0, ...
    'Max',1, ...
    'Value',0, ...
    'SliderStep',[0.01 0.1]);
  % these are just the defaults, made explicit
a3fCdata = zeros(strctMovieInfo.m_iHeight,strctMovieInfo.m_iWidth);
colormap(gray(256))
hLeftImage = image([], [], a3fCdata, 'BusyAction', 'cancel', 'Parent', handles.hLeftAxes, 'Interruptible', 'off');
axis(handles.hLeftAxes,'image');  % maintain image aspect ratio

%hMenu = uicontextmenu;
hMenu = uicontextmenu('parent',handles.figure1);
uimenu(hMenu, 'Label', 'Scroll', 'Callback', {@SetScrollMode,handles});
uimenu(hMenu, 'Label', 'Zoom', 'Callback', {@fnSetZoomMode,handles});
uimenu(hMenu, 'Label', 'Pan', 'Callback', {@fnSetPanMode,handles});
uimenu(hMenu, 'Label', 'Reset', 'Callback', {@fnResetMode,handles});
% uimenu(hMenu, 'Label', 'Interpolate', 'Callback', {@fnInterpolateBetween,handles});
uimenu(hMenu, 'Label', 'Swap With', 'Callback', {@fnSwapIdentity,handles});
uimenu(hMenu, 'Label', 'Head-Tail Swap', 'Callback', {@fnSwapHeadTail,handles});

set(hLeftImage, 'UIContextMenu', hMenu);

hold(handles.hLeftAxes,'on');

setappdata(handles.figure1,'hLeftImage',hLeftImage);

set(handles.hLeftAxes,'visible','off');

set(handles.figure1,'WindowButtonDownFcn',{@fnMouseDown,handles});
set(handles.figure1,'WindowButtonUpFcn',{@fnMouseUp,handles});
set(handles.figure1,'WindowButtonMotionFcn',{@fnMouseMove,handles});
set(handles.figure1,'WindowScrollWheelFcn',{@fnMouseScroll,handles});
set(handles.figure1,'Units','pixels');
fnInvalidate(handles);

return



function fnUpdateTrackers(handles, iMouse, iFrame, strctNewInfo)
astrctTrackers = getappdata(handles.figure1,'astrctTrackers');
astrctTrackers(iMouse).m_afX(iFrame) = strctNewInfo.m_fX;
astrctTrackers(iMouse).m_afY(iFrame) = strctNewInfo.m_fY;
astrctTrackers(iMouse).m_afA(iFrame) = strctNewInfo.m_fA;
astrctTrackers(iMouse).m_afB(iFrame) = strctNewInfo.m_fB;
astrctTrackers(iMouse).m_afTheta(iFrame) = strctNewInfo.m_fTheta;
setappdata(handles.figure1,'astrctTrackers',astrctTrackers);
return;


function fnUpdateMousePosition(a,b,handles,iCurrMouse)
error('not longer supported');
strctMouseDown = getappdata(handles.figure1,'strctMouseDown');
a2fFrame = double(getappdata(handles.figure1,'a2fLeftImage'))/255;
iFrame = getappdata(handles.figure1,'iLeftFrame');
strctNewInfo = fnSegmentMouse(strctMouseDown.m_pt2fPos, a2fFrame,strctAdditionalInfo);
fnUpdateTrackers(handles, iCurrMouse, iFrame, strctNewInfo);

fnInvalidate(handles);

return;


function strctTracker = fnSegmentMouse(pt2fPoint, a2fFrame,strctAdditionalInfo)
error('no longer supported');
[a2iOnlyMouse,iNumBlobs] = fnSegmentForegroundWithoutBackgroundSubtraction(a2fFrame, strctAdditionalInfo);
x = round(pt2fPoint(1));
y = round(pt2fPoint(2));
afXRange = min(size(a2fFrame,2),max(1,x-20:x+20));
afYRange = min(size(a2fFrame,1),max(1,y-20:y+20));
aiHist = fnLabelsHist(a2iOnlyMouse(afYRange,afXRange));
if length(aiHist) == 1
    afMu = [NaN;NaN];
    a2fCov = [NaN,NaN;NaN,NaN];
    return;
end;
[fDummy, iSelectedComponent] = max(aiHist(2:end));
[aiY,aiX] = find(a2iOnlyMouse == iSelectedComponent);
[afMu, a2fCov] = fnFitGaussian([aiX,aiY]);
[strctTracker.m_fX,strctTracker.m_fY,...
    strctTracker.m_fA,strctTracker.m_fB,...
    strctTracker.m_fTheta] = fnCov2Tuple(afMu,a2fCov);

return;




function fnDrawTrackers(handles, strahHandles, hAxes, iFrame, bMainTracker)
if nargin<5
  bMainTracker = true;
end
iCurrMouse = getappdata(handles.figure1,'iCurrMouse');
ahHandles = getappdata(handles.figure1,strahHandles);
if bMainTracker
  %fnSafeDelete(ahHandles);
  deleteAllNonImageChildren(hAxes);
  ahHandles = [];
end
if bMainTracker
  astrctTrackers = getappdata(handles.figure1,'astrctTrackers');
else
  astrctTrackers = getappdata(handles.figure1,'astrctTrackers2');
end
a2fCol = fnGetMiceColors();
lineWidth=2;
for iMouseIter=1:length(astrctTrackers)
  strctTracker = fnGetTrackerAtFrame(astrctTrackers, iMouseIter, iFrame);
  clr=a2fCol(iMouseIter,:);
  if iMouseIter == iCurrMouse
    drawShapeControls=true;
    [hHandle,ahShapeHandles] = ...
      fnDrawTracker(hAxes, ...
                    strctTracker, ...
                    clr, ...
                    lineWidth, ...
                    drawShapeControls, ...
                    bMainTracker);
  else
    drawShapeControls=false;
    hHandle = ...
      fnDrawTracker(hAxes, ...
                    strctTracker, ...
                    clr, ...
                    lineWidth, ...
                    drawShapeControls, ...
                    bMainTracker);
    ahShapeHandles =[];
  end
  ahHandles = [ahHandles;hHandle;ahShapeHandles];
end
setappdata(handles.figure1,strahHandles,ahHandles);
return



function deleteAllNonImageChildren(h)
% Deletes all children of HG handle h, except for images.
c=get(h,'children');
for i=1:length(c)
  if ishandle(c(i))
    type_c=get(c(i),'type');
    if ~strcmp(type_c,'image')
      delete(c(i));
    end
  end
end
return



function fnSetFocus(handles)
iCurrMouse = getappdata(handles.figure1,'iCurrMouse');
iLeftFrame = getappdata(handles.figure1,'iLeftFrame');

astrctTrackers = getappdata(handles.figure1,'astrctTrackers');
fLeftX = astrctTrackers(iCurrMouse).m_afX(iLeftFrame);
fLeftY = astrctTrackers(iCurrMouse).m_afY(iLeftFrame);
strctMovieInfo = getappdata(handles.figure1,'strctMovieInfo');
fRatio = strctMovieInfo.m_iWidth ./ strctMovieInfo.m_iHeight;
fZoom = 200;

if ~isnan(fLeftX)
    afXLim = [fLeftX-fRatio*fZoom,fLeftX+fRatio*fZoom];
    afYLim = [fLeftY-fZoom,fLeftY+fZoom];
    set(handles.hLeftAxes,'xlim',afXLim);
    set(handles.hLeftAxes,'ylim',afYLim);
end;

return;


function fnInvalidateLeft(handles)
strctMovieInfo = getappdata(handles.figure1,'strctMovieInfo');
iLeftFrame = getappdata(handles.figure1,'iLeftFrame');
hLeftImage = getappdata(handles.figure1,'hLeftImage');
a2iLeft= fnReadFrameFromVideo(strctMovieInfo, iLeftFrame);
%strctLeft = aviread(strAVIfilename, iLeftFrame);
set(hLeftImage,'cdata',a2iLeft);
setappdata(handles.figure1,'a2fLeftImage',a2iLeft);
set(handles.hLeftFrameText,'String',num2str(iLeftFrame));
% Update ellipses markers...
bHighlights = getappdata(handles.figure1,'bHighlights');
if bHighlights
    fnDrawTrackers(handles, 'ahLeftMarkers', handles.hLeftAxes, iLeftFrame);
end
bHighlights2 = getappdata(handles.figure1,'bHighlights2');
if bHighlights2
    fnDrawTrackers(handles, 'ahLeftMarkers', handles.hLeftAxes, iLeftFrame, false);
end;
bAutoZoom = getappdata(handles.figure1,'bAutoZoom');
if bAutoZoom
    fnSetFocus(handles);
end;

return;

function fnInvalidate(handles)
fnInvalidateLeft(handles);
drawnow
return;

% --- Outputs from this function are returned to the command line.
function varargout = ResultsEditor_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function fnSetNewValueForLeftFrame(iLeftFrame, handles)
% This is for setting the "left" frame b/c of input from controls _other_
% than the slider itself.
strctMovieInfo = getappdata(handles.figure1,'strctMovieInfo');
bWindowsLinked = getappdata(handles.figure1,'bWindowsLinked');
setappdata(handles.figure1,'iLeftFrame',iLeftFrame);
val_slider=(iLeftFrame-1)/(strctMovieInfo.m_iNumFrames-1);
set(handles.hLeftSlider,'value',val_slider);
fnInvalidateLeft(handles);
return;

% --- Executes on slider movement.
function hLeftSlider_Callback(hObject, eventdata, handles)
val = get(hObject,'value');
%set(hObject,'value',fValue);  % in theory, this should do nothing
strctMovieInfo = getappdata(handles.figure1,'strctMovieInfo');
n_frame=strctMovieInfo.m_iNumFrames;
iLeftFrame=round(val*(n_frame-1))+1;
%iLeftFrame = round(fValue);
%fnSetNewValueForLeftFrame(iLeftFrame, handles);
setappdata(handles.figure1,'iLeftFrame',iLeftFrame);
%val_slider=(iLeftFrame-1)/(strctMovieInfo.m_iNumFrames-1);
%set(handles.hLeftSlider,'value',val_slider);
fnInvalidateLeft(handles);
return;


% --- Executes during object creation, after setting all properties.
function hLeftSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hLeftSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



% --- Executes on selection change in hMiceList.
function hMiceList_Callback(hObject, eventdata, handles)
iNewSelectedMouse = get(hObject,'value');
iNumMice = getappdata(handles.figure1,'iNumMice');
if iNewSelectedMouse <= iNumMice
    setappdata(handles.figure1,'iCurrMouse', iNewSelectedMouse);
    fnInvalidate(handles);
end;
return;

% --- Executes during object creation, after setting all properties.
function hMiceList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hMiceList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in hSaveSequence.
function hSaveSequence_Callback(hObject, eventdata, handles)
strResultFolder=getappdata(handles.figure1,'strResultFolder');
astrctTrackers = getappdata(handles.figure1,'astrctTrackers');
strctMovieInfo = getappdata(handles.figure1,'strctMovieInfo');
strMovieFileName = strctMovieInfo.m_strFileName;
strctID = getappdata(handles.figure1,'strctID');
strSequence = [strResultFolder,'Sequence.mat'];
[strFileName,strPath] = uiputfile(strSequence);
if strFileName(1) == 0
    return;
end;
setappdata(handles.figure1,'strBaseSequence',[strPath,strFileName]);

if exist([strPath,strFileName],'file')
    % Are you sure you want to overwrite this file?!?!?!
    ButtonName = questdlg('Are you sure you want to overwrite this file?',...
        'Warning', ...
        'Yes', 'No','No');
    drawnow
    if strcmpi(ButtonName,'Yes')
        fprintf('Writing To Disk...');
        save([strPath,strFileName],'astrctTrackers','strMovieFileName','strctID');
        fprintf('Resulted saved\n');
    end;
else
        fprintf('Writing To Disk...');
        save([strPath,strFileName],'astrctTrackers','strMovieFileName','strctID');
        fprintf('Resulted saved\n');
end;

return;

% --- Executes on button press in hLoadSequence.
function hLoadSequence_Callback(hObject, eventdata, handles)
strResultFolder=getappdata(handles.figure1,'strResultFolder');
strSequence = [strResultFolder,'Sequence.mat'];
[strFileName,strPath] = uigetfile(strSequence);
if strFileName(1) == 0
    return;
end;
strBaseSequence = [strPath,strFileName];
fnLoadSequence(handles, strBaseSequence);
fnInvalidate(handles);
return;

function fnLoadSequence(handles, strBaseSequence)
%
fprintf('Reading from disk...');
setappdata(handles.figure1,'strBaseSequence',strBaseSequence);
strctTmp = load(strBaseSequence);
fprintf('Done!\n');
setappdata(handles.figure1,'astrctTrackers',strctTmp.astrctTrackers);
fprintf('Results Loaded\n');
return;

% --------------------------------------------------------------------
function hLoadSequenceCompare_Callback(hObject, eventdata, handles)
% hObject    handle to hLoadSequenceCompare (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

strResultFolder=getappdata(handles.figure1,'strResultFolder');
strSequence = [strResultFolder,'Sequence.mat'];
[strFileName,strPath] = uigetfile(strSequence);
if strFileName(1) == 0
    return;
end;
fprintf('Reading from disk...');
setappdata(handles.figure1,'strOtherSequence',[strPath,strFileName]);
strctTmp = load([strPath,strFileName]);
fprintf('Done!\n');
setappdata(handles.figure1,'astrctTrackers2',strctTmp.astrctTrackers);
strBaseSequence = getappdata(handles.figure1,'strBaseSequence');
if isempty(strBaseSequence)
   hSaveSequence_Callback(hObject, eventdata, handles);
end

fnInvalidate(handles);
fprintf('Other Results Loaded\n');

astrctTrackers = getappdata(handles.figure1,'astrctTrackers');
[bDiff, afMaxDist] = fnEllipseDiff(astrctTrackers, strctTmp.astrctTrackers, true);
a2Intervals = fnConvertToIntervals(bDiff, afMaxDist)';
fprintf('Large Diff Frames Calculated. Found %d intervals\n', size(a2Intervals,2));
setappdata(handles.figure1,'aiDiffFrames',a2Intervals);
setappdata(handles.figure1,'iDiffFrameIndex',0);
fprintf('Diff Frames Calculated. Found %d intervals\n', size(a2Intervals,2));

return;

% --- Executes on button press in hResubmitJob.
function hResubmitJob_Callback(hObject, eventdata, handles)
% no longer supported
% strAVIfilename = getappdata(handles.hMainWindow.figure1,'strAVIfilename');
% strJobFolder = getappdata(handles.hMainWindow.figure1,'strJobFolder');
% strResultFolder= getappdata(handles.hMainWindow.figure1,'strResultFolder');
% astrctTmp = dir([strJobFolder,'Jobargin*']);
% iNewJobNum = length(astrctTmp)+1-2;
% iLeftFrame = getappdata(handles.hMainWindow.figure1,'iLeftFrame');
% iRightFrame = getappdata(handles.hMainWindow.figure1,'iRightFrame');
% astrctTrackers = getappdata(handles.hMainWindow.figure1,'astrctTrackers');
% strctMovieInfo = getappdata(handles.hMainWindow.figure1,'strctMovieInfo');
% strctAdditionalInfo = getappdata(handles.hMainWindow.figure1,'strctAdditionalInfo');
% iNumMice = length(astrctTrackers);%getappdata(handles.hMainWindow.figure1,'iNumMice');
% 
% for k=1:iNumMice
%     astrctEllipse(k) = fnGetTrackerAtFrame(astrctTrackers, k, iLeftFrame);
% end;
% 
% strctBootstrap.m_astrctEllipse = astrctEllipse;
% strctBootstrap.m_strctAdditionalInfo = strctAdditionalInfo;
% strctBootstrap.m_iNumMice = iNumMice;
% strAdditionalInfoFile = getappdata(handles.hMainWindow.figure1,'strSetupFilename');
% 
% fnCreateJob(strAVIfilename, strctMovieInfo, ...
%                      iLeftFrame:iRightFrame, strctBootstrap, strAdditionalInfoFile,...
%                      sprintf('%sJobOut%04d.mat',strResultFolder,iNewJobNum), iNewJobNum, ...
%                       sprintf('%sJobargin%04d.mat',strJobFolder, iNewJobNum),false);
% 
% strJobargin = sprintf('%sJobargin%04d.mat',strJobFolder, iNewJobNum);
% fnJobAlgorithm(strJobargin);
% return;

% --- Executes on selection change in hAnnotationList.
function hAnnotationList_Callback(hObject, eventdata, handles)
% hObject    handle to hAnnotationList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns hAnnotationList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from hAnnotationList


% --- Executes during object creation, after setting all properties.
function hAnnotationList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hAnnotationList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in hAnnotate.
function hAnnotate_Callback(hObject, eventdata, handles)
% hObject    handle to hAnnotate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in hRefreshJobList.
function hRefreshJobList_Callback(hObject, eventdata, handles)
fnRefreshJobList(handles);
return;

function astrctTrackersJob = fnGetTrackersAtFrameFromJob(astrctMiceTrackers, iFrame)
for iMouseIter=1:length(astrctMiceTrackers(iFrame).m_astrctMouse)
    astrctTrackersJob(iMouseIter) = astrctMiceTrackers(iFrame).m_astrctMouse(iMouseIter);
end;
return;


function hMergeJobs_Callback(hObject, eventdata, handles)
%
aiSelectedJobs = get(handles.hJobList,'value');
if length(aiSelectedJobs) == 0
    return;
end;

strctMovieInfo = getappdata(handles.hMainWindow.figure1,'strctMovieInfo');
acstrJobFiles = getappdata(handles.hMainWindow.figure1,'acstrJobFiles');
astrctTrackers = getappdata(handles.hMainWindow.figure1,'astrctTrackers');

astrctTrackers = fnMergeJobs(strctMovieInfo, acstrJobFiles(aiSelectedJobs), astrctTrackers);

setappdata(handles.hMainWindow.figure1,'astrctTrackers',astrctTrackers);
fnInvalidate(handles.hMainWindow);
fprintf('Job results merged!\n');

return;


function fnSafeDelete(ahHandles)
for k=1:length(ahHandles)
    if ishandle(ahHandles(k))
        delete(ahHandles(k));
    end
end;
return;

% --- Executes on button press in hToggleHighlights.
function hToggleHighlights_Callback(hObject, eventdata, handles)
bHighlights = get(hObject,'value');
setappdata(handles.figure1,'bHighlights',bHighlights);
if ~bHighlights
    ahRightMarkers = getappdata(handles.figure1,'ahRightMarkers');
    ahLeftMarkers = getappdata(handles.figure1,'ahLeftMarkers');
    fnSafeDelete(ahRightMarkers);
    fnSafeDelete(ahLeftMarkers);
end;
fnInvalidate(handles);
return;

% --- Executes on button press in hToggleHighlights.
function hToggleHighlights2_Callback(hObject, eventdata, handles)
bHighlights2 = get(hObject,'value');
setappdata(handles.figure1,'bHighlights2',bHighlights2);
fnInvalidate(handles);
return;


% --------------------------------------------------------------------
function hFixPosition_Callback(hObject, eventdata, handles)
dbg = 1;
return;

% --------------------------------------------------------------------
function Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in hExportAVI.
% function hExportAVI_Callback(hObject, eventdata, handles)
% strctMovieInfo = getappdata(handles.figure1,'strctMovieInfo');
% strAVIfilename = getappdata(handles.figure1,'strAVIfilename');
% iLeftFrame = getappdata(handles.figure1,'iLeftFrame');
% iRightFrame = getappdata(handles.figure1,'iRightFrame');
% 
% if iRightFrame-iLeftFrame > 10000
%     ButtonName = questdlg(sprintf('Are you sure you want to export %d frames ?', iRightFrame-iLeftFrame+1), ...
%         'Important Question', ...
%         'Yes', 'No', 'No');
%     if strcmp(ButtonName,'No')
%         return;
%     end;
% end;
% mov = avifile([strAVIfilename(1:end-3),'Result.Avi'],'Compression','xvid','fps',30);
% fig=figure(10);
% clf;
% hGca = gca;
% set(fig,'DoubleBuffer','on');
% set(gca,'Visible','off')
% for k=iLeftFrame:iRightFrame %1:strctMovieInfo.m_iNumFrames
%     a2iFrame = fnReadFrameFromVideo(strctMovieInfo, k);
%     imshow(double(a2iFrame)/255,[]);
%     hold on;
%     fnDrawTrackers(handles, 'ahLeftMarkers', hGca, k);
%     hold off;
%     drawnow
%     F = getframe(gca);
%     F.cdata = imresize(F.cdata, [480 640]);
%     mov = addframe(mov,F);
% end
% mov = close(mov);
% return;


function SetScrollMode(obj,eventdata,handles)
setappdata(handles.figure1,'strMouseMoveMode','Scroll');
fprintf('Scroll Mode\n');
return;

function fnSetZoomMode(obj,eventdata,handles)
setappdata(handles.figure1,'strMouseMoveMode','Zoom');
fprintf('Zoom Mode\n');
return;

function fnSetPanMode(obj,eventdata,handles)
setappdata(handles.figure1,'strMouseMoveMode','Pan');
fprintf('Pan Mode\n');
return;


function fnResetMode(obj,eventdata,handles)
strctMovieInfo = getappdata(handles.figure1,'strctMovieInfo');
[hAxes,strActiveWindow] = fnGetActiveWindow(handles);
if isempty(hAxes)
    return;
end;
set(hAxes,'xlim',[0 strctMovieInfo.m_iWidth]);
set(hAxes,'ylim',[0 strctMovieInfo.m_iHeight]);
return;


function fnMouseUp(obj,eventdata,handles)
setappdata(handles.figure1,'bMouseDown',0);
strctMouseOp.m_strButton = fnGetClickType(handles.figure1);
strctMouseOp.m_strAction = 'Up';
[strctMouseOp.m_hAxes, strctMouseOp.m_strWindow] = fnGetActiveWindow(handles);
strctMouseOp.m_pt2fPos = fnGetMouseCoordinate(strctMouseOp.m_hAxes);

fnPrintMouseOp(strctMouseOp);
setappdata(handles.figure1,'strctMouseCurr',strctMouseOp);
setappdata(handles.figure1,'strctMouseUp',strctMouseOp);

strSavedMouseMode = getappdata(handles.figure1,'strSavedMouseMode');
if ~isempty(strSavedMouseMode)
%    fprintf('Setting Mouse mode back to %s\n',strSavedMouseMode);
    setappdata(handles.figure1,'strMouseMoveMode',strSavedMouseMode);
    setappdata(handles.figure1,'strSavedMouseMode',[]);
end;

bInterpolateWhenMouseUp = getappdata(handles.figure1,'bInterpolateWhenMouseUp');
if bInterpolateWhenMouseUp
    strctMouseDown = getappdata(handles.figure1,'strctMouseDown');
    setappdata(handles.figure1,'bInterpolateWhenMouseUp',0);

    if strcmpi(strctMouseDown.m_strWindow(1:end-1),'Zoom')
        iZoomPane = str2num(strctMouseDown.m_strWindow(end));
        astrctTrackers = getappdata(handles.figure1,'astrctTrackers');
        iCurrMouse = getappdata(handles.figure1,'iCurrMouse');
        aiZoomFrames = getappdata(handles.figure1,'aiZoomFrames');
        if iZoomPane == 1
            astrctTrackers = fnInterpolateBetweenFrames(...
                astrctTrackers, iCurrMouse, aiZoomFrames(1), aiZoomFrames(2), false);
        end;
        if iZoomPane == 5
            astrctTrackers = fnInterpolateBetweenFrames(...
                astrctTrackers, iCurrMouse, aiZoomFrames(4), aiZoomFrames(5), false);
        end;

        if iZoomPane > 1 && iZoomPane < 5
            astrctTrackers = fnInterpolateBetweenFrames(...
                astrctTrackers, iCurrMouse, aiZoomFrames(iZoomPane-1), aiZoomFrames(iZoomPane), false);
            astrctTrackers = fnInterpolateBetweenFrames(...
                astrctTrackers, iCurrMouse, aiZoomFrames(iZoomPane), aiZoomFrames(iZoomPane+1), false);
        end;
        setappdata(handles.figure1,'astrctTrackers',astrctTrackers);
        fnInvalidate(handles);
    end;
end;

return;

function fnMouseScroll(obj,eventdata,handles)
fDelta = round(eventdata.VerticalScrollCount * get(handles.hPlaySpeed,'value'));

[hAxes,strActiveWindow] = fnGetActiveWindow(handles);
if isempty(hAxes)
    return;
end;
strctMovieInfo = getappdata(handles.figure1,'strctMovieInfo');
iLeftFrame = getappdata(handles.figure1,'iLeftFrame');
iNewLeftValue = min(strctMovieInfo.m_iNumFrames,max(1, iLeftFrame+fDelta));
fnSetNewValueForLeftFrame(iNewLeftValue, handles);
set(handles.hLeftSlider,'value',iNewLeftValue);
return;


% --- Executes on button press in hPlaySequence.

function TimerFnc(hPlayTimer,b,handles,iEndFrame)
iLeftFrame = getappdata(handles.figure1,'iLeftFrame');
strctMovieInfo = getappdata(handles.figure1,'strctMovieInfo');
iPlaySpeed = getappdata(handles.figure1,'iPlaySpeed');
iNewLeftFrame = min(strctMovieInfo.m_iNumFrames, iLeftFrame + iPlaySpeed);
fnSetNewValueForLeftFrame(iNewLeftFrame, handles);
fnInvalidate(handles);
if iNewLeftFrame >= strctMovieInfo.m_iNumFrames || iNewLeftFrame >= iEndFrame
    fnStopPlayingSequence(handles);
    return;
end;
return;

function fnStopPlayingSequence(handles)
hPlayTimer = getappdata(handles.figure1,'hPlayTimer');
setappdata(handles.figure1,'bMoviePlaying',0);
set(handles.hPlaySequence,'String','Play');
if isobject(hPlayTimer)
    stop(hPlayTimer);
end;
return;

function fnPlaySequenceFromFrame(handles, iStartFrame,iEndFrame)
fnSetNewValueForLeftFrame(iStartFrame, handles);
% fnStopPlayingSequence(handles);
bMoviePlaying = getappdata(handles.figure1,'bMoviePlaying');

if ~bMoviePlaying
   hPlayTimer = timer('StartDelay',0,...
      'BusyMode','drop',...
      'ExecutionMode','FixedRate',...
      'TasksToExecute',Inf,...
      'TimerFcn',{@TimerFnc,handles,iEndFrame},...
      'Period',1/10);%1/strctMovieInfo.FramesPerSecond);
   setappdata(handles.figure1,'hPlayTimer',hPlayTimer);
   set(handles.hPlaySequence,'String','Stop');
   start(hPlayTimer);
   setappdata(handles.figure1,'bMoviePlaying',1);
else
   fnStopPlayingSequence(handles);
end;
return;

% --- Executes on button press in hPlaySequence.
function hPlaySequence_Callback(hObject, eventdata, handles)
iLeftFrame = getappdata(handles.figure1,'iLeftFrame');
strctMovieInfo = getappdata(handles.figure1,'strctMovieInfo');
fnPlaySequenceFromFrame(handles, iLeftFrame, strctMovieInfo.m_iNumFrames);
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

function [hAxes,strActiveWindow] = fnGetActiveWindow(handles)
if (fnInsideImage(handles,handles.hLeftAxes))
    hAxes = handles.hLeftAxes;
    strActiveWindow = 'Left';
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
% fprintf('%s %s in %s window, Pos [%.2f %.2f]\n',...
%     strctMouseOp.m_strButton, strctMouseOp.m_strAction, ...
%     strctMouseOp.m_strWindow,strctMouseOp.m_pt2fPos(1),strctMouseOp.m_pt2fPos(2));
return;


function fnMouseDown(obj,eventdata,handles)
strMouseMoveMode = getappdata(handles.figure1,'strMouseMoveMode');
setappdata(handles.figure1,'bMouseDown',1);
strctMouseOp.m_strButton = fnGetClickType(handles.figure1);
strctMouseOp.m_strAction = 'Down';
[strctMouseOp.m_hAxes, strctMouseOp.m_strWindow] = fnGetActiveWindow(handles);
strctMouseOp.m_pt2fPos = fnGetMouseCoordinate(strctMouseOp.m_hAxes);
strctMouseOp.m_strModeWhenDown = strMouseMoveMode;
if strcmp(strctMouseOp.m_strWindow,'Left')
    strctMouseOp.m_iFrame = getappdata(handles.figure1,'iLeftFrame');
elseif strcmp(strctMouseOp.m_strWindow(1:end-1),'Zoom')
    iZoomPane = str2num(strctMouseOp.m_strWindow(end));
    aiZoomFrames = getappdata(handles.figure1,'aiZoomFrames');
    if ~isempty(aiZoomFrames)
        strctMouseOp.m_iFrame = aiZoomFrames(iZoomPane);
    end;
else
    strctMouseOp.m_iFrame = -1;
end;


fnPrintMouseOp(strctMouseOp);

setappdata(handles.figure1,'strctMouseDown',strctMouseOp);
setappdata(handles.figure1,'strctMouseCurr',strctMouseOp);
fnHandleMouseDownEvent(strctMouseOp,handles);

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

if bMouseDown > 0 && ~isempty(strctMouseOp.m_hAxes) && ~isempty(strctMouseDown.m_hAxes) && ...
        strctMouseOp.m_hAxes == strctMouseDown.m_hAxes
    fnHandleMouseMoveWhileDown(strctPrevMouseOp, strctMouseOp, handles);
end;
return;


function iNewSelectedMouse = fnFindClosestMouse(strctMouseOp, handles)
iNewSelectedMouse = [];
if strcmp(strctMouseOp.m_strWindow,'Left')
    iFrame = getappdata(handles.figure1,'iLeftFrame');
else
   return;
end;
astrctTrackers = getappdata(handles.figure1,'astrctTrackers');
iNumMice = length(astrctTrackers);
afDist = zeros(1,iNumMice);
for iMouseIter=1:iNumMice
    afDist(iMouseIter) =sqrt( (astrctTrackers(iMouseIter).m_afX(iFrame)-strctMouseOp.m_pt2fPos(1)).^2 + ...
        (astrctTrackers(iMouseIter).m_afY(iFrame)-strctMouseOp.m_pt2fPos(2)).^2 );
end;
fMaxMouseDist = 50;
[fMinDist, iIndex] = min(afDist);
if fMinDist < fMaxMouseDist
    iNewSelectedMouse = iIndex;
end;

return;

function fnSelectClosestMouse(strctMouseOp,handles)
iNewSelectedMouse = fnFindClosestMouse(strctMouseOp, handles);
if ~isempty(iNewSelectedMouse)
    setappdata(handles.figure1,'iCurrMouse', iNewSelectedMouse);
    fnInvalidate(handles);
end;

return;

function fnHighlightMouse(strctMouseOp,handles)
% Just highlight the mouse which is near the current position
iNewSelectedMouse = fnFindClosestMouse(strctMouseOp, handles);
if ~isempty(iNewSelectedMouse)
    astrctTrackers = getappdata(handles.figure1,'astrctTrackers');
    a2fCol = fnGetMiceColors();
    strctTracker = fnGetTrackerAtFrame(astrctTrackers, iNewSelectedMouse, strctMouseOp.m_iFrame);
    for k=1:5
        hHandle = fnDrawTracker(strctMouseOp.m_hAxes,strctTracker, a2fCol(iNewSelectedMouse,:), k,0);
        drawnow
        tic
        while toc < 0.05
        end;
        delete(hHandle);
    end;
end;

return;



function fnSwapHeadTail(a,b,handles)
strctMouseDown = getappdata(handles.figure1,'strctMouseDown');
astrctTrackers = getappdata(handles.figure1,'astrctTrackers');
iSwapWithMouse = fnFindClosestMouse(strctMouseDown, handles);
t = astrctTrackers(iSwapWithMouse).m_afTheta(strctMouseDown.m_iFrame:end);
dt = abs(t(2:end)-t(1:end-1));
iFrameJump = find(dt>pi/2 & dt<3*pi/2,1) + strctMouseDown.m_iFrame-1
if ~isempty(iSwapWithMouse)
    astrctTrackers(iSwapWithMouse).m_afTheta(strctMouseDown.m_iFrame:iFrameJump) = ...
        astrctTrackers(iSwapWithMouse).m_afTheta(strctMouseDown.m_iFrame:iFrameJump) + pi;
end;

X = astrctTrackers(iSwapWithMouse).m_afTheta;
X(X > 2*pi) = X(X > 2*pi) - 2*pi;
astrctTrackers(iSwapWithMouse).m_afTheta = X;
setappdata(handles.figure1,'astrctTrackers',astrctTrackers);
fnInvalidate(handles);
return;


function fnSwapIdentity(a,b,handles)
strctMouseDown = getappdata(handles.figure1,'strctMouseDown');
iCurrMouse = getappdata(handles.figure1,'iCurrMouse');
iSwapWithMouse = fnFindClosestMouse(strctMouseDown, handles);
if isempty(iSwapWithMouse)
    return;
end;
astrctTrackers = getappdata(handles.figure1,'astrctTrackers');

afSaveX = astrctTrackers(iCurrMouse).m_afX(strctMouseDown.m_iFrame:end);
afSaveY = astrctTrackers(iCurrMouse).m_afY(strctMouseDown.m_iFrame:end);
afSaveA = astrctTrackers(iCurrMouse).m_afA(strctMouseDown.m_iFrame:end);
afSaveB = astrctTrackers(iCurrMouse).m_afB(strctMouseDown.m_iFrame:end);
afSaveT = astrctTrackers(iCurrMouse).m_afTheta(strctMouseDown.m_iFrame:end);

astrctTrackers(iCurrMouse).m_afX(strctMouseDown.m_iFrame:end) = ...
    astrctTrackers(iSwapWithMouse).m_afX(strctMouseDown.m_iFrame:end);
astrctTrackers(iCurrMouse).m_afY(strctMouseDown.m_iFrame:end) = ...
    astrctTrackers(iSwapWithMouse).m_afY(strctMouseDown.m_iFrame:end);
astrctTrackers(iCurrMouse).m_afA(strctMouseDown.m_iFrame:end) = ...
    astrctTrackers(iSwapWithMouse).m_afA(strctMouseDown.m_iFrame:end);
astrctTrackers(iCurrMouse).m_afB(strctMouseDown.m_iFrame:end) = ...
    astrctTrackers(iSwapWithMouse).m_afB(strctMouseDown.m_iFrame:end);
astrctTrackers(iCurrMouse).m_afTheta(strctMouseDown.m_iFrame:end) = ...
    astrctTrackers(iSwapWithMouse).m_afTheta(strctMouseDown.m_iFrame:end);

astrctTrackers(iSwapWithMouse).m_afX(strctMouseDown.m_iFrame:end) = afSaveX;
astrctTrackers(iSwapWithMouse).m_afY(strctMouseDown.m_iFrame:end) = afSaveY;
astrctTrackers(iSwapWithMouse).m_afA(strctMouseDown.m_iFrame:end) = afSaveA;
astrctTrackers(iSwapWithMouse).m_afB(strctMouseDown.m_iFrame:end) = afSaveB;
astrctTrackers(iSwapWithMouse).m_afTheta(strctMouseDown.m_iFrame:end) = afSaveT;

setappdata(handles.figure1,'astrctTrackers',astrctTrackers);
fnInvalidate(handles);
return;



function fnHandleMouseMoveWhileDown(strctPrevMouseOp, strctMouseOp, handles)
fnPrintMouseOp(strctMouseOp);
strctMouseDown = getappdata(handles.figure1,'strctMouseDown');
strMouseMoveMode = getappdata(handles.figure1,'strMouseMoveMode');
if strcmp(strMouseMoveMode,'Zoom')
    afDiff = strctMouseOp.m_pt2fPos - strctPrevMouseOp.m_pt2fPos;
    dl = afDiff(2);
    if abs(dl) < 200
        strctMovieInfo = getappdata(handles.figure1,'strctMovieInfo');
        fRatio = strctMovieInfo.m_iWidth ./ strctMovieInfo.m_iHeight;
        afXlim = get(strctMouseDown.m_hAxes ,'xlim');
        afYlim = get(strctMouseDown.m_hAxes,'ylim');
        afXlim = [afXlim(1)+fRatio*dl, afXlim(2)-fRatio*dl];
        afYlim = [afYlim(1)+dl, afYlim(2)-dl];
        set(strctMouseDown.m_hAxes,'xlim',afXlim);
        set(strctMouseDown.m_hAxes,'ylim',afYlim);
    end;
end;
if strcmp(strMouseMoveMode,'Pan')
    dl = strctMouseDown.m_pt2fPos - strctMouseOp.m_pt2fPos;
    if max(abs(dl)) < 200

        afXlim = get(strctMouseDown.m_hAxes,'xlim');
        afYlim = get(strctMouseDown.m_hAxes,'ylim');
        afXlim = afXlim + dl(1);
        afYlim = afYlim + dl(2);
        set(strctMouseDown.m_hAxes,'xlim',afXlim);
        set(strctMouseDown.m_hAxes,'ylim',afYlim);
    end;
end;
if strcmp(strMouseMoveMode,'Control')

    setappdata(handles.figure1,'bInterpolateWhenMouseUp',1);
    strctControl = getappdata(handles.figure1,'strctControl');
    astrctTrackers = getappdata(handles.figure1,'astrctTrackers');
    %fprintf('Selected Control %d\n',strctControl.m_iControl );


    if strctControl.m_iControl == 1
        % Change center
        astrctTrackers(strctControl.m_iSelectedMouse).m_afX(strctControl.m_iFrame) =  strctMouseOp.m_pt2fPos(1);
        astrctTrackers(strctControl.m_iSelectedMouse).m_afY(strctControl.m_iFrame) =  strctMouseOp.m_pt2fPos(2);
    end;
    if strctControl.m_iControl == 4 || strctControl.m_iControl == 2
        % Major Axis
        x = astrctTrackers(strctControl.m_iSelectedMouse).m_afX(strctControl.m_iFrame);
        y = astrctTrackers(strctControl.m_iSelectedMouse).m_afY(strctControl.m_iFrame);
        a = astrctTrackers(strctControl.m_iSelectedMouse).m_afA(strctControl.m_iFrame);
        b = astrctTrackers(strctControl.m_iSelectedMouse).m_afB(strctControl.m_iFrame);
        xp = strctMouseOp.m_pt2fPos(1);
        yp = strctMouseOp.m_pt2fPos(2);
        newa = sqrt((xp-x).^2 + (yp-y).^2);
        u = [xp-x;yp-y];
        u = u ./ norm(u);
        theta = atan2(-u(2),u(1));
        if newa < b
            strctControl.m_iControl = 3;
            setappdata(handles.figure1,'strctControl',strctControl);
            astrctTrackers(strctControl.m_iSelectedMouse).m_afTheta(strctControl.m_iFrame)  = ...
                astrctTrackers(strctControl.m_iSelectedMouse).m_afTheta(strctControl.m_iFrame) + pi /2;
        else
            astrctTrackers(strctControl.m_iSelectedMouse).m_afA(strctControl.m_iFrame) = newa;
            astrctTrackers(strctControl.m_iSelectedMouse).m_afTheta(strctControl.m_iFrame)  = theta ;
        end;

    end;
    if strctControl.m_iControl ==5 || strctControl.m_iControl ==3
        % Major Axis
        x = astrctTrackers(strctControl.m_iSelectedMouse).m_afX(strctControl.m_iFrame);
        y = astrctTrackers(strctControl.m_iSelectedMouse).m_afY(strctControl.m_iFrame);
        a = astrctTrackers(strctControl.m_iSelectedMouse).m_afA(strctControl.m_iFrame);
        b = astrctTrackers(strctControl.m_iSelectedMouse).m_afB(strctControl.m_iFrame);

        xp = strctMouseOp.m_pt2fPos(1);
        yp = strctMouseOp.m_pt2fPos(2);
        newb = sqrt((xp-x).^2 + (yp-y).^2);
        u = [xp-x;yp-y];
        u = u ./ norm(u);
        theta = atan2(-u(2),u(1))+pi/2;
        if newb > a
            strctControl.m_iControl = 2;
            fprintf('Flip\n');
            setappdata(handles.figure1,'strctControl',strctControl);
            astrctTrackers(strctControl.m_iSelectedMouse).m_afTheta(strctControl.m_iFrame)  = ...
                astrctTrackers(strctControl.m_iSelectedMouse).m_afTheta(strctControl.m_iFrame) + pi /2;
        else
            astrctTrackers(strctControl.m_iSelectedMouse).m_afB(strctControl.m_iFrame) = newb;
            astrctTrackers(strctControl.m_iSelectedMouse).m_afTheta(strctControl.m_iFrame)  = theta ;
        end;

    end;

    while astrctTrackers(strctControl.m_iSelectedMouse).m_afTheta(strctControl.m_iFrame) > 2*pi
        astrctTrackers(strctControl.m_iSelectedMouse).m_afTheta(strctControl.m_iFrame)  = ...
            astrctTrackers(strctControl.m_iSelectedMouse).m_afTheta(strctControl.m_iFrame)  - 2*pi;
    end;

    while astrctTrackers(strctControl.m_iSelectedMouse).m_afTheta(strctControl.m_iFrame) < 0
        astrctTrackers(strctControl.m_iSelectedMouse).m_afTheta(strctControl.m_iFrame)  = ...
            astrctTrackers(strctControl.m_iSelectedMouse).m_afTheta(strctControl.m_iFrame)  + 2*pi;
    end;
    setappdata(handles.figure1,'astrctTrackers',astrctTrackers);
    iLeftFrame = getappdata(handles.figure1,'iLeftFrame');
    fnDrawTrackers(handles, 'ahLeftMarkers', handles.hLeftAxes, iLeftFrame);

    aiZoomFrames = getappdata(handles.figure1,'aiZoomFrames');
    ahZoomArray = getappdata(handles.figure1,'ahZoomArray');
    acstrZoomHandles = getappdata(handles.figure1,'acstrZoomHandles');
    if iscell(acstrZoomHandles)
        for iZoomIter=1:5
            fnDrawTrackers(handles, acstrZoomHandles{iZoomIter}, ahZoomArray(iZoomIter), aiZoomFrames(iZoomIter));
        end;
    end;
end;



return;

function fnSelectController(strctMouseOp,handles)
if strctMouseOp.m_iFrame == -1
    return;
end;
iCurrMouse = getappdata(handles.figure1,'iCurrMouse');
astrctTrackers= getappdata(handles.figure1,'astrctTrackers');
if isempty(astrctTrackers)
    return;
end;

strctTracker = fnGetTrackerAtFrame(astrctTrackers,iCurrMouse,strctMouseOp.m_iFrame);
if ~isnan(strctTracker.m_fX)
    [apt2fControls] = fnGetEllipseControls(strctTracker);
    afDistToControls = sqrt(sum((apt2fControls - repmat(strctMouseOp.m_pt2fPos',1,5)).^2));
    [fMinDist, iControlIndex] = min(afDistToControls);
    fMinDistToControl = 8;
    if fMinDist < fMinDistToControl
        strctControl.m_iSelectedMouse = iCurrMouse;
        strctControl.m_iFrame = strctMouseOp.m_iFrame;
        strctControl.m_iControl = iControlIndex;
        strMouseMoveMode = getappdata(handles.figure1,'strMouseMoveMode');
        setappdata(handles.figure1,'strSavedMouseMode',strMouseMoveMode);
        setappdata(handles.figure1,'strMouseMoveMode', 'Control');
        setappdata(handles.figure1,'strctControl',strctControl);
        %fprintf('Control %d Selected \n',iControlIndex');
    else
        %fprintf('No Controller Found\n');

    end;
end;
return;

function [hAxes,strActiveWindow] = fnHandleMouseDownEvent(strctMouseOp,handles)
bMoviePlaying = getappdata(handles.figure1,'bMoviePlaying');
if bMoviePlaying
    fnStopPlayingSequence(handles);
end;

if strcmp(strctMouseOp.m_strButton,'Right')
    fnHighlightMouse(strctMouseOp,handles);
    return;
end;

if strcmp(strctMouseOp.m_strButton,'Left');
    fnSelectController(strctMouseOp,handles);
end;

if strcmp(strctMouseOp.m_strButton,'DoubleClick');
    fnSelectClosestMouse(strctMouseOp,handles);
end;

return;

function fnAddEllipse(a,b,handles,iCurrMouse)
strctMouseDown = getappdata(handles.figure1,'strctMouseDown');
astrctTrackers = getappdata(handles.figure1,'astrctTrackers');
astrctTrackers(iCurrMouse).m_afX(strctMouseDown.m_iFrame) = strctMouseDown.m_pt2fPos(1);
astrctTrackers(iCurrMouse).m_afY(strctMouseDown.m_iFrame) = strctMouseDown.m_pt2fPos(2);
astrctTrackers(iCurrMouse).m_afA(strctMouseDown.m_iFrame) = 50;
astrctTrackers(iCurrMouse).m_afB(strctMouseDown.m_iFrame) = 30;
astrctTrackers(iCurrMouse).m_afTheta(strctMouseDown.m_iFrame) = 0;

setappdata(handles.figure1,'astrctTrackers',astrctTrackers);
iLeftFrame = getappdata(handles.figure1,'iLeftFrame');
fnDrawTrackers(handles, 'ahLeftMarkers', handles.hLeftAxes, iLeftFrame);
return;

% function fnInterpolateBetween(a,b,handles)
% strctMouseDown = getappdata(handles.figure1,'strctMouseDown');
% iClosestMouse = fnFindClosestMouse(strctMouseDown, handles);
% if ~isempty(iClosestMouse)
%     astrctTrackers = getappdata(handles.figure1,'astrctTrackers');
%     iLeftFrame = getappdata(handles.figure1,'iLeftFrame');
%     iRightFrame = getappdata(handles.figure1,'iRightFrame');
% 
%     [astrctTrackers,bFailed] = fnInterpolateBetweenFrames(astrctTrackers, iClosestMouse, iLeftFrame, iRightFrame, true);
%     if ~bFailed
%         setappdata(handles.figure1,'astrctTrackers',astrctTrackers);
%         fnInvalidate(handles);
%     end;
% end;
% 
% return;
% 


% --- Executes on slider movement.
function hPlaySpeed_Callback(hObject, eventdata, handles)
iNewSpeed = round(get(hObject,'value'));
setappdata(handles.figure1,'iPlaySpeed',iNewSpeed);
return;

% --- Executes during object creation, after setting all properties.
function hPlaySpeed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hPlaySpeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function [a2fMinMouseDist, a2iClosestMouse] = fnComputeMiceDist(astrctTrackers)
iNumMice = length(astrctTrackers);
iNumFrames = length(astrctTrackers(1).m_afX);
% Detect cases where mice get too close to each other
a2fMinMouseDist = Inf*ones(iNumMice, iNumFrames);
a2iClosestMouse = zeros(iNumMice, iNumFrames);
for iMouseIter=1:iNumMice
    apt2fCent = [astrctTrackers(iMouseIter).m_afX;astrctTrackers(iMouseIter).m_afY];
    for iMouseIter2=setdiff(1:iNumMice, iMouseIter)
        apt2fCent2 = [astrctTrackers(iMouseIter2).m_afX;astrctTrackers(iMouseIter2).m_afY];
        afDist = sqrt(sum((apt2fCent2- apt2fCent).^2,1));
        aiLower = find(afDist < a2fMinMouseDist(iMouseIter,:));
        a2fMinMouseDist(iMouseIter,aiLower) = afDist(aiLower);
        a2iClosestMouse(iMouseIter,aiLower) = iMouseIter2;
    end;
end;
a2fMinMouseDist=abs(a2fMinMouseDist);

function [a2fVelocity] = fnComputeMiceVelocity(astrctTrackers)
iNumMice = length(astrctTrackers);
iNumFrames = length(astrctTrackers(1).m_afX);
a2fVelocity = zeros(iNumMice, iNumFrames);

for iMouseIter=1:iNumMice
    afX = real(astrctTrackers(iMouseIter).m_afX);
    afY = real(astrctTrackers(iMouseIter).m_afY);
    a2fVelocity(iMouseIter, :) = [0,sqrt((afX(2:end)-afX(1:end-1)).^2+(afY(2:end)-afY(1:end-1)).^2)];
end;

return;

% function fnMakeThetaSmooth(handles)
% %
% for iMouseIter=1:4
%     afTheta = astrctTrackers(iMouseIter).m_afTheta;
%     afTheta(afTheta<0) = afTheta(afTheta<0)+2*pi;
%     fPrevTheta = afTheta(1);
%     for iFrameIter=2:strctMovieInfo.m_iNumFrames
%         fCurrTheta = afTheta(iFrameIter);
%         fAngleDiff = min( abs(fCurrTheta-fPrevTheta), 2*pi-abs(fCurrTheta-fPrevTheta))/pi*180;
%         if fAngleDiff > 90
%             afTheta(iFrameIter) = afTheta(iFrameIter)+pi;
%             fPrevTheta  = afTheta(iFrameIter);
%         else
%             fPrevTheta = fCurrTheta;
%         end;
%     end;
%     afTheta(afTheta>2*pi) = afTheta(afTheta>2*pi)-2*pi;
%     afTheta(afTheta > pi) = afTheta(afTheta > pi) - 2*pi;
%     astrctTrackers(iMouseIter).m_afTheta = afTheta ;
% end;
% setappdata(handles.figure1,'astrctTrackers',astrctTrackers);
% fnInvalidate(handles);
% return;
% 
% figure;
% plot(afTheta)
% 
% return;
% 

function a2bGoodSamples = fnGetGoodTrainingSamples(astrctTrackers,fMinVelocity,fMinDistanceThreshold)
[a2fMinMouseDist, a2iClosestMouse] = fnComputeMiceDist(astrctTrackers);
[a2fVelocity] = fnComputeMiceVelocity(astrctTrackers);

fMinDistanceThreshold = 100;
fMinVelocity = 5;
aiWindowSize = [52,111];
% First, find reliable frames:
% 1. mouse velocity is larger than a threshold
% 2. it is not close to any other mouse

a2bGoodSamples = a2fMinMouseDist > 100 &  ...
    a2fVelocity > fMinVelocity;
return;



% --------------------------------------------------------------------
function hFixOrientationOnly_Callback(hObject, eventdata, handles)
fprintf('This is no longer functioning due to recent code changes\n');
assert(false);

astrctTrackers = getappdata(handles.figure1,'astrctTrackers');
strctMovieInfo = getappdata(handles.figure1,'strctMovieInfo');
strctAdditionalInfo = getappdata(handles.figure1,'strctAdditionalInfo');
[iLeftFrame,iRightFrame] = fnAskRange(handles);
if iLeftFrame < 0
    return;
end;

iNumMice = length(astrctTrackers);

ButtonName = questdlg('Recompute head-tail features?', ...
                         'HOG Question', ...
                         'Yes', 'No', 'No');
drawnow                     
if strcmpi(ButtonName,'Yes')
    astrctTrackersOld = astrctTrackers;
    astrctTrackers = rmfield(astrctTrackers,'m_astrctClass');

    h = waitbar(0,'Recomputing HOG Features and applying Head-Tail classifier only...');
    for k=1:iNumMice
        Dummy(k).m_fTheta  = 0;
    end;
    
    strctEmptyClass = struct('m_afValue',zeros(1,6),'m_fHeadTailValue',NaN);
    
    if ~isfield(astrctTrackers(1),'m_astrctClass')
        for k=1:iNumMice
            astrctTrackers(k).m_astrctClass(1:strctMovieInfo.m_iNumFrames) = strctEmptyClass;
        end;
    end;
    
    iNumFrames = iRightFrame-iLeftFrame+1;
    for iFrameIter=iLeftFrame:iRightFrame
        if mod(iFrameIter,10)==0
            waitbar((iFrameIter-iLeftFrame)/iNumFrames,h);
        end;
        a2iFrame = fnReadFrameFromVideo(strctMovieInfo,iFrameIter);
        %a3iRectified = zeros(52,111,iNumMice,'uint8');
        
        astrctElipses = fnGetTrackersAtFrame(astrctTrackers,iFrameIter);
        a3iRectified = fnCollectRectifiedMice(a2iFrame, astrctElipses, []);
        
        [astrctEllipsesUpdated] = fnApplyMiceHeadTail(...
            Dummy, a3iRectified, strctAdditionalInfo);
        
        for iMouseIter=1:iNumMice
            astrctTrackers(iMouseIter).m_astrctClass(iFrameIter).m_fHeadTailValue = ...
                astrctEllipsesUpdated(iMouseIter).m_strctClass.m_fHeadTailValue;
        end;
        
    end;
    
    close(h);
end;

iNumFramesInChunk = 1000;
astrctTrackers=fnFixHeadTail(astrctTrackers,iNumFramesInChunk,strctAdditionalInfo,iLeftFrame,iRightFrame);

setappdata(handles.figure1,'astrctTrackers',astrctTrackers);

fnInvalidate(handles);
return;

% --------------------------------------------------------------------
function hRecomputeHOG_Callback(hObject, eventdata, handles)
fprintf('This is no longer functioning due to recent code changes\n');
assert(false);

astrctTrackers = getappdata(handles.figure1,'astrctTrackers');
strctMovieInfo = getappdata(handles.figure1,'strctMovieInfo');
strctAdditionalInfo = getappdata(handles.figure1,'strctAdditionalInfo');
iNumMice = length(astrctTrackers);
iNumFrames = length(astrctTrackers(1).m_afX);
for k=1:iNumMice
    Dummy(k).m_fTheta  = 0;
end;
astrctTrackers = rmfield(astrctTrackers,'m_astrctClass');

 h = waitbar(0,'Recomputing HOG Features...');
 
for iFrameIter=1:iNumFrames
    if mod(iFrameIter,10)==0
        waitbar(iFrameIter/iNumFrames,h);
    end;
 %   fprintf('%d\n',iFrameIter);
    a2fFrame = fnReadFrameFromVideo(strctMovieInfo,iFrameIter);
    a3iRectified = zeros(52,111,iNumMice,'uint8');
    for iMouseIter=1:iNumMice
     a3iRectified(:,:,iMouseIter) = uint8(fnRectifyPatch(a2fFrame,         ...
         astrctTrackers(iMouseIter).m_afX(iFrameIter),...
        astrctTrackers(iMouseIter).m_afY(iFrameIter),...
        astrctTrackers(iMouseIter).m_afTheta(iFrameIter)));
    end;
    [astrctEllipsesUpdated] = fnApplyMiceClassifiers(...
       Dummy, a3iRectified, strctAdditionalInfo);
   
    for iMouseIter=1:iNumMice
        astrctTrackers(iMouseIter).m_astrctClass(iFrameIter) = ...
        astrctEllipsesUpdated(iMouseIter).m_strctClass;
    end;
end;
close(h);
setappdata(handles.figure1,'astrctTrackers',astrctTrackers);

fnInvalidate(handles);
return;

% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function hExportToAVI_Callback(hObject, eventdata, handles)
% hObject    handle to hExportAVI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_2_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_3_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function hJobsGUI_Callback(hObject, eventdata, handles)
% hObject    handle to hJobsGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

JobsManager(handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
function varargout = JobsManager(varargin)
% JOBSMANAGER M-file for JobsManager.fig
%      JOBSMANAGER, by itself, creates a new JOBSMANAGER or raises the existing
%      singleton*.
%
%      H = JOBSMANAGER returns the handle to a new JOBSMANAGER or the handle to
%      the existing singleton*.
%
%      JOBSMANAGER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in JOBSMANAGER.M with the given input arguments.
%
%      JOBSMANAGER('Property','Value',...) creates a new JOBSMANAGER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before JobsManager_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to JobsManager_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help JobsManager

% Last Modified by GUIDE v2.5 31-Jan-2012 16:22:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       'JobsManager', ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @JobsManager_OpeningFcn, ...
    'gui_OutputFcn',  @JobsManager_OutputFcn, ...
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


% --- Executes just before JobsManager is made visible.
function JobsManager_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to JobsManager (see VARARGIN)

% Choose default command line output for JobsManager
handles.output = hObject;
handles.hMainWindow = varargin{1};
%
%fnRefreshJobList(handles);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes JobsManager wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = JobsManager_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles;


% --- Executes on selection change in hJobList.
function hJobList_Callback(hObject, eventdata, handles)
strctMovieInfo = getappdata(handles.hMainWindow.figure1,'strctMovieInfo');
acJobs = getappdata(handles.figure1,'acJobs');
if isempty(acJobs)
    return;
end;
aiSelectedJob = get(hObject,'value');
if length(aiSelectedJob) > 1
    iLeftFrame = ...
        min(strctMovieInfo.m_iNumFrames, ...
            acJobs{aiSelectedJob(1)}.strctJobInfo.m_aiFrameInterval(1));
else
    iLeftFrame = ...
        min(strctMovieInfo.m_iNumFrames, ...
            acJobs{aiSelectedJob}.strctJobInfo.m_aiFrameInterval(1));
end
setappdata(handles.hMainWindow.figure1,'iLeftFrame',iLeftFrame);
set(handles.hMainWindow.hLeftSlider,'value',iLeftFrame);
fnInvalidate(handles.hMainWindow);
return;


% --- Executes during object creation, after setting all properties.
function hJobList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hJobList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function fnRefreshJobList(handles)
% Load Job information
strResultFolder = getappdata(handles.hMainWindow.figure1,'strResultFolder');
astrctJobFiles = dir([strResultFolder,'Job*.mat']);
acstrJobFiles = cell(1, length(astrctJobFiles));
hWaitBar = waitbar(0,'Loading jobs, please wait...');
iNumJobs = length(astrctJobFiles);
acJobs = cell(1,iNumJobs);
a2iFrameRange = zeros(iNumJobs,2);
for k=1:iNumJobs
    acstrJobFiles{k} = [strResultFolder, astrctJobFiles(k).name];
    strctTmp = load(acstrJobFiles{k});
    a2iFrameRange(k,:) = ...
        [strctTmp.strctJobInfo.m_aiFrameInterval(1), strctTmp.strctJobInfo.m_aiFrameInterval(end)];
    waitbar(k/iNumJobs,hWaitBar);
end;
close(hWaitBar);

% Sort jobs according to start frame

% process jobs according to their initial frame...

[afDummy, aiSortedIndices] = sort(a2iFrameRange(:,1));
a2iFrameRange = a2iFrameRange(aiSortedIndices,:);
acstrJobFiles=acstrJobFiles(aiSortedIndices);
setappdata(handles.hMainWindow.figure1,'acstrJobFiles',acstrJobFiles);
%

% update the list
strJobList = '';
aiJobsIndices = zeros(1,iNumJobs);

if isunix || ismac
    strSlash = '/';
else
    strSlash = '\';
end;

for iJobIter=1:iNumJobs
    
    strJobIndex = acstrJobFiles{iJobIter}(7+find(acstrJobFiles{iJobIter}==strSlash,1,'last'):find(acstrJobFiles{iJobIter}=='.',1,'last')-1);
    aiJobsIndices(iJobIter) = str2num(strJobIndex);
    
    strJobList = [strJobList,'|','Job ',strJobIndex,...
        ':  [',num2str(a2iFrameRange(iJobIter,1)),'-',num2str(a2iFrameRange(iJobIter,2)),']',];
end;
if ~isempty(strJobList)
    strJobList = strJobList(2:end);
end;
set(handles.hJobList,'String',strJobList,'Min',1,'Max',iNumJobs);

abResultsFound = zeros(1,max(aiJobsIndices))>0;
abResultsFound(aiJobsIndices)=1;

aiIndices = find(~abResultsFound);
if ~isempty(aiIndices)
    fprintf('Warning. The following job results were not found. \n');
    fprintf('Do not merge results before these jobs are finished!\n');
    aiIndices
    
    ButtonName = questdlg('Resubmit missing jobs?', ...
        'Missing results', ...
        'Yes', 'No', 'Yes');
    
    if strcmpi(ButtonName,'Yes')
        strJobsFolder = getappdata(handles.hMainWindow.figure1,'strJobFolder');
        for iMissingJobs=1:length(aiIndices)
            strCmd=['qsub -t ', num2str(aiIndices(iMissingJobs)),' -N MouseJob -e ',strJobsFolder,' -o ',strJobsFolder,' -b y -cwd -V ',strJobsFolder,'submitscript'];
            fprintf('%s\n',strCmd);
            system(strCmd);
        end;
    end;
end;

return;

% --- Executes on button press in hJumpToFrame.
function hJumpToFrame_Callback(hObject, eventdata, handles)
% hObject    handle to hJumpToFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

iLeftFrame = getappdata(handles.figure1,'iLeftFrame');

prompt={'Jump To Frame:'};
name='Dialog';
numlines=1;
defaultanswer={num2str(iLeftFrame)};

answer=inputdlg(prompt,name,numlines,defaultanswer);

if ~isempty(answer)
    iLeftFrame = str2num(answer{1});
    fnSetNewValueForLeftFrame(iLeftFrame, handles);
end;


% --------------------------------------------------------------------
function hSimulateTracking_Callback(hObject, eventdata, handles)
fnSimulateTrackingFromFrame(handles);


% --------------------------------------------------------------------
function hCropSeq_Callback(hObject, eventdata, handles)
% iLeftFrame = getappdata(handles.figure1,'iLeftFrame');
% iRightFrame = getappdata(handles.figure1,'iRightFrame');
% strInputFile = getappdata(handles.figure1,'strAVIfilename');
% strOutputFileName = sprintf('%s_cropped_%d-%d.seq',strInputFile(1:end-4),iLeftFrame,iRightFrame);
% [strName, strPath] = uiputfile(strOutputFileName);
% strOutputFile = [strPath, strName];
% iJPGQuality = 80;
% fnCropSEQ(strInputFile, strOutputFile,iJPGQuality, iLeftFrame:iRightFrame);

%uiputfile('Cropped


% --------------------------------------------------------------------
function hFixIdentities_Callback(hObject, eventdata, handles)

astrctTrackers = getappdata(handles.figure1,'astrctTrackers');
if length(astrctTrackers) == 1
    errordlg('Only one mouse is present.');
    return;
end;


if ~isfield(astrctTrackers,'m_a2fClassifer')
    errordlg('Identeties were already corrected. It is not possible to run this algorithm twice.');
    return;
end;

strIDFile = getappdata(handles.figure1,'strIDFile');
strIDFolder = getappdata(handles.figure1,'strIDFile');
if isempty(strIDFile)
    [strFile, strPath] = uigetfile([strIDFolder,'*.mat'],'Enter Identities file for this sequence');
    if strFile(1) == 0
        return;
    end;
    strIDFile = [strPath,strFile];
end

strctID = load(strIDFile);
f=figure(3);
acstrColors = {'Red','Green','Blue','Cyan','Magenta','Yellow'};
iNumMice = size(strctID.strctIdentityClassifier.m_a3fRepImages,3);
iNumSubPlotsX = ceil(sqrt(iNumMice));
iNumSubPlotsY = ceil(iNumMice / iNumSubPlotsX);
for k=1:iNumMice
    tightsubplot(iNumSubPlotsY,iNumSubPlotsX,k,'Spacing',0.15,'Parent',f);
    imshow(strctID.strctIdentityClassifier.m_a3fRepImages(:,:,k),[]);
    title([num2str(k),' ',acstrColors{k}]);
end;
ButtonName = questdlg('Please confirm that these are the identities in the sequence', ...
                         'Important Question', ...
                         'OK', 'Not OK', 'OK');
if ~strcmp(ButtonName,'OK')
    delete(f);
    return;
end
delete(f)

strctMovieInfo = getappdata(handles.figure1,'strctMovieInfo');
aiBigJumps = 1+ (find(strctMovieInfo.m_afTimestamp(2:end)-strctMovieInfo.m_afTimestamp(1:end-1) > 1/strctMovieInfo.m_fFPS * 10));

abLargeTimeGap = zeros(1,length(astrctTrackers(1).m_afX))>0;
abLargeTimeGap(aiBigJumps) = 1;

fSwapPenalty = -200; % OA - debug: was -300
[astrctTrackersFixed2, afFrameReliability] = fnCorrectIdentitiesOnTheFly(astrctTrackers, strctID.strctIdentityClassifier, abLargeTimeGap, false,fSwapPenalty);
afSmoothFrameReliability = conv2(afFrameReliability, fspecial('gaussian',[1 800], 100),'same');
figure;
plot(afSmoothFrameReliability);
astrctPossibleProblems = fnGetIntervals(afSmoothFrameReliability < 0.4);
for k=1:length(astrctPossibleProblems)
    fprintf('Low prob at : [%d, %d]\n',astrctPossibleProblems(k).m_iStart,astrctPossibleProblems(k).m_iEnd);
end

setappdata(handles.figure1,'afSmoothFrameReliability',afSmoothFrameReliability);
setappdata(handles.figure1,'afFrameReliability',afFrameReliability);

setappdata(handles.figure1,'astrctTrackers',astrctTrackersFixed2);
fnInvalidate(handles);
return;
% --- Executes on button press in hNextDiff.
function hNextDiff_Callback(hObject, eventdata, handles)
% hObject    handle to hNextDiff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

return;  % temporary, until I figure out what these buttons are supposed
         % to do
aiDiffFrames = getappdata(handles.figure1,'aiDiffFrames');
aiDiffFrames = aiDiffFrames(:);
iNumDiff = length(aiDiffFrames);

iDiffFrameIndex = max(1, min(iNumDiff, getappdata(handles.figure1,'iDiffFrameIndex') + 1));
setappdata(handles.figure1,'iDiffFrameIndex',iDiffFrameIndex);

iFrame = aiDiffFrames(iDiffFrameIndex);
setappdata(handles.figure1,'iLeftFrame',iFrame);
fnInvalidate(handles);
return;

% --- Executes on button press in hPrevDiff.
function hPrevDiff_Callback(hObject, eventdata, handles)
% hObject    handle to hPrevDiff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

return;  % temporary, until I figure out what these buttons are supposed
         % to do
aiDiffFrames = getappdata(handles.figure1,'aiDiffFrames');
aiDiffFrames = aiDiffFrames(:);
iNumDiff = length(aiDiffFrames);

iDiffFrameIndex = max(1, min(iNumDiff, getappdata(handles.figure1,'iDiffFrameIndex') - 1));
setappdata(handles.figure1,'iDiffFrameIndex',iDiffFrameIndex);

iFrame = aiDiffFrames(iDiffFrameIndex);
setappdata(handles.figure1,'iLeftFrame',iFrame);
fnInvalidate(handles);
return;


% --------------------------------------------------------------------
function hSnapshotReview_Callback(hObject, eventdata, handles)
% hObject    handle to hSnapshotReview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

aiDiffFrames = getappdata(handles.figure1,'aiDiffFrames');
strctMovieInfo = getappdata(handles.figure1,'strctMovieInfo');
astrctTrackers = getappdata(handles.figure1,'astrctTrackers');
astrctTrackers2 = getappdata(handles.figure1,'astrctTrackers2');
strBaseSequence = getappdata(handles.figure1,'strBaseSequence');
strOtherSequence = getappdata(handles.figure1,'strOtherSequence');

SnapshotReview(strctMovieInfo, astrctTrackers, astrctTrackers2, aiDiffFrames, strBaseSequence, strOtherSequence);



% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

% Implements keys to advance by one frame, or go back one frame.
% Implmenting this functionality using the slider doesn't work for clips
% with more than 10^6 frames, which are common for us.  This is a
% limitation of the slider uicontrol, which is mentioned in the docs for
% the SliderStep uicontrol property in R2011a, but not R2008b.

%disp(eventdata.Key)
% switch eventdata.Character
%   case {',','<'}
%     i=getappdata(handles.figure1,'iLeftFrame');
%     if i>1
%       fnSetNewValueForLeftFrame(i-1, handles)
%     end
%   case {'.','>'}
%     i=getappdata(handles.figure1,'iLeftFrame');
%     strctMovieInfo = getappdata(handles.figure1,'strctMovieInfo');
%     n_frame=strctMovieInfo.m_iNumFrames;
%     if i<n_frame
%       fnSetNewValueForLeftFrame(i+1, handles)
%     end
% end
switch eventdata.Key
  case {'leftarrow','comma'}
    i=getappdata(handles.figure1,'iLeftFrame');
    if i>1
      fnSetNewValueForLeftFrame(i-1, handles)
    end
  case {'rightarrow','period'}
    i=getappdata(handles.figure1,'iLeftFrame');
    strctMovieInfo = getappdata(handles.figure1,'strctMovieInfo');
    n_frame=strctMovieInfo.m_iNumFrames;
    if i<n_frame
      fnSetNewValueForLeftFrame(i+1, handles)
    end
end
