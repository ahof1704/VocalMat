function compareClassifiers(strctMovInfo, astrctTrackers, strctHeadPos, iTimeScale, heuristic, sniff, aMiceInd)
%
iFrame = iTimeScale + 1;
button = 29;
while (1)
    showFrame(iFrame, strctMovInfo, astrctTrackers, strctHeadPos, aMiceInd);
    title(['frame ' num2str(iFrame) '   Heuristic:' num2str(heuristic(iFrame-iTimeScale)) '  Boosting: ' num2str(sniff(iFrame-iTimeScale))]);
    [x,y,button] = ginput(1);
    if isempty(button)
        break;
    end
    switch button
        case 28
            iFrame = max(iTimeScale+1, iFrame-1);
        case 29
            iFrame = min(strctMovInfo.m_iNumFrames, iFrame+1);
        case 30
            state = (sniff(iFrame-iTimeScale) == heuristic(iFrame-iTimeScale));
            while ( (sniff(iFrame-iTimeScale) == heuristic(iFrame-iTimeScale))==state || ...
                          (sniff(iFrame-iTimeScale+1) == heuristic(iFrame-iTimeScale+1))==state || ...
                          (sniff(iFrame-iTimeScale+2) == heuristic(iFrame-iTimeScale+2))==state) && ...
                         iFrame<strctMovInfo.m_iNumFrames-2
                iFrame = min(strctMovInfo.m_iNumFrames, iFrame+1);
            end   
        case 31
            state = (sniff(iFrame-iTimeScale) == heuristic(iFrame-iTimeScale));
            while ( (sniff(iFrame-iTimeScale) == heuristic(iFrame-iTimeScale))==state || ...
                           (sniff(iFrame-iTimeScale-1) == heuristic(iFrame-iTimeScale-1))==state || ...
                           (sniff(iFrame-iTimeScale-2) == heuristic(iFrame-iTimeScale-2))==state) && ...
                           iFrame>iTimeScale+1
                iFrame = max(iTimeScale+1, iFrame-1);
            end
        otherwise
            break;
    end
end

