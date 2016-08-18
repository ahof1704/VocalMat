function fnChooseExperiment(hFig)

% get the userdata, see if there's a current experiment
u=get(hFig,'userdata');
expSelected=u.expSelected;

% get the listbox selection
%handles=guidata(hFig);
%iList = get(handles.hChooseExp, 'Value');

sExp = uigetdir('.', ...
                'Choose directory of an experiment');
if sExp==0  % means user hit Cancel button
  fnUpdateGUIStatus(hFig);
  return;
end
%sExp = fnConvertToAbsolutePath(sExp);
if expSelected
  expDirName=u.expDirName;
  if any(strcmp(sExp, expDirName))
    % this means they selected the current experiment
    fnUpdateGUIStatus(hFig);
    %msgbox(['An experiment named ' sExp ' already exists']);
    return;
  end
end
setCurrentExperiment(hFig, sExp);
  
end
