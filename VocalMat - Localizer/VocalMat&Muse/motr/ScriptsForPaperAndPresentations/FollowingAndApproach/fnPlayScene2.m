function fnPlayScene2(strctMov, aiMice,aiFrames, astrctTrackers,fDelay, iAugument)
if ~exist('iAugument','var')
    iAugument = 0;
end;
figure(11);
clf;
acColor = 'rgbcym';
aiFramesAug = [aiFrames(1)-iAugument:aiFrames(1),aiFrames,aiFrames(end):aiFrames(end)+iAugument];
if ~isempty(strctMov)
    a2fI= fnReadFrameFromSeq(strctMov, aiFramesAug(1));
else
    a2fI= 255*ones(768,1024,'uint8');
end

h=imshow(a2fI);
hold on;
hInInterval = rectangle('Position',[0 0 20 20],'facecolor','r');
for iFrameIter=1:length(aiFramesAug)
    if iFrameIter >= iAugument && iFrameIter < length(aiFramesAug)-iAugument
        set(hInInterval,'visible','on')
    else
        set(hInInterval,'visible','off')
    end
    if ~isempty(strctMov)
        a2fI= fnReadFrameFromSeq(strctMov, aiFramesAug(iFrameIter));
    else
        a2fI= 255*ones(768,1024,'uint8');
    end
    
    set(h,'cdata',a2fI);

    ahHandles = [];
    for iMouseIter=1:length(aiMice)
        ahHandles = [ahHandles; fnDrawTrackers8( astrctTrackers(aiMice(iMouseIter)).m_afX(aiFramesAug(iFrameIter)),...
            astrctTrackers(aiMice(iMouseIter)).m_afY(aiFramesAug(iFrameIter)),...
            astrctTrackers(aiMice(iMouseIter)).m_afA(aiFramesAug(iFrameIter)),...
            astrctTrackers(aiMice(iMouseIter)).m_afB(aiFramesAug(iFrameIter)),...
            astrctTrackers(aiMice(iMouseIter)).m_afTheta(aiFramesAug(iFrameIter)),...
            acColor(aiMice(iMouseIter)));];
    end
    title(sprintf('Frame %d',aiFramesAug(iFrameIter)));

    drawnow
    tic
    while toc < fDelay
    end
    if iFrameIter ~= length(aiFramesAug)
        delete(ahHandles);
    end
end