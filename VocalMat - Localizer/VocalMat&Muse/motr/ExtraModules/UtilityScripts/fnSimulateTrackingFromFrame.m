% Simulate algorithm from frame iLeftFrame...
astrctTrackers = getappdata(handles.figure1,'astrctTrackers');
strctMovieInfo = getappdata(handles.figure1,'strctMovieInfo');
iNumMice = length(astrctTrackers);
iLeftFrame = getappdata(handles.figure1,'iLeftFrame');
strctAdditionalInfo = getappdata(handles.figure1,'strctAdditionalInfo');

for iPrev = iLeftFrame-2:iLeftFrame-1

    for iMouseIter=1:iNumMice
        astrctMiceTrackers(iPrev-iLeftFrame+3).m_astrctMouse(iMouseIter) = fnGetTrackerAtFrame(astrctTrackers,iMouseIter,iPrev);
    end;
end;
global g_bVERBOSE g_bDebugMode
g_bVERBOSE = true;
g_bDebugMode = true;

for iCurrFrame=iLeftFrame:strctMovieInfo.m_iNumFrames
    iOutputIndex = iCurrFrame-iLeftFrame+3;
    aiHistoryIndices = 1:iOutputIndex-1;
    a2iFrame = fnReadFrameFromVideo(strctMovieInfo, iCurrFrame);
    astrctMiceTrackers(iOutputIndex).m_astrctMouse =...
        fnJobProcessFrame(astrctMiceTrackers(aiHistoryIndices),...
        a2iFrame,strctAdditionalInfo,iNumMice);
end;

figure(11);
clf;
hold on;
iMouseFocus = 1;
hAxes = gca;
afCol = 'rgbcymk'
for k=1:length(aiHistoryIndices)
fnDrawTracker(hAxes,...
    astrctMiceTrackers(aiHistoryIndices(k)).m_astrctMouse(iMouseFocus),...
    afCol(k), 1, false);
end;


figure(12);
clf;
hold on;
iMouseFocus = 1;
hAxes = gca;
afCol = 'rgbcymk'
fnDrawTracker(hAxes,strctP1,'r', 1, false);
fnDrawTracker(hAxes,strctP2,'g', 1, false);
fnDrawTracker(hAxes,astrctPredictedEllipses(iMouseIter),'b',2,false);



