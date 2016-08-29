clear all
strFolder = 'D:\Data\Janelia Farm\ResultsFromNewTrunk\';
aiCages = [16,17,18,19,20];
iNumCages = length(aiCages);
iBlockSize = 10000;
iNumMice = 4;
figure(20);clf;

for iCageIter=1:length(aiCages)
    strDatfile = [strFolder,'cage',num2str(aiCages(iCageIter)),'_matrix.mat'];
    strctData = load(strDatfile);
    
    fMinX = floor(min(strctData.X(:)));
    fMaxX = ceil(max(strctData.X(:)));
    fMinY = floor(min(strctData.Y(:)));
    fMaxY = ceil(max(strctData.Y(:)));
    iNumMice = size(strctData.X,2);
    iNumFrames = size(strctData.X,1);
    afXBins = fMinX:5:fMaxX;
    afYBins = fMinY:5:fMaxY;
    iNumXBins = length(afXBins);
    iNumYBins = length(afYBins);
    

    fFPS = 30;
    iNumFramesPerMinute = fFPS * 60;
    iBlockSizeInFrames = iNumFramesPerMinute * 60;
    iNumBlocks = round(iNumFrames/iBlockSizeInFrames);
    
    aiBlockStartFrame = 1:iBlockSizeInFrames:iNumFrames;

    a3fMasterPlot = zeros(10*iNumYBins,  12*iNumXBins,iNumMice);
    for iMouseIter=1:iNumMice
        a2fMasterPlot = zeros(10*iNumYBins,  12*iNumXBins);
        for iBlockIter=1:iNumBlocks
            X,Y,A,B,Theta
            
            
            
            aiRange = aiBlockStartFrame(iBlockIter):min(iNumFrames,aiBlockStartFrame(iBlockIter)+iBlockSizeInFrames-1);
            a2fSmooth = fspecial('gaussian',[5 5]);
            a2fHist = conv2(hist2(strctData.X(aiRange,iMouseIter), strctData.Y(aiRange,iMouseIter), afXBins, afYBins),a2fSmooth,'same');
            a2fHist = a2fHist / max(a2fHist(:));
            [iXplc,iYplc]=ind2sub([12, 10],iBlockIter);
            aiXrng = 1+[(iXplc-1)*iNumXBins:(iXplc)*iNumXBins-1];
            aiYrng = 1+[(iYplc-1)*iNumYBins:(iYplc)*iNumYBins-1];
            a3fMasterPlot(aiYrng,aiXrng,iMouseIter) = a2fHist;
        end
    end
    %%
    figure(20);
   for iMouseIter=1:4
        tightsubplot(iNumCages,4 ,(iCageIter-1)*iNumMice+iMouseIter,'Spacing',0.05);
        imagesc((a3fMasterPlot(:,:,iMouseIter).^(0.1)));
        colormap hot;
        axis off
   end
    figure(20+iCageIter);
   for iMouseIter=1:4
        subplot(2,2,iMouseIter);
        imagesc((a3fMasterPlot(:,:,iMouseIter).^(0.1)));
        colormap hot;
        axis off
   end
    drawnow
end
%%
