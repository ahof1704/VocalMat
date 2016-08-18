function fnViewMovie(strMovie)

strctMovInfo = fnReadVideoInfo(strMovie);
hFig = figure;
set(hFig,'Name',strMovie);
hAxes = axes;
setappdata(hFig,'hAxes',hAxes);
setappdata(hFig,'strctMovInfo',strctMovInfo);
I=fnReadFrameFromVideo(strctMovInfo,1);
hImage = image([], [], I, ...
               'BusyAction', 'cancel', ...
               'Parent', hAxes, ...
               'Interruptible', 'off', ...
               'CDataMapping', 'scaled');
setappdata(hFig,'hImage',hImage);
colormap gray
set(hAxes,'visible','off')
set(hAxes,'units','pixels');
A=get(hFig,'position');
n_frame=strctMovInfo.m_iNumFrames;
hSlider = ...
  uicontrol('style','slider', ...
            'units','pixels', ...
            'position',[100 10 A(3)-120 20], ...
            'parent',hFig,...
            'min',1, ...
            'max',n_frame, ...
            'sliderstep', ...
              [1/n_frame 10/n_frame], ...
            'value',1, ...
            'callback',{@fnVerifyTrackingResults, hFig});

hPlay = uicontrol('style','pushbutton', ...
                  'units','pixels', ...
                  'position',[10 10 70 20], ...
                  'parent',hFig,...
                  'String','Play', ...
                  'callback',{@fnVerifyTrackingResultsPlay, hFig});

hJump = uicontrol('style','pushbutton', ...
                  'units','pixels', ...
                  'position',[10 35 70 20], ...
                  'parent',hFig, ...
                  'String','Jump', ...
                  'callback',{@fnJumpNewFrame, hFig});

hold(hAxes,'on');
setappdata(hFig,'hSlider',hSlider);
fnVerifyTrackingResults(hSlider,[], hFig);

return;





function fnVerifyTrackingResultsPlay(a,b, hFig)
global g_bPlaying
if isempty(g_bPlaying)
  g_bPlaying = 0;
end
g_bPlaying = ~g_bPlaying;

strctMovInfo = getappdata(hFig,'strctMovInfo');
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
  set(hFig,'Name',sprintf('Frame %d - %s',iNewFrame,strctMovInfo.m_strFileName));

  if ~g_bPlaying
    break;
  end
  drawnow
end

return





function fnVerifyTrackingResults(a,b, hFig)

iNewFrame = round(get(a,'value'));
strctMovInfo = getappdata(hFig,'strctMovInfo');
hImage = getappdata(hFig,'hImage');
I=fnReadFrameFromVideo(strctMovInfo,iNewFrame);
set(hImage,'cdata',I);
set(hFig,'Name',sprintf('Frame %d - %s',iNewFrame,strctMovInfo.m_strFileName));

return;




        
function fnJumpNewFrame(a,b,hFig)
prompt={'Enter frame number:'};
name='Jump to frame';
numlines=1;
defaultanswer={'1'};
answer=inputdlg(prompt,name,numlines,defaultanswer);
if isempty(answer)
  return;
end
hSlider = getappdata(hFig,'hSlider');
iNewFrame =  str2num(answer{1});
set(hSlider,'value',iNewFrame);
strctMovInfo = getappdata(hFig,'strctMovInfo');
hImage = getappdata(hFig,'hImage');
I=fnReadFrameFromVideo(strctMovInfo,iNewFrame);
set(hImage,'cdata',I);
set(hFig,'Name',sprintf('Frame %d - %s',iNewFrame,strctMovInfo.m_strFileName));
return;
