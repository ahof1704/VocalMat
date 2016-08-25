function showEvent(strctBehavior, strctMovInfo, astrctTrackers, strctHeadPos)
%
frameStart = max(1, strctBehavior.m_iStart-30);
frameEnd = min(strctMovInfo.m_iNumFrames, strctBehavior.m_iEnd+20);
for iFrame=frameStart:frameEnd
    showFrame(iFrame, strctMovInfo,astrctTrackers, strctHeadPos);
end
