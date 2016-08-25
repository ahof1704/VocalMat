function fnHourlyConfigurationEntryPoint
strFolder = 'D:\Data\Janelia Farm\ResultsFromNewTrunk\';
aiCages = [16,17,18,19,20,23,24];
iNumCages = length(aiCages);

fTimeThresholdMin = 4;
fProximityThreshold = 50;
iNumMice = 4;


for iCageIter=1:iNumCages
    strDatfile = [strFolder,'cage',num2str(aiCages(iCageIter)),'_matrix.mat'];
    strctData = load(strDatfile);
    
     strFavfile = [strFolder,'cage',num2str(aiCages(iCageIter)),'_Favorite.mat'];
     strCumPosfile = [strFolder,'cage',num2str(aiCages(iCageIter)),'_CumutlativePosition.mat'];

     %     if exist(strFavfile,'file')
%         load(strFavfile)
%         fnPercentTimeSpentAtFavoritePlace(strctData,a4bFavorite, fProximityThreshold);
%         
%         fnDisplayStatAboutFavoritePlaces(a4bFavorite);
%         
%     else
if exist(strCumPosfile,'file')
    load(strCumPosfile);
else
        [a4bFavorite,a4fCumulative]= fnComputeFavoritePlaces(strctData,fTimeThresholdMin);
        save(strFavfile,'a4bFavorite');
        save(strCumPosfile,'a4fCumulative');
end
%     end
    
    a3fCum_AllExp = sum(a4fCumulative,4);
    figure(iCageIter);
    clf;
    for iMouseIter=1:4
         tightsubplot(2,2,iMouseIter,'Spacing',0.01);
         imagesc(a3fCum_AllExp(:,:,iMouseIter),[0 5])
         axis off
        
        
        
    end
%     for iMouseIter = 1:4
%      figure(iMouseIter);
%      clf;
%      for k=1:120
%         tightsubplot(10,12,k);
%         imagesc(a4fCumulative(:,:,iMouseIter,k),[0 4/60])
%         axis off
%      end
%     end
     
     
end

return;


function fnDisplayStatAboutFavoritePlaces(a4bFavorite)
    iNumBlocks = 120;
    iNumMice = 4;
    a2iNumCC = zeros(iNumMice,iNumBlocks);
    for iMouseIter=1:iNumMice
        for i=1:iNumBlocks
            [T,a2iNumCC(iMouseIter,i)]=bwlabel(a4bFavorite(:,:,iMouseIter,i)>0);
        end
    end
    
    figure(13);
    clf;
    for iMouseIter=1:4
        subplot(2,2,iMouseIter);
        T=squeeze(sum(a4bFavorite(:,:,iMouseIter,:),4));
        imagesc(T,[0 40])
        title(sprintf('Mouse %d',iMouseIter));
        axis off
    end;
    
    figure(11);
    clf;hold on;
    for k=1:iNumMice
        subplot(iNumMice,1,k);
        bar(a2iNumCC(k,:));
          set(gca,'xlim',[0 120]);
    end
  return;
  
    

function  [a4bFavorite,a4fCumulative]=fnComputeFavoritePlaces(strctData,fTimeThresholdMin)
fMinX = floor(min(strctData.X(:)));
fMaxX = ceil(max(strctData.X(:)));
fMinY = floor(min(strctData.Y(:)));
fMaxY = ceil(max(strctData.Y(:)));
iNumMice = size(strctData.X,2);
iNumFrames = size(strctData.X,1);

iBlockSize = 10000;

afXBins = fMinX:5:fMaxX;
afYBins = fMinY:5:fMaxY;
iNumXBins = length(afXBins);
iNumYBins = length(afYBins);
    
fFPS = 30;
iNumFramesPerMinute = fFPS * 60;
iBlockSizeInFrames = iNumFramesPerMinute * 60;
iNumBlocks = round(iNumFrames/iBlockSizeInFrames);
    
aiBlockStartFrame = 1:iBlockSizeInFrames:iNumFrames;
a4bFavorite= zeros(fMaxX-fMinX,fMaxY-fMinY,iNumMice,iNumBlocks) > 0;
a4fCumulative = zeros(fMaxX-fMinX,fMaxY-fMinY,iNumMice,iNumBlocks);


afProcessingTime = zeros(1,iNumBlocks);

