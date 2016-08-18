function navigateMovie(strctMovInfo, astrctTrackers, strctHeadPos, iTimeScale, Sniff)
%
iFrame = iTimeScale + 1;
button = 29;
while (1)
    showFrame(iFrame, strctMovInfo, astrctTrackers, strctHeadPos);
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
            state = Sniff(iFrame-iTimeScale);
            while Sniff(iFrame-iTimeScale)==state && iFrame<strctMovInfo.m_iNumFrames
                iFrame = min(strctMovInfo.m_iNumFrames, iFrame+1);
            end   
        case 31
            state = Sniff(iFrame-iTimeScale);
            while Sniff(iFrame-iTimeScale)==state && iFrame>iTimeScale+1
                iFrame = max(iTimeScale+1, iFrame-1);
            end
        otherwise
            break;
    end
end

