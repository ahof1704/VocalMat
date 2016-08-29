% function fnHourlyConfigurationEntryPoint_V5

acCage{1} = 'cage16_matrix.mat';
acCage{2} = 'cage17_matrix.mat';
acCage{3} = 'cage20_matrix.mat';
acCage{4} = 'cage19_matrix.mat';
acCage{5} = 'cage18_matrix.mat';
acCage{6} = 'cage23_matrix.mat';

                                       %Tracker: 1,2,3,4
% Dominant male is encoded by "1", Subordinate male is "2", females are 3 and 4                                       
a2iCageToMaleFeamle = [3,4,2,1;
                                             2,3,1,4;
                                             3,2,4,1;
                                             1,3,2,4;
                                             1,3,4,2;
                                             1,3,4,2];
% First entry: Dominant male, second, subordinate male, third and forth : females                                          
a2iCageToMaleFemalePermuation = [4,3,1,2;
                                              3,1,2,4;
                                              4,2,1,3,;
                                              1,3,2,4;
                                              1,4,2,3;
                                              1,4,2,3];
                                         
                                         

% First, show examples....
strFolder = 'D:\Data\Janelia Farm\ResultsFromNewTrunk\';
 strDatfile = [strFolder,'cage16_matrix.mat'];
 strctData = load(strDatfile);
 
 strColor = 'rgbcym';
 aiInterval=10000:10000+30*60*5; % 2
 figure(5);clf;hold on;
 for iMouseIter = 1:4
     figure(iMouseIter);
     clf;
     plot( strctData.X(aiInterval,iMouseIter),  strctData.Y(aiInterval,iMouseIter),strColor(iMouseIter),'LineWidth',1);
     axis([50 800 50 750]);
     box on
     set(gca,'xticklabel',[],'yticklabel',[]);
     P=get(gcf,'Position');
     P(3:4) = [116 86];
     set(gcf,'Position',P);
    figure(5);
      plot( strctData.X(aiInterval,iMouseIter),  strctData.Y(aiInterval,iMouseIter),strColor(iMouseIter),'LineWidth',1);
     axis([50 750 50 750]);
     box on
 end
 figure(5);
      P=get(gcf,'Position');
     P(3:4) = [116 86];
     set(gcf,'Position',P);
    set(gca,'xticklabel',[],'yticklabel',[]);
%%

%Now do the 30 mintutes, 12 hours and 5 days...
 aiInterval=10000:10000+30*60*30;
fnHourlyConfigurationEntryPoint_V5Aux(strctData,aiInterval, [-4 -1],6)

 aiInterval=10000:10000+30*60*60*12;
fnHourlyConfigurationEntryPoint_V5Aux(strctData,aiInterval, [-4 -1],6)

aiInterval=10000+30*60*60*12:10000+30*60*60*24;
fnHourlyConfigurationEntryPoint_V5Aux(strctData,aiInterval,  [-4 -1],6)

aiInterval=10000:12961047;
fnHourlyConfigurationEntryPoint_V5Aux(strctData,aiInterval,  [-4 -2],6)

aiIntervalDark= [];
aiIntervalLight= [];
iFramesPerDay = 30*60*60*24;
for k=1:5
    aiIntervalDark = [aiIntervalDark,(k-1)*iFramesPerDay+[1:iFramesPerDay/2]];
    aiIntervalLight = [aiIntervalLight,(k-1)*iFramesPerDay+[iFramesPerDay/2:iFramesPerDay]];
end
fnHourlyConfigurationEntryPoint_V5Aux(strctData,aiIntervalDark,  [-4 -2],6)

fnHourlyConfigurationEntryPoint_V5Aux(strctData,aiIntervalLight,  [-4 -1],6)

fnHourlyConfigurationEntryPoint_V5Aux(strctData,1:size(strctData.X,1),  [-4.5 -1.5],6)

%%
% Build ethogram of time spent at faviote locations...
% fnGenerateRegions()
%
%fnComputeTimeSpendInRegions(acCage,a2iCageToMaleFeamle)
a4fTimePerc= fnComputeTimeSpendInRegions(acCage);


%%
acRegionNames = {    'All Other Regions'    'Right tube'    'Left tube'    'Top left corner'    'Top right corner'    'Bottom left corner'    'Bottom right corner'    'Tube enterance'};
iNumCages= length(acCage);
a3fBars = zeros(8,4, iNumCages);
afSampleTimeHours = 0:0.1/6:120;
abSampleTimeDark = mod(afSampleTimeHours,24) <= 12;
abSampleTimeDark(end)=0;
abSampleTimeLight = ~abSampleTimeDark;
    figure(12);clf; hold on;

for iCageIter=1:iNumCages
    a3fTimePerc = a4fTimePerc(:,:,:,iCageIter);
    
%     fnPlotTimeSpentAtRegions(a3fTimePerc,acRegionNames)

    a2fTotalTime = squeeze(sum(a3fTimePerc,2));
    fTotalTime = sum(a2fTotalTime(:,1));
     a2fTotalTimeNormalized = a2fTotalTime / fTotalTime;
     a2fTotalTimeNormalizedMalesFirst = a2fTotalTimeNormalized(:,a2iCageToMaleFemalePermuation(iCageIter,:));
    a3fBars(:,:,iCageIter)=a2fTotalTimeNormalizedMalesFirst;
    
    % Time spent in cornerrs vs. tubes, vs. all other places
    a3fTimePercMalesFirst = a3fTimePerc(:,:, a2iCageToMaleFemalePermuation(iCageIter,:));
    
    a2fTimeSpentInOtherRegions = squeeze(sum(a3fTimePercMalesFirst([1,8],:,:),1))';
    a2fTimeSpentInTubes = squeeze(sum(a3fTimePercMalesFirst(1:2,:,:),1))';
    a2fTimeSpentInCorners = squeeze(sum(a3fTimePercMalesFirst(4:7,:,:),1))';
    
    A=conv2(a2fTimeSpentInOtherRegions(:,abSampleTimeDark),fspecial('gaussian',[100 1], 10)','same');
    B=conv2(a2fTimeSpentInTubes(:,abSampleTimeDark),fspecial('gaussian',[100 1], 10)','same');
    Ct=conv2(a2fTimeSpentInCorners,fspecial('gaussian',[100 1], 10)','same');
    C=Ct(:,abSampleTimeDark);
       
    iNumPoints = size(C,2);
    strColor = 'rgbcym';
    for k=1:4
        plot(1:iNumPoints,iCageIter-1+C(k,:),'color',strColor(k));
    end;
    plot([1 iNumPoints],[iCageIter iCageIter],'k--');
    
    a2fMeanStat(iCageIter,:)=[mean(mean(C(:,1:720))),mean(mean(C(:,721:2*720))),mean(mean(C(:,720*2:3*720))),mean(mean(C(:,720*3:4*720))),mean(mean(C(:,720*4:5*720)))];
end
axis([1 iNumPoints  0 6]);

for k=1:6
    plot((k-1)*720*ones(1,2),[0 6],'k','LineWidth',3);
end
legend('Male 1','Male 2','Female 1','Female 2','location','northeastoutside')
set(gca,'xtick',360:720:3600,'xticklabel',{'1','2','3','4','5'})
set(gca,'ytick',0.5:1:6,'yticklabel',1:6)
set(gcf,'position',[     1182         606         466         492]);
%%



a2fAllCages = reshape(a3fBars, 8,4 * iNumCages);
figure(12);clf;
imagesc(flipud(a2fAllCages))
set(gca,'xtick',0.5:4:26,'xticklabel',[])
hold on;
for k=1:iNumCages
    plot(1+4*[k k]-0.5,[0.5 8.5 ],'w','LineWidth',2);
end
set(gca,'ytick',1:8,'yticklabel',[]);
colorbar

T1=a2fAllCages(4:7,:);
T2=a2fAllCages(1,:);
T3=a2fAllCages(2:3,:);

ranksum(T1(:),T2(:))
ranksum(T1(:),T3(:))
figure(600);clf;
ahBars=bar(median(a3fBars,3));
set(ahBars(1),'facecolor','b');
set(ahBars(2),'facecolor','c');
set(ahBars(3),'facecolor','r');
set(ahBars(4),'facecolor','g');
%%



    if 0
    dbg = 1;
    % Higher order statistics...
    a2iPairs = nchoosek(1:4,2);
    clear a3fCorr
    for iDwellPlaceIter = 1:iNumDwellingPlaces
        for iPairIter=1:size(a2iPairs,1)
            
            iMouseA = a2iPairs(iPairIter,1);
            iMouseB = a2iPairs(iPairIter,2);
            acPairIter{iPairIter} = sprintf('%d - %d',iMouseA,iMouseB);
%             afCurve1 = conv2(a3fTimePerc(iDwellPlaceIter,:,iMouseA)', fspecial('gaussian',[50 1],4),'same');
%             afCurve2 = conv2(a3fTimePerc(iDwellPlaceIter,:,iMouseB)', fspecial('gaussian',[50 1],4),'same');
            afCurve1 = a3fTimePerc(iDwellPlaceIter,:,iMouseA)';
            afCurve2 = a3fTimePerc(iDwellPlaceIter,:,iMouseB)';
              [afCorr, afLags]=xcorr(afCurve1,afCurve2,'coeff');
            a3fCorr(iPairIter, iDwellPlaceIter,:) = afCorr;
        end;
    end
    iDwellPlaceIter = 7;
    figure(600+iCageIter);
    clf;
    subplot(2,1,1);
    plot(afLags,squeeze(a3fCorr(:,iDwellPlaceIter+1,:)));
    hold on;
    plot([0 0],[0 1],'w');
    legend(acPairIter)
    xlabel('Lag (minutes)');
    ylabel('Correlation');
    title(sprintf('Dwelling %d',iDwellPlaceIter));
    subplot(2,1,2);
      plot(afLags,squeeze(a3fCorr(:,iDwellPlaceIter+1,:)));
    hold on;
    plot([0 0],[0 1],'w');
    legend(acPairIter)
    xlabel('Lag (minutes)');
    ylabel('Correlation');
    axis([-400 400 0 1]);

     %%
    % Higher order statistics...
    a2iPairs = nchoosek(1:4,2);
    for iPairIter = 1:size(a2iPairs,1)
        iMouseA = a2iPairs(iPairIter,1);
        iMouseB = a2iPairs(iPairIter,2);
        
        for iDwellPlaceIter1 = 1:iNumDwellingPlaces
            for iDwellPlaceIter2= 1:iNumDwellingPlaces
                afCurve1 = a3fTimePerc(iDwellPlaceIter1,:,iMouseA)';
                afCurve2 = a3fTimePerc(iDwellPlaceIter2,:,iMouseB)';
                a3fCorrFixedLag(iDwellPlaceIter1,iDwellPlaceIter2,iPairIter) = corr(afCurve1,afCurve2);
            end;
        end
    end
     
    figure(700+iCageIter);
    clf;
    for iPairIter=1:6
        tightsubplot(2,3,iPairIter,'Spacing',0.1);
        imagesc(0:iNumDwellingPlaces-1,0:iNumDwellingPlaces-1,a3fCorrFixedLag(:,:,iPairIter),[0 0.8]);
        set(gca,'xtick',0:iNumDwellingPlaces-1,'ytick',0:iNumDwellingPlaces-1);
        title(acPairIter{iPairIter});
    end
    
    imagesc(a2fCorr)
    
    subplot(2,1,1);
    plot(afLags,squeeze(a3fCorr(:,iDwellPlaceIter+1,:)));
    hold on;
    plot([0 0],[0 1],'w');
    legend(acPairIter)
    xlabel('Lag (minutes)');
    ylabel('Correlation');
    title(sprintf('Dwelling %d',iDwellPlaceIter));
    subplot(2,1,2);
      plot(afLags,squeeze(a3fCorr(:,iDwellPlaceIter+1,:)));
    hold on;
    plot([0 0],[0 1],'w');
    legend(acPairIter)
    xlabel('Lag (minutes)');
    ylabel('Correlation');
    axis([-400 400 0 1]);    
    end
end

%
%
%              figure(12);
%             clf;hold on;
%             for k=1:iNumDwellingPlaces
%                 astrctIntervals =fnMergeIntervals( fnGetIntervals(aiPlaces == k), iMergeTimeFrames);
%                 afOnset = cat(1,astrctIntervals.m_iStart);
%                 afOffset = cat(1,astrctIntervals.m_iEnd);
%                 afInterVisitIntervalMin = (afOffset(2:end)-afOnset(1:end-1))/3600;
%                 afCent = 0:0.5:180;
%                 [aiHist]=histc(afInterVisitIntervalMin,afCent);
%                 plot(afCent,double(k)+aiHist/max(aiHist))
%             end


%
%         end
%

%
%
% % Merge dwelling places (if possible...)
% iPrevCC = 0;
% clear a3iCC aiCC_To_Image
% for k=1:4
%     a2iFinal = a3iDweeling(:,:,k);
%     a2iFinal(a2iFinal<=1) = 0;
%     aiCC= setdiff(unique(a2iFinal(:)),0)-1;
%     a3iCC(:,:,k) = a2iFinal-1+iPrevCC;
%     aiCC_To_Image(iPrevCC+aiCC)=k;
%     iPrevCC = iPrevCC +length(aiCC);
% end
% iTotalNumberCC = max(a3iCC(:));
%
% a2fOverlapAB = zeros(iTotalNumberCC,iTotalNumberCC);
% for iCC1=1:iTotalNumberCC
%     for iCC2=1:iTotalNumberCC
%         i1=aiCC_To_Image(iCC1);
%         i2=aiCC_To_Image(iCC2);
%         a2iL1 = a3iCC(:,:,i1) ==iCC1 ;
%         a2iL2 = a3iCC(:,:,i2) == iCC2;
%         a2fOverlapAB(iCC1,iCC2) = sum(a2iL1(:) & a2iL2(:)) / sum(a2iL1(:)) * 1e2;
%     end
% end
%
% triu( a2fOverlapAB)
% tril(a2fOverlapAB)
%
% figure(13);clf;
% imagesc(1-abs(1-(a2fOverlapAB./a2fOverlapAB')),[0 0.4]);
% colormap gray
% impixelinfo


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



function  [a4fCumulative]=fnComputeFavoritePlaces(strctData,fTimeThresholdMin)
% fMinX = floor(min(strctData.X(:)));
% fMaxX = ceil(max(strctData.X(:)));
% fMinY = floor(min(strctData.Y(:)));
% fMaxY = ceil(max(strctData.Y(:)));
iNumMice = size(strctData.X,2);
iNumFrames = size(strctData.X,1);

iBlockSize = 10000;

fFPS = 30;
iNumFramesPerMinute = fFPS * 60;
iBlockSizeInFrames = iNumFramesPerMinute * 60;
iNumBlocks = round(iNumFrames/iBlockSizeInFrames);

aiBlockStartFrame = 1:iBlockSizeInFrames:iNumFrames;
a4fCumulative = zeros(768,1024,iNumMice,iNumBlocks);


afProcessingTime = zeros(1,iNumBlocks);

for iBlockIter=1:iNumBlocks
    fStartTime=cputime;
    aiRange = aiBlockStartFrame(iBlockIter):60:min(iNumFrames,aiBlockStartFrame(iBlockIter)+iBlockSizeInFrames-1);
    for iMouseIter=1:iNumMice
        for iFrameIter=1:length(aiRange)
            BW=fnEllipseToBinary(strctData.X(aiRange(iFrameIter),iMouseIter),...
                strctData.Y(aiRange(iFrameIter),iMouseIter),...
                strctData.A(aiRange(iFrameIter),iMouseIter),...
                strctData.B(aiRange(iFrameIter),iMouseIter),...
                strctData.Theta(aiRange(iFrameIter),iMouseIter),[768,1024]);
            a4fCumulative(:,:,iMouseIter,iBlockIter)  = a4fCumulative(:,:,iMouseIter,iBlockIter)  + double(BW)/length(aiRange);
        end;
    end
    
    
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