for iBlockIter=1:iNumBlocks
    fStartTime=cputime;
    a3fCumulative = zeros(fMaxX-fMinX,fMaxY-fMinY,iNumMice);
    aiRange = aiBlockStartFrame(iBlockIter):60:min(iNumFrames,aiBlockStartFrame(iBlockIter)+iBlockSizeInFrames-1);
    for iMouseIter=1:iNumMice
        for iFrameIter=1:length(aiRange)
            BW=fnEllipseToBinary(strctData.X(aiRange(iFrameIter),iMouseIter)-fMinX,...
                strctData.Y(aiRange(iFrameIter),iMouseIter)-fMinY,...
                strctData.A(aiRange(iFrameIter),iMouseIter),...
                strctData.B(aiRange(iFrameIter),iMouseIter),...
                strctData.Theta(aiRange(iFrameIter),iMouseIter),[fMaxX-fMinX,fMaxY-fMinY]);
            a3fCumulative(:,:,iMouseIter)  = a3fCumulative(:,:,iMouseIter)  + double(BW)/length(aiRange);
        end;
    end
    a4fCumulative(:,:,:,iBlockIter) = a3fCumulative;
    
         fMinutesInRange =  (aiRange(end)-aiRange(1)) / 30 / 60;
         for iMouseIter=1:iNumMice
         a2bThres= a3fCumulative(:,:,iMouseIter) > fTimeThresholdMin/fMinutesInRange;
            a2fDist = bwdist(a2bThres);
            a2bLowThres =  a3fCumulative(:,:,iMouseIter) > fTimeThresholdMin/2/fMinutesInRange & a2fDist <5;
            a4bFavorite(:,:,iMouseIter,iBlockIter) = a2bLowThres;
         end;
         
    afProcessingTime(iBlockIter) = cputime-fStartTime;

    iNumBlocksLeft =iNumBlocks - iBlockIter + 1;
    fApproxTimetoFinish = iNumBlocksLeft*mean(afProcessingTime(1:iBlockIter)) / 60;
    fprintf('Processing time for block %d: %.2f.  Approx time to finish job: %.2f (min) (%d blocks)\n',...
        iBlockIter, afProcessingTime(iBlockIter),fApproxTimetoFinish,iNumBlocksLeft );
         
end
return;
% 
% 
function fnPercentTimeSpentAtFavoritePlace(strctData,a4bFavorite, fProximityThreshold)
% Now compute time percentage spent at favorite places (as a function of time)....
fMinX = floor(min(strctData.X(:)));
fMaxX = ceil(max(strctData.X(:)));
fMinY = floor(min(strctData.Y(:)));
fMaxY = ceil(max(strctData.Y(:)));
    iNumMice = 4;
fFPS = 30;
iNumFramesPerMinute = fFPS * 60;
iBlockSizeInFrames = iNumFramesPerMinute * 60;
iNumFrames = size(strctData.X,1);
iNumBlocks = size(a4bFavorite,4);
    
aiBlockStartFrame = 1:iBlockSizeInFrames:iNumFrames;
        fQuant = 100;

