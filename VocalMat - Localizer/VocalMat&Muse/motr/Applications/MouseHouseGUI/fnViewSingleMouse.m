function fnViewSingleMouse(a,b,handles)

i = get(handles.hSingleMouseListbox,'value');
u=get(gcbf,'userdata');
clipSMFNAbs=u.clipSMFNAbs;
clipSMFNAbsThis=clipSMFNAbs{i};
fnViewMovie(clipSMFNAbsThis);

end


