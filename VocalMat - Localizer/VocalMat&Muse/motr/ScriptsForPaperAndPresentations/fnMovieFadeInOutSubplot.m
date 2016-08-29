function Mov=fnMovieFadeInOutSubplot(strctMovInfo, astrctTrackers, astrctInterval,iFadeInSec, iFadeOutSec,Mov,MovieOutputSize, aiSubplots,iPadding,aiSelectedMice)
FPS = 30;
afFadeIn = linspace(0.01,1, iFadeInSec*FPS);
afFadeOut = linspace(0.01,1, iFadeOutSec*FPS);
for k=1:length(astrctInterval)
    astrctInterval(k).m_iStart = astrctInterval(k).m_iStart - iPadding;
    astrctInterval(k).m_iEnd= astrctInterval(k).m_iEnd + iPadding;    
    astrctInterval(k).m_iLength =     astrctInterval(k).m_iLength + 2*iPadding;
end
aiLength = cat(1,astrctInterval.m_iLength);
for iIter=1:max(aiLength)

    for j=1:length(astrctInterval)
        if iIter <= aiLength(j)
            iFrameIter = astrctInterval(j).m_iStart+iIter;
            a2iFrame = fnReadFrameFromSeq(strctMovInfo, iFrameIter);
            astrctTrackersAtFrame = fnGetTrackersAtFrame(astrctTrackers, iFrameIter);
            hold off;
            tightsubplot(2,2,aiSubplots(j));
            if iIter< (iFadeInSec*FPS)
                a2iFrame = a2iFrame * afFadeIn(iIter);
                if max(a2iFrame(:)) > 0
                    imshow(a2iFrame);
                    hold on;
                    fnDrawTrackers3(astrctTrackersAtFrame,afFadeIn(iIter));
                end;
            elseif iIter > astrctInterval(j).m_iLength-(iFadeOutSec*FPS)
                Q =  astrctInterval(j).m_iLength-iIter+1;
                a2iFrame = a2iFrame * afFadeOut(Q);
                if max(a2iFrame(:)) > 0
                    imshow(a2iFrame);
                    hold on;
                    fnDrawTrackers3(astrctTrackersAtFrame,afFadeOut(Q));
                end;

            else
                imshow(a2iFrame);
                hold on;
                fnDrawTrackers3(astrctTrackersAtFrame,1);
            end;
            if ~isempty(aiSelectedMice)
                axis([astrctTrackersAtFrame(aiSelectedMice(j)).m_fX-300 astrctTrackersAtFrame(aiSelectedMice(j)).m_fX+300 ...
                    astrctTrackersAtFrame(aiSelectedMice(j)).m_fY-300 astrctTrackersAtFrame(aiSelectedMice(j)).m_fY+300])
            end;
        end
    end
    drawnow
    if ~isempty(Mov)
       M = getframe(gcf);
        a2fOutputFrame = imresize(M.cdata, MovieOutputSize,'bilinear');
        M.cdata = a2fOutputFrame;
        Mov = addframe(Mov,M);
    end

end;
