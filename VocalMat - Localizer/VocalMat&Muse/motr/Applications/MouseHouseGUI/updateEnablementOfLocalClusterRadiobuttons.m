function updateEnablementOfLocalClusterRadiobuttons(hFig)

handles=guidata(hFig);
isLinuxAndClusterExecutablePresent=islinux()&&isClusterExecutablePresent();
set(get(handles.hProcessingModeGroup,'children'),'enable',onIff(isLinuxAndClusterExecutablePresent));

end
