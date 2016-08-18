function varargout = ResubmitJobsGUI(varargin)
% RESUBMITJOBSGUI M-file for ResubmitJobsGUI.fig
%      RESUBMITJOBSGUI, by itself, creates a new RESUBMITJOBSGUI or raises the existing
%      singleton*.
%
%      H = RESUBMITJOBSGUI returns the handle to a new RESUBMITJOBSGUI or the handle to
%      the existing singleton*.
%
%      RESUBMITJOBSGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RESUBMITJOBSGUI.M with the given input arguments.
%
%      RESUBMITJOBSGUI('Property','Value',...) creates a new RESUBMITJOBSGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ResubmitJobsGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ResubmitJobsGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ResubmitJobsGUI

% Last Modified by GUIDE v2.5 10-Mar-2009 12:10:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ResubmitJobsGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @ResubmitJobsGUI_OutputFcn, ...
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


% --- Executes just before ResubmitJobsGUI is made visible.
function ResubmitJobsGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ResubmitJobsGUI (see VARARGIN)

% Choose default command line output for ResubmitJobsGUI

handles.output = hObject;
strJobsFolder = varargin{1};
setappdata(handles.figure1,'strJobsFolder',strJobsFolder);
%%
astrctJobFiles = dir([strJobsFolder,'Job*.mat']);
acstrJobFiles = cell(1, length(astrctJobFiles));
hWaitBar = waitbar(0,'Loading jobs, please wait...');
iNumJobs = length(astrctJobFiles);
acJobs = cell(1,iNumJobs);
a2iFrameRange = zeros(iNumJobs,2);
for k=1:iNumJobs
    acstrJobFiles{k} = [strJobsFolder, astrctJobFiles(k).name];
    acJobs{k} = load(acstrJobFiles{k});
    a2iFrameRange(k,:) = ...
        [acJobs{k}.strctJob.m_aiFrameInterval(1), acJobs{k}.strctJob.m_aiFrameInterval(end)];
    waitbar(k/iNumJobs,hWaitBar);
end;
close(hWaitBar);


% Sort jobs according to start frame

% process jobs according to their initial frame...

aiFirstFrame = zeros(1,iNumJobs);
for k=1:iNumJobs
    aiFirstFrame(k) = acJobs{k}.strctJob.m_aiFrameInterval(1);
end;
[afDummy, aiSortedIndices] = sort(aiFirstFrame);
a2iFrameRange = a2iFrameRange(aiSortedIndices,:);
acJobs=acJobs(aiSortedIndices);
acstrJobFiles=acstrJobFiles(aiSortedIndices);

%

setappdata(handles.figure1,'acstrJobFiles',acstrJobFiles);
setappdata(handles.figure1,'acJobs',acJobs);
% update the list
strJobList = '';
aiJobsIndices = zeros(1,iNumJobs);

if isunix || ismac
    strSlash = '/';
else
    strSlash = '\';
end;

for iJobIter=1:iNumJobs
    
    strJobIndex = acstrJobFiles{iJobIter}(9+find(acstrJobFiles{iJobIter}==strSlash,1,'last'):find(acstrJobFiles{iJobIter}=='.',1,'last')-1);
    aiJobsIndices(iJobIter) = str2num(strJobIndex);
    
    strJobList = [strJobList,'|','Job ',strJobIndex,...
        ':  [',num2str(a2iFrameRange(iJobIter,1)),'-',num2str(a2iFrameRange(iJobIter,2)),']',];
end;
if ~isempty(strJobList)
    strJobList = strJobList(2:end);
end;
set(handles.hJobList,'String',strJobList,'Min',1,'Max',iNumJobs);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ResubmitJobsGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ResubmitJobsGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in hJobList.
function hJobList_Callback(hObject, eventdata, handles)
% hObject    handle to hJobList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns hJobList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from hJobList


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


% --- Executes on button press in hResubmitSelected.
function hResubmitSelected_Callback(hObject, eventdata, handles)
aiSelectedJobs = get(handles.hJobList,'value');
acstrJobFiles = getappdata(handles.figure1,'acstrJobFiles');
if isunix || ismac
%    for iJobIter=1:length(aiSelectedJobs)
%         fprintf('Submittin Jobs\n');
%         strCmd = sprintf('qsub -t 1-%d -N MouseJob -e %s -o %s -b y -cwd -V ''%s''',iNumJobs-1, strJobFolder, strJobFolder, strSubmitFile);
%     end;
%     

else
    for iJobIter=1:length(aiSelectedJobs)
        fnJobAlgorithm(acstrJobFiles{aiSelectedJobs(iJobIter)});
    end;

end;

