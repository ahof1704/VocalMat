function fnSetCurrentExpClip(hFig, iClip)

u=get(hFig,'userdata');
u.iClipCurr=iClip;
set(hFig,'userdata',u);
fnUpdateGUIStatus(hFig);
