function fnVerifyTrackingResultsPlay(a,b, hFig)
%
global g_bPlaying
if isempty(g_bPlaying)
    g_bPlaying = 0;
end
g_bPlaying = ~g_bPlaying;

strctMovInfo = getappdata(hFig,'strctMovInfo');
strctIdentity = getappdata(hFig,'strctIdentity');
hImage = getappdata(hFig,'hImage');

hSlider=getappdata(hFig,'hSlider');
iCurrSliderFrame = get(hSlider,'value');
for iNewFrame=round(iCurrSliderFrame:strctMovInfo.m_iNumFrames)
    if ~ishandle(hSlider)
        break;
    end
    
    set(hSlider,'value',iNewFrame);
    I=fnReadFrameFromVideo(strctMovInfo,iNewFrame);
    set(hImage,'cdata',I);
    ahDrawHandles = getappdata(hFig,'ahDrawHandles');
    delete(ahDrawHandles);
    hAxes = getappdata(hFig,'hAxes');
    strctTracker.m_fX = strctIdentity.m_afX(iNewFrame);
    strctTracker.m_fY = strctIdentity.m_afY(iNewFrame);
    strctTracker.m_fA = strctIdentity.m_afA(iNewFrame);
    strctTracker.m_fB = strctIdentity.m_afB(iNewFrame);
    strctTracker.m_fTheta = strctIdentity.m_afTheta(iNewFrame);
    ahDrawHandles = fnDrawTracker(hAxes,strctTracker, [0 1 0], 2, false);
    ahDrawHandles(end+1) = text(500,20,num2str(iNewFrame),'color',[1 0 0]);
    setappdata(hFig,'ahDrawHandles',ahDrawHandles);
    if ~g_bPlaying
        break;
    end
    drawnow 
    drawnow update 
end

return;

