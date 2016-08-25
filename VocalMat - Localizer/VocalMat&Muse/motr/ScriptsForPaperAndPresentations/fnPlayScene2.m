function fnPlayScene2(strctMov, aiMice,aiFrames, astrctTrackers,fDelay)
figure(11);
clf;
acColor = 'rgbcym';
a2fI= fnReadFrameFromSeq(strctMov, aiFrames(1));
h=imshow(a2fI);
hold on;
for iFrameIter=1:length(aiFrames)
    
    a2fI= fnReadFrameFromSeq(strctMov, aiFrames(iFrameIter));
    set(h,'cdata',a2fI);

    ahHandles = [];
    for iMouseIter=1:length(aiMice)
        ahHandles = [ahHandles; fnDrawTrackers8( astrctTrackers(aiMice(iMouseIter)).m_afX(aiFrames(iFrameIter)),...
            astrctTrackers(aiMice(iMouseIter)).m_afY(aiFrames(iFrameIter)),...
            astrctTrackers(aiMice(iMouseIter)).m_afA(aiFrames(iFrameIter)),...
            astrctTrackers(aiMice(iMouseIter)).m_afB(aiFrames(iFrameIter)),...
            astrctTrackers(aiMice(iMouseIter)).m_afTheta(aiFrames(iFrameIter)),...
            acColor(aiMice(iMouseIter)));];
    end
    title(sprintf('Frame %d',aiFrames(iFrameIter)));

    drawnow
    tic
    while toc < fDelay
    end
    
    delete(ahHandles);
end