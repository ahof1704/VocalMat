function fnPlayScene2Matrix(strctMov, aiMice,aiFrames, X,Y,A,B,Theta,fDelay, iAugument, aiEvents)
if ~exist('iAugument','var')
    iAugument = 0;
end;
if ~exist('aiEvents','var')
    aiEvents = [];
end

figure(11);
clf;
a2fColors = [1 0 0;
             0 1 0;
             0 0 1;
             1 0 1];
             

aiFramesAug = max(1,[aiFrames(1)-iAugument:aiFrames(1),aiFrames,aiFrames(end):aiFrames(end)+iAugument]);
if ~isempty(strctMov)
    a2fI= fnReadFrameFromSeq(strctMov, aiFramesAug(1));
else
    a2fI= 255*ones(768,1024,'uint8');
end

h=imshow(a2fI);
hold on;
hInInterval = rectangle('Position',[0 0 20 20],'facecolor','r');
hInEvent = rectangle('Position',[0 30 20 20],'facecolor','g');

abEvents = ismember(aiFramesAug, intersect(aiFramesAug, aiEvents));

for iFrameIter=1:length(aiFramesAug)
    if iFrameIter >= iAugument && iFrameIter < length(aiFramesAug)-iAugument
        set(hInInterval,'visible','on')
    else
        set(hInInterval,'visible','off')
    end
    if abEvents(iFrameIter)
         set(hInEvent,'visible','on')
    else
        set(hInEvent,'visible','off')
    end
    if ~isempty(strctMov)
        a2fI= fnReadFrameFromSeq(strctMov, aiFramesAug(iFrameIter));
    else
        a2fI= 255*ones(768,1024,'uint8');
    end
    
    set(h,'cdata',a2fI);

    ahHandles = [];
    for iMouseIter=1:length(aiMice)
        ahHandles = [ahHandles; fnDrawTrackers8( X(aiFramesAug(iFrameIter), aiMice(iMouseIter)),...
            Y(aiFramesAug(iFrameIter), aiMice(iMouseIter)),...
            A(aiFramesAug(iFrameIter), aiMice(iMouseIter)),...
            B(aiFramesAug(iFrameIter), aiMice(iMouseIter)),...
            Theta(aiFramesAug(iFrameIter), aiMice(iMouseIter)),...
            a2fColors(aiMice(iMouseIter),:))];
        
           ahHandles = [ahHandles;plot(X(aiFramesAug(1:iFrameIter), aiMice(iMouseIter)),...
             Y(aiFramesAug(1:iFrameIter), aiMice(iMouseIter)),'color',a2fColors(aiMice(iMouseIter),:),'linewidth',2,'linestyle','--')];
        
        if iFrameIter >= iAugument && iFrameIter <  length(aiFramesAug)-iAugument
        ahHandles = [ahHandles;plot(X(aiFramesAug(iAugument+1:iFrameIter), aiMice(iMouseIter)),...
             Y(aiFramesAug(iAugument+1:iFrameIter), aiMice(iMouseIter)),'color',a2fColors(aiMice(iMouseIter),:),'linewidth',2)];
        end
        
        if iFrameIter >= length(aiFramesAug)-iAugument
            
    ahHandles = [ahHandles;plot(X(aiFramesAug(iAugument+1:length(aiFramesAug)-iAugument), aiMice(iMouseIter)),...
             Y(aiFramesAug(iAugument+1:length(aiFramesAug)-iAugument), aiMice(iMouseIter)),'color',a2fColors(aiMice(iMouseIter),:),'linewidth',2)];
               
        ahHandles = [ahHandles;plot(X(aiFramesAug(length(aiFramesAug)-iAugument:iFrameIter), aiMice(iMouseIter)),...
             Y(aiFramesAug(length(aiFramesAug)-iAugument:iFrameIter), aiMice(iMouseIter)),'color',a2fColors(aiMice(iMouseIter),:),'linewidth',2,'linestyle','--')];
            
            
        end;
        
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