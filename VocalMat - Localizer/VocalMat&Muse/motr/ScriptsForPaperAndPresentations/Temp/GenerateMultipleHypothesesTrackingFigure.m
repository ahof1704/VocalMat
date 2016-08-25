strctJob = load('E:\JaneliaResults\cage14\Jobs\b6_pop_cage_14_12.02.10_09.52.04.882\Jobargin97.mat');
load('SolveUsingConstrainedEMDebug');

strctMovInfo = fnReadVideoInfo( strctJob.strctJob.m_strMovieFileName);

%%

afXlim = [233, 409];
afYlim = [346, 478];

a2iFrame = fnReadFrameFromVideo(strctMovInfo, 408334);
[a2iLForeground,iNumBlobs] = fnSegmentForeground2(double(a2iFrame)/255, strctAdditionalInfo);
aiUseableBlobs = 1:iNumBlobs;
astrctProps = regionprops(a2iLForeground,'PixelList');
  a2fPixelList = cat(1,astrctProps(aiUseableBlobs).PixelList);
  [bFailed,acSolutions] = fnRiskyInit2(a2iFrame,strctAdditionalInfo,4,15,0);
 astrctPred = acSolutions{1};

bUseAppearance = isfield(strctAdditionalInfo,'strctAppearance');
a2bIntersect = fnEllipseIntersectionMatrix2(astrctPred);
[aiM1, aiM2] = find(triu(a2bIntersect));
if isempty(aiM1)
    iNumReinitializations = 1;
else
    % Multiple Hypotheses
    dbg = 1;
end;

iNumMice = length(astrctPred);

Data = a2fPixelList(1:g_strctGlobalParam.m_strctTracking.m_fExpectationMaximizationDataSubSamplingFactor:end,:)';

a3fOptMu = zeros(2,iNumMice,iNumReinitializations);
a4fSigma0 = zeros(2,2,iNumMice,iNumReinitializations);
a2fImageCorr = zeros(iNumReinitializations,iNumMice);
a2fPredError = zeros(iNumReinitializations,iNumMice);

aiUseableTrackers = 1:iNumMice;

a2fRandX = [zeros(iNumMice,1),fnMyRandN(iNumMice, iNumReinitializations-1) * 10];
a2fRandY = [zeros(iNumMice,1),fnMyRandN(iNumMice, iNumReinitializations-1) * 10];
a2fRandA = [zeros(iNumMice,1),fnMyRandN(iNumMice, iNumReinitializations-1) * 5];
a2fRandB = [zeros(iNumMice,1),fnMyRandN(iNumMice, iNumReinitializations-1) * 5];
a2fRandTheta = [zeros(iNumMice,1),fnMyRandN(iNumMice, iNumReinitializations-1) *60/180*pi];

aiIsolated = setdiff(1:iNumMice,[aiM1;aiM2]);

a2fRandX(aiIsolated,:) = 0;
a2fRandY(aiIsolated,:) = 0;
a2fRandA(aiIsolated,:) = 0;
a2fRandB(aiIsolated,:) = 0;
a2fRandTheta(aiIsolated,:) = 0;

afLogLike = zeros(1,iNumReinitializations);
a2fPriors = zeros(iNumReinitializations,iNumMice);



%
a2bSegmentation=zeros(size(a2iFrame),'uint8')>0;
a2bSegmentation(sub2ind(size(a2bSegmentation),a2fPixelList(:,2),a2fPixelList(:,1)))=1;

    figure(17);
    clf;
    tightsubplot(5,4,1,'Spacing',0.05);
    imshow(a2iFrame);
set(gca,'xlim',afXlim,'ylim',afYlim);
    tightsubplot(5,4,2,'Spacing',0.05);
    imshow(a2bSegmentation);
set(gca,'xlim',afXlim,'ylim',afYlim);

