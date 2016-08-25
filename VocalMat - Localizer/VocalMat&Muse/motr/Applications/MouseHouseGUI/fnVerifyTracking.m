function fnVerifyTracking(handles, iClip)
%
[strClipName, strctIdentity] = fnGetSingleMouseInfo(iClip);
if isempty(strctIdentity)
   msgbox('Tracking results were not found');
else
   hFig = figure;
   set(hFig,'Name',strClipName);
   hAxes = axes;
   setappdata(hFig,'hAxes',hAxes);
   strctMovInfo = fnReadVideoInfo(strClipName);
   setappdata(hFig,'strctMovInfo',strctMovInfo);
   I=fnReadFrameFromVideo(strctMovInfo,1);
   hImage = image([], [], I, 'BusyAction', 'cancel', 'Parent', hAxes, 'Interruptible', 'off','CDataMapping', 'scaled');
   setappdata(hFig,'hImage',hImage);
   colormap gray
   set(hAxes,'visible','off')
   setappdata(hFig,'strctIdentity',strctIdentity);
   set(hAxes,'units','pixels');
   A=get(hFig,'position');
   hSlider = uicontrol('style','slider','units','pixels','position',[100 10 A(3)-40 20],'parent',hFig,...
      'min',1,'max',strctMovInfo.m_iNumFrames,'sliderstep',[1/strctMovInfo.m_iNumFrames 10/strctMovInfo.m_iNumFrames], 'value',1,'callback',{@fnVerifyTrackingResults, hFig});
   
   hPlay = uicontrol('style','pushbutton','units','pixels','position',[10 10 70 20],'parent',hFig,...
      'String','Play','callback',{@fnVerifyTrackingResultsPlay, hFig});
   
   hold(hAxes,'on');
   setappdata(hFig,'hSlider',hSlider);
   fnVerifyTrackingResults(hSlider,[], hFig);
end;

