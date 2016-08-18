function fnSetCurrentSingleMouseClip(hFig, iClip)

u=get(hFig,'userdata');
u.iClipSMCurr=iClip;
set(hFig,'userdata',u);
fnUpdateGUIStatus(hFig);
