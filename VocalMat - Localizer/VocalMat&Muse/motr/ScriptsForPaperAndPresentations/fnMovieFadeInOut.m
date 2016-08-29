function Mov=fnMovieFadeInOut(strctMovInfo, astrctTrackers, aiInterval,iFadeInSec, iFadeOutSec,Mov,MovieOutputSize)
FPS = 30;
afFadeIn = linspace(0.01,1, iFadeInSec*FPS);
afFadeOut = linspace(0.01,1, iFadeOutSec*FPS);
for iIter=1:length(aiInterval)
    iFrameIter = aiInterval(iIter);
    a2iFrame = fnReadFrameFromSeq(strctMovInfo, iFrameIter);
    
    astrctTrackersAtFrame = fnGetTrackersAtFrame(astrctTrackers, iFrameIter);
    
    f=figure(10);
    %clf;
    hold off;
   % set(f,'Position',[ 246         106        1188         854]);
    if iIter< (iFadeInSec*FPS)
        a2iFrame = a2iFrame * afFadeIn(iIter);
        if max(a2iFrame(:)) > 0
            imshow(a2iFrame);
            hold on;
            fnDrawTrackers3(astrctTrackersAtFrame,afFadeIn(iIter));
        end;
    elseif iIter > length(aiInterval)-(iFadeOutSec*FPS)
        Q = length(aiInterval)-iIter+1;
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
    drawnow
    if ~isempty(Mov)
        M = getframe(gcf);
        a2fOutputFrame = imresize(M.cdata, MovieOutputSize,'bilinear');
        M.cdata = a2fOutputFrame;
        Mov = addframe(Mov,M);
    end
    
end;