iOffset = 1;
for j=iOffset:iOffset+3
    astrctInput = astrctPred;
    for k=1:iNumMice
        astrctInput(k).m_fX = astrctInput(k).m_fX + a2fRandX(k,j);
        astrctInput(k).m_fY = astrctInput(k).m_fY + a2fRandY(k,j);
        astrctInput(k).m_fA = astrctInput(k).m_fA + a2fRandA(k,j);
        astrctInput(k).m_fB = astrctInput(k).m_fB + a2fRandB(k,j);
        astrctInput(k).m_fTheta = astrctInput(k).m_fTheta + a2fRandTheta(k,j);
    end;
    [Mu0, Sigma0] = fnEllipseArrayToCov(astrctInput);
    Priors0 =  ones(1,iNumMice)/iNumMice;
    
     tightsubplot(5,4,5+(j-iOffset)*4,'Spacing',0.05);
     imshow(a2iFrame,[]);
     hold on;
     fnDrawTrackers(astrctInput);
set(gca,'xlim',afXlim,'ylim',afYlim);
    
    [a2fOptMu, a3fOptCov, Priors, fLogLikelihood] = fnEM(Data, Mu0, Sigma0, Priors0,...
        g_strctGlobalParam.m_strctTracking.m_fExpectationMaximizationConvergence,...
        20);
    
        astrctOptEllipses = fnCov2EllipseArrayStrct(a2fOptMu, a3fOptCov);
         tightsubplot(5,4,6+(j-iOffset)*4,'Spacing',0.05);
     imshow(a2iFrame,[]);
     hold on;
     fnDrawTrackers(astrctOptEllipses);
   set(gca,'xlim',afXlim,'ylim',afYlim);
 
    
    if sum(isnan(a3fOptCov(:))) > 0
        % We probably lost a tracker and trying to fit too many elipses to
        % our data....
        continue;        
    end
    afLogLike(j) = fLogLikelihood;
    a3fOptMu(:,:,j) = a2fOptMu;
    a4fSigma0(:,:,:,j) = a3fOptCov;
    a2fPriors(j,:) = Priors;
     if bUseAppearance
        astrctOptEllipses = fnCov2EllipseArrayStrct(a2fOptMu, a3fOptCov);
        a2fImageCorr(j,:) = fnScoreFunction(a2iFrame, astrctOptEllipses, strctAdditionalInfo.strctAppearance);
        a2fPredError(j,:) = fnPredictionError(astrctOptEllipses, astrctPred);
    end;
end;

mean(a2fImageCorr(1:4,[1 2]),2)
%%
if bUseAppearance
    a2fImageCorr(isnan(a2fImageCorr))=0;
    a2fImageCorr(isinf(a2fImageCorr))=0;
    afMeanCorr = mean(a2fImageCorr,2);
    afMeanPredError = mean(a2fPredError,2);
    [fMaxCorr, iIndex] = max(afMeanCorr - g_strctGlobalParam.m_strctTracking.m_fHypothesisScorePositionWeight * afMeanPredError);
    afImageCorr = a2fImageCorr(iIndex,:);
    [a2fOptMu, a3fOptCov, Priors, fLogLikelihood] = fnEM(Data, a3fOptMu(:,:,iIndex), a4fSigma0(:,:,:,iIndex), Priors0,...
        g_strctGlobalParam.m_strctTracking.m_fExpectationMaximizationConvergence, 5);
    
    astrctOpt = fnCov2EllipseArrayStrct(a2fOptMu, a3fOptCov);
    
    
else
    aiNotValid = find(cat(1,sum(sum(isnan(a3fOptMu),1),2)));
    a3fOptMu(:,:,aiNotValid) = [];
    a2fOptMu = median(a3fOptMu,3);
    aiNotValid = find(cat(1,sum(sum(sum(isnan(a4fSigma0),1),2),3)));
    a4fSigma0(:,:,:,aiNotValid) = [];
    a3fOptCov = median(a4fSigma0,4);
    astrctOpt = fnCov2EllipseArrayStrct(a2fOptMu, a3fOptCov);
    fMaxCorr = 0;
end;

if 0
    figure(15);
    %clf;
    hold off;
    imshow(a2iFrame,[]);
    hold on;
    fnDrawTrackers(astrctOpt);
      fnDrawTrackers(astrctPred);
  
  fnDrawTrackers(astrctInput);
 
    for k=1:iNumMice
        fnDrawTracker(gca,astrctPred(k), 'm',1,false);
    end;
 
end;