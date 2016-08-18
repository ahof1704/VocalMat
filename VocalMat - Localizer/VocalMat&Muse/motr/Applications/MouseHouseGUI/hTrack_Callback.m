function hTrack_Callback(hObject, eventdata, handles)
% --- Executes on button press in hTrack.
% hObject    handle to hTrack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get userdata
hFig=gcbf;
u=get(hFig,'userdata');
expDirName=u.expDirName;
clipFNAbs=u.clipFNAbs;

% Generate the dir, file names we'll need.
sTuningDir = fullfile(expDirName, 'Tuning');
sDetectionFile = fullfile(sTuningDir, 'Detection.mat');
sClassifiersFile = fullfile(sTuningDir, 'Identities.mat');

% Make sure the classifiers file is present.
if ~exist(sClassifiersFile,'file')
  h=msgbox('Error. Identities file missing. Did the single mouse movies finish processing?');
  waitfor(h);
  return;
end;

% Figure out what clips will be tracked.
if isempty(clipFNAbs)
  fnSelectExperimentClips(hFig, false);
else
  answer = ...
    questdlg('Do you want to select new experiment clips?', ...
             'Question', ...
             'Yes', ...
             'Yes, but keep the old ones', ...
             'No, keep these', ...
             'Yes');
  if isempty(answer)
    return;
  end
  if strcmpi(answer(1:3),'Yes')
    bAppend = length(answer)>3;
    fnSelectExperimentClips(hFig, bAppend);
  end
end

% fnSelectExperiment() modifies the the userdata, so re-read it
u=get(hFig,'userdata');
clipFNAbs=u.clipFNAbs;
iClipCurr=u.iClipCurr;

% If there are no clips, for whatever reason, return without doing
% anything.
if isempty(clipFNAbs)
  return;
end

% Check for the "detection" file, and generate it if it's absent.
if exist(sDetectionFile, 'file')
  answer = ...
    questdlg('Detection is already tuned. Do you want to retune it?', ...
             'Question', ...
             'Yes, but starting from the previous tuning', ...
             'Yes, ignore previous tuning', ...
             'No, keep existing tuning', ...
             'No, keep existing tuning');
  if strcmpi(answer, 'Yes, but starting from the previous tuning')
    strctID = load(sClassifiersFile);  % Load the classifiers file.
    iNumMice = length(strctID.strctIdentityClassifier.m_astrctClassifiers);
    TuneSegmentationGUI(iNumMice, sTuningDir);
  elseif strcmpi(answer, 'Yes, ignore previous tuning')
    strctMovieInfo = fnReadVideoInfo(clipFNAbs{iClipCurr});
    strctID = load(sClassifiersFile);  % Load the classifiers file.
    set(hFig,'pointer','watch');
    drawnow('expose');  drawnow('update');
    fnTuneBackgroundFromScratch(strctMovieInfo, strctID, sTuningDir);
    set(hFig,'pointer','arrow');
    drawnow('expose');  drawnow('update');
  end
else
  clipFNAbsThis=clipFNAbs{iClipCurr};
  strctMovieInfo = fnReadVideoInfo(clipFNAbsThis);
  strctID = load(sClassifiersFile);  % Load the classifiers file.
  set(hFig,'pointer','watch');
  drawnow('expose');  drawnow('update');
  fnTuneBackgroundFromScratch(strctMovieInfo, strctID, sTuningDir);
  set(hFig,'pointer','arrow');
  drawnow('expose');  drawnow('update');
end

% Even though they got here by pressing the "Track" button, ask the user
% if they want to run tracking.
answer = ...
  questdlg('Do you want to run tracking now?', ...
           'Question', ...
           'Yes', ...
           'No, later', ...
           'Yes');
if isempty(answer) || strcmpi(answer,'No, later')
  return;
end

% Finally, run tracking...
fnTrack(hFig);

end