iTimeSmoothingKernelFrames = iNumFramesPerMinute*2;
iNumTimePoints = 1080;
a3fTimePercentageInHangOut = zeros(iNumBlocks,iNumMice,iNumTimePoints);
for iBlockIter=1:iNumBlocks
    aiRange = aiBlockStartFrame(iBlockIter):1:min(iNumFrames,aiBlockStartFrame(iBlockIter)+iBlockSizeInFrames-1);

    for iMouseIter=1:iNumMice
        a2fDistanceToFavorite = bwdist( a4bFavorite(:,:,iMouseIter, iBlockIter));
        afX = strctData.X(aiRange,iMouseIter)-fMinX;
        afY = strctData.Y(aiRange,iMouseIter)-fMinY;
        % Interpolate missing X Values....
        afX(isnan(afX)) =  interp1(find(~isnan(afX)),afX(~isnan(afX)), find(isnan(afX)));
        afY(isnan(afY)) =  interp1(find(~isnan(afY)),afY(~isnan(afY)), find(isnan(afY)));
        
        afDist =  interp2(a2fDistanceToFavorite, afX,afY);
        abInHangOut = afDist < fProximityThreshold;
        afTimerPercentage = conv2(double(abInHangOut)', ones(1,iTimeSmoothingKernelFrames )/iTimeSmoothingKernelFrames ,'same');
        afTimerPercentageSmooth = conv2(afTimerPercentage, fspecial('gaussian',[1 25],3),'same');
%         afTime = 1:length(afTimerPercentage);
%         afTimeSubSampled = afTime(1:fQuant:end);
        afTimerPercentageSmoothSubSampled = afTimerPercentageSmooth(1:fQuant:end);
        a3fTimePercentageInHangOut(iBlockIter,iMouseIter,:) =  afTimerPercentageSmoothSubSampled;
    end
end
figure(13);
clf;
iMouseA = 1;
iMouseB = 2;
for iBlockIter=1:120
    iBlockIter = 16
    afCorr(iBlockIter) = corr(squeeze(a3fTimePercentageInHangOut(iBlockIter,iMouseA,:)),     squeeze(a3fTimePercentageInHangOut(iBlockIter,iMouseB,:)));
end
plot(afCorr)
return


             figure(12);
             clf;
             hold on;
             for iMouseIter=1:iNumMice
                plot(1:length(aiRange), a2fTimePercentageInHangOut(iMouseIter,:) + iMouseIter-1)
                plot([0 length(aiRange)],[iMouseIter-1,iMouseIter-1],'k--');
             end 
             set(gca,'ytick',[0:4],'yticklabel',[],'ylim',[0 4],'xlim',[0 length(aiRange)])

             %% Sensitivity to proximity threshold
     fProximityThreshold = 15;
         iTimeSmoothingKernelFrames = iNumFramesPerMinute*2;
         aiRange = aiBlockStartFrame(iBlockIter):min(iNumFrames,aiBlockStartFrame(iBlockIter)+iBlockSizeInFrames-1);
         for iMouseIter=1:iNumMice
            afX = strctData.X(aiRange,iMouseIter)-fMinX;
            afY = strctData.Y(aiRange,iMouseIter)-fMinY;
              afDist =  interp2(a3fDistanceToHandOut(:,:,iHangOutOfMice), afX,afY);
              abInHangOut = afDist < fProximityThreshold;
              a2fTimePercentageInHangOut(iMouseIter,:) = conv2(double(abInHangOut)', ones(1,iTimeSmoothingKernelFrames )/iTimeSmoothingKernelFrames ,'same');
         end
             figure(12);
             hold on;
             for iMouseIter=1:iNumMice
                plot(1:length(aiRange), a2fTimePercentageInHangOut(iMouseIter,:) + iMouseIter-1,'g')
             end
             
         
     iHangOutOfMice = 4;
         for iMouseIter=1:iNumMice
            aiRange = aiBlockStartFrame(iBlockIter):min(iNumFrames,aiBlockStartFrame(iBlockIter)+iBlockSizeInFrames-1);
            afX = strctData.X(aiRange,iMouseIter)-fMinX;
            afY = strctData.Y(aiRange,iMouseIter)-fMinY;
            subplot(4,1,iMouseIter)
            afDist =  interp2(a3fDistanceToHandOut(:,:,iHangOutOfMice), afX,afY);
            plot(a2fDistToHangOut(iMouseIter,:));
         end         
         
%          [afHist,afCent] = hist(a2fDistToHangOut(:),5000);
%          figure(11);
%          clf;
% %          semilogx(afCent,log10(afHist));
%          plot(afCent,(afHist));
%          xlabel('Distance (pixels)');
%          ylabel('Prob');
%          axis([0 60 0 1000]);
%          figure;plot(a2fDistToHangOut')
%          
%          
%          
%          fNorm=  max(a3fCumulative(:));
%          figure(11);
%          clf;
%          a2iParis = nchoosek(1:4,2);
%          a2bColors = [1,0,0;0,1,0;0,0,1;0,1,1];
%         for j=1:4
%             tightsubplot(1,4,j,'Spacing',0.05);
%             X = zeros(fMaxX-fMinX,fMaxY-fMinY,3);
%             for k=1:3
%                 X(:,:,k) = a3fCumulative(:,:,j)*a2bColors(j,k);
%             end
%             X=X./fNorm;
%             X=min(1,X*2);
%             imagesc(X);
%             axis off
%         end
%         
%             
%         
%       fNorm=  max(a3fCumulative(:));
%          figure(11);
%          clf;
%          a2iParis = nchoosek(1:4,2);
%          a2bColors = [1,0,0;0,1,0;0,0,1;0,1,1];
%         for j=1:4
%             tightsubplot(1,4,j,'Spacing',0.05);
%             imagesc(a3fCumulative(:,:,j),[0 fNorm/2]);
%             axis off
%         end
% %         impixelinfo
%        colormap jet;
% %                 
%         
%       fNorm=  max(a3fCumulative(:));
%          figure(13);
%          clf;
%          a2iParis = nchoosek(1:4,2);
%          a2bColors = [1,0,0;0,1,0;0,0,1;0,1,1];
%         for j=1:4
%             tightsubplot(1,4,j,'Spacing',0.05);
%             imagesc(a3bHangOutPlaces(:,:,j),[0 1]);
%             axis off
%         end
% %         impixelinfo
%        colormap gray;        
% 
% 
%         
%         
%             
%             a2fSmooth = fspecial('gaussian',[5 5]);
%             a2fHist = conv2(hist2(strctData.X(aiRange,iMouseIter), strctData.Y(aiRange,iMouseIter), afXBins, afYBins),a2fSmooth,'same');
%             a2fHist = a2fHist / max(a2fHist(:));
%             [iXplc,iYplc]=ind2sub([12, 10],iBlockIter);
%             aiXrng = 1+[(iXplc-1)*iNumXBins:(iXplc)*iNumXBins-1];
%             aiYrng = 1+[(iYplc-1)*iNumYBins:(iYplc)*iNumYBins-1];
%             a3fMasterPlot(aiYrng,aiXrng,iMouseIter) = a2fHist;
%         end
    %end
    %%
%     
%    for iMouseIter=1:4
%         tightsubplot(iNumCages,4 ,(iCageIter-1)*iNumMice+iMouseIter,'Spacing',0.05);
%         imagesc((a3fMasterPlot(:,:,iMouseIter).^(0.1)));
%         colormap hot;
%         axis off
%    end
%     figure(20+iCageIter);
%    for iMouseIter=1:4
%         subplot(2,2,iMouseIter);
%         imagesc((a3fMasterPlot(:,:,iMouseIter).^(0.1)));
%         colormap hot;
%         axis off
%    end
%     drawnow

%%
