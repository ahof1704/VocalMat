function updateLocalClusterRadiobuttons(hFig)

% get the handles
handles=guidata(hFig);

% get the userdata from the GUI
u=get(hFig,'userdata');
clusterMode=u.clusterMode;

% Update the GUI widgets
set(handles.hLocalMode  ,'value',~clusterMode);
set(handles.hClusterMode,'value', clusterMode);

end
