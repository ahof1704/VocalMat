N = 7;
M = 6;
for iMouse=2:6
for iStart = 1:M*N:1400
figure(1);
clf;
for k=1:M*N
    if (iStart+k-1 <= 1400)
        tightsubplot(M,N,k,'Spacing',0.01);
        imagesc(squeeze(a4iRectified(iStart+k-1,:,:,iMouse)));
        axis equal
        axis off
        title(num2str(iStart+k-1));
    end
end
colormap gray
set(gcf,'PaperOrientation','landscape');
print(['C:\Mouse',num2str(iMouse),'.eps'],'-dpsc','-append');
end

end

% Interesting key frames:
249,252,599,690,876





iNumMice =6;
iSubsetSize = 5;
iFrameIter=1%:iSubsetSize :iNumFramesToSample
    aiFrameSubset = iFrameIter+[0:iSubsetSize-1];
    figure(2);
    clf;
    for iSubsetIter=1:iSubsetSize
        
        for k=1:iNumMice
            tightsubplot(iSubsetSize,iNumMice,(iSubsetIter-1)*iNumMice+k,'Spacing',0.05);
            imagesc(squeeze(a4iRectified(aiFrameSubset(iSubsetIter),:,:,k)));
            axis equal
            axis off
        end
    end
    set(gcf,'Name',sprintf('%d - %d',aiFrameSubset(1),aiFrameSubset(end)));
    drawnow
colormap gray
    %end

