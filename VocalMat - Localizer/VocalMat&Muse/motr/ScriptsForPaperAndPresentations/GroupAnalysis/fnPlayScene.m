function fnPlayScene(strctData, aiMice, aiFrames, fDelay)
figure(11);
clf;
subplot(2,1,1);
hold on;
acColor='rgbcym';
fMinX = double(floor(min(strctData.X(:))));
fMaxX = double(ceil(max(strctData.X(:))));
fMinY = double(floor(min(strctData.Y(:))));
fMaxY = double(ceil(max(strctData.Y(:))));
axis([fMinX fMaxX fMinY fMaxY]);
set(gca,'xtick',[],'ytick',[]);
box on
axis('ij');
for iFrameIter=1:length(aiFrames)
     subplot(2,1,1);
    ahHandles = [];
    for iMouseIter=1:length(aiMice)
        ahHandles = [ahHandles; fnDrawTrackers8( strctData.X(aiFrames(iFrameIter), aiMice(iMouseIter)),...
            strctData.Y(aiFrames(iFrameIter), aiMice(iMouseIter)),...
            strctData.A(aiFrames(iFrameIter), aiMice(iMouseIter)),...
            strctData.B(aiFrames(iFrameIter), aiMice(iMouseIter)),...
            strctData.Theta(aiFrames(iFrameIter), aiMice(iMouseIter)),...
            acColor(aiMice(iMouseIter)));];
        if iFrameIter >=2
            fVelX = strctData.X(aiFrames(iFrameIter), aiMice(iMouseIter))-strctData.X(aiFrames(iFrameIter-1), aiMice(iMouseIter));
            fVelY = strctData.Y(aiFrames(iFrameIter), aiMice(iMouseIter))-strctData.Y(aiFrames(iFrameIter-1), aiMice(iMouseIter));
            fVel = sqrt(fVelX.^2+fVelY.^2);
        else
            fVel = 0;
        end
        ahHandles = [ahHandles; text(fMinX+10,fMinY+60*iMouseIter,sprintf('%d: %.2f',aiMice(iMouseIter),fVel),'color',acColor(aiMice(iMouseIter)))];
    end
    title(sprintf('Frame %d',aiFrames(iFrameIter)));
    
    
    if iFrameIter > 21
        subplot(2,1,2);
        cla;hold on;
        for iMouseIter=1:length(aiMice)
            
            fVelX = strctData.X(aiFrames(iFrameIter-20:iFrameIter), aiMice(iMouseIter))-strctData.X(aiFrames(iFrameIter-21:iFrameIter-1), aiMice(iMouseIter));
            fVelY = strctData.Y(aiFrames(iFrameIter-20:iFrameIter), aiMice(iMouseIter))-strctData.Y(aiFrames(iFrameIter-21:iFrameIter-1), aiMice(iMouseIter));
            fVel = sqrt(fVelX.^2+fVelY.^2);
            plot(-10:+10,fVel,acColor(aiMice(iMouseIter)));
        end
        axis([-10 10 0 30]);
    end
    drawnow
    tic
    while toc < fDelay
    end
    
    delete(ahHandles);
end