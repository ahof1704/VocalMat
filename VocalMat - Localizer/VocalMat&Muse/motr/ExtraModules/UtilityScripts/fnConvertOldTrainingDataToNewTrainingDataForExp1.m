load('D:\Data\Janelia Farm\Classifiers\MergedTraining_Experiment1.mat');
iNumMice = 4;
iNumSamples = 40000;
iNumHOGBins = 10;
bCollectFlipped = 1;
aiNumSamples = ones(1,iNumMice)*iNumSamples;
iHOG_Dim = 837;
a2fFeatures = zeros(sum(aiNumSamples), iHOG_Dim,'single');
a2fFeaturesFlipped = zeros(sum(aiNumSamples), iHOG_Dim,'single');

a3fRepImages = zeros(52,111, iNumMice);
a3fRepImages(:,:,1) = a4iTraining(:,:,1,1);
a3fRepImages(:,:,2) = a4iTraining(:,:,2,1);
a3fRepImages(:,:,3) = a4iTraining(:,:,3,1);
a3fRepImages(:,:,4) = a4iTraining(:,:,4,1);

aiStart = [0:(iNumMice-1)]*iNumSamples+1;
aiEnd = aiStart + iNumSamples-1;

% Extract all other patches...
[a2fX,a2fY]=meshgrid(1:111,linspace(1,52,51));

for iFrameIter=1:iNumSamples
    if mod(iFrameIter,100) == 0
        fprintf('Passed frame %d out of %d (%.2f %%) \n',iFrameIter, iNumSamples,iFrameIter/iNumSamples*1e2 );
        drawnow update
    end
    for iMouseIter=1:iNumMice
        a2fTmp = a4iTraining(:,:,iMouseIter,iFrameIter);
        a2fTmp=uint8(reshape(fnFastInterp2(single(a2fTmp),a2fX(:),a2fY(:)),size(a2fX)));
        
        Tmp = fnHOGfeatures(a2fTmp, iNumHOGBins);
        a2fFeatures(aiStart(iMouseIter)+iFrameIter-1,:) = Tmp(:)';
    end
    if bCollectFlipped
        a2fTmp = a4iTraining(:,:,iMouseIter,iFrameIter);
        a2fTmp=flipud(fliplr(uint8(reshape(fnFastInterp2(single(a2fTmp),a2fX(:),a2fY(:)),size(a2fX)))));
        
        Tmp = fnHOGfeatures(a2fTmp, iNumHOGBins);
        a2fFeaturesFlipped(aiStart(iMouseIter)+iFrameIter-1,:) = Tmp(:)';
    end;
end
acMovies{1} = 'D:\Data\Janelia Farm\Movies\SeqFiles\10.04.19.390_cropped_120-175.seq';