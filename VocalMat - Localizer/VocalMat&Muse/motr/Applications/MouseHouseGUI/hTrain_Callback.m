function hTrain_Callback(hObject, eventdata, handles)
% --- Executes on button press in hTrain.
% hObject    handle to hTrain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get userdata
hFig=gcbf;
u=get(hFig,'userdata');

% If no experiment has been selected, prompt the user to select one.
expSelected=u.expSelected;
if ~expSelected
  fnChooseExperiment(hFig);
end

% need to re-load userdat, since fnChooseExperiment() might have changed it
u=get(hFig,'userdata');
expSelected=u.expSelected;

% If there's _still_ no experiment selected (maybe the user hit "Cancel"),
% then just return
if ~expSelected
  return;
end

% Get thee single-cmouse clip file names from the userdata.
clipSMFNAbs=u.clipSMFNAbs;

% If no single-mouse clips have been selected, prompt the user to select
% them,
if isempty(clipSMFNAbs)
  fnSelectSingleMouseClips(hFig);
else
  % Even if there are single-mouse clips, see if the user wants to select
  % new ones.
  answer = questdlg('Do you want to select new single-mouse clips?', ...
                    'Question', ...
                    'Yes','No, keep these', ...
                    'Yes');
  if isempty(answer) || strcmpi(answer,'cancel')
    return;
  elseif strcmpi(answer,'Yes')
    fnSelectSingleMouseClips(hFig);
  end
end

% Need to re-load userdata, since fnSelectSingleMouseClips() might have
% changed it.
u=get(hFig,'userdata');
clipSMFNAbs=u.clipSMFNAbs;

% If there are no single-mouse clips selected, just return
if isempty(clipSMFNAbs)
  return;
end

% Even though the user pushed the "Train" button to get here, see if
% they really want to do training.
answer = questdlg('Do you want to run Training now?', ...
                  'Question','Yes','No, later','Yes');
if isempty(answer) || strcmpi(answer,'cancel') || ...
   strcmpi(answer,'No, later')
  return;
end

% If we get here, the user has opted to run training.

% Set the training status to "in progress"
u.trainStatus=3;
set(hFig,'userdata',u);

% sync the view
fnUpdateGUIStatus(hFig);

% Do the training.
wasTrainingSuccessful=fnTrain(hFig);

% If we get here, and training finished successfully, update the model
% accordingly.
if wasTrainingSuccessful ,
  u=get(hFig,'userdata');
  u.trainStatus=4;
  set(hFig,'userdata',u);
end

% sync the view
fnUpdateGUIStatus(hFig);

end

