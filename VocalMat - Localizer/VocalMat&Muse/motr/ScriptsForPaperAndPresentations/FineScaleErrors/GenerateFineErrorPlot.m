%% Configuration
if 0
strCage16Location = 'L:\popcage_16\';
strctMovInfo = fnReadVideoInfo([strCage16Location,'b6_popcage_16_110405_09.58.30.268.seq']);
end

strGTLocation = 'D:\Code\Janelia Farm\Data_For_Paper\';

%% fine scale GT
% Take on cage 16, sequence b6_popcage_16_110405_09.58.30.268.seq
strctTmp1 = load([strGTLocation,'HandMadeEllipsesAnu.mat']);
abAnnotated1 = cat(1,strctTmp1.strctBackground.m_astrctTuningEllipses.m_bValid);
strctTmp2 = load([strGTLocation,'HandMadeEllipsesAdi1_FirstAttempt.mat']);
abAnnotated2 = cat(1,strctTmp2.strctBackground.m_astrctTuningEllipses.m_bValid);
strctTmp4 = load([strGTLocation,'HandMadeEllipsesAdi2_FirstAttempt.mat']);
abAnnotated4 = cat(1,strctTmp4.strctBackground.m_astrctTuningEllipses.m_bValid);

% Adi's first attempt has bias in minor axis.
% Adi's second attempt has bias in position.....
% Trying to merge results from both to generate a clean ground truth...
strctTmp5 = load([strGTLocation,'HandMadeEllipsesAdi1_SecondAttempt.mat']);
strctTmp6 = load([strGTLocation,'HandMadeEllipsesAdi2_SecondAttempt.mat']);
iNumMice = 4;

for iFrameIter=1:length(strctTmp5.strctBackground.m_astrctTuningEllipses)
    for iMouseIter=1:iNumMice
        
        strctTmp2.strctBackground.m_astrctTuningEllipses(iFrameIter).m_astrctEllipse(iMouseIter).m_fB = strctTmp5.strctBackground.m_astrctTuningEllipses(iFrameIter).m_astrctEllipse(iMouseIter).m_fB;
        strctTmp4.strctBackground.m_astrctTuningEllipses(iFrameIter).m_astrctEllipse(iMouseIter).m_fB = strctTmp6.strctBackground.m_astrctTuningEllipses(iFrameIter).m_astrctEllipse(iMouseIter).m_fB;
    end
end
    

%%

aiAnnotatedInAll = find(abAnnotated4 & abAnnotated2 & abAnnotated1);

aiAnnotatedFrames = cat(1,strctTmp1.strctBackground.m_astrctTuningEllipses(aiAnnotatedInAll).m_iFrame);

astrctFineGT(1).m_astrctEllipses = strctTmp1.strctBackground.m_astrctTuningEllipses(aiAnnotatedInAll);
astrctFineGT(2).m_astrctEllipses = strctTmp2.strctBackground.m_astrctTuningEllipses(aiAnnotatedInAll);
astrctFineGT(3).m_astrctEllipses = strctTmp4.strctBackground.m_astrctTuningEllipses(aiAnnotatedInAll);

%% Bias in annotator?
% iNumFrames = length(astrctFineGT(iAnnotator).m_astrctEllipses);
% iNumAnnotators = 3;
% a3fA = zeros(iNumFrames,iNumMice, iNumAnnotators);
% a3fB = zeros(iNumFrames,iNumMice, iNumAnnotators);
% a3fTheta = zeros(iNumFrames,iNumMice, iNumAnnotators);
% for iAnnotator=1:iNumAnnotators
%     for iFrameIter=1:iNumFrames
%         for iMouseIter=1:iNumMice
%             a2fA(iFrameIter,iMouseIter,iAnnotator) = astrctFineGT(iAnnotator).m_astrctEllipses(iFrameIter).m_astrctEllipse(iMouseIter).m_fA;
%             a2fB(iFrameIter,iMouseIter,iAnnotator) = astrctFineGT(iAnnotator).m_astrctEllipses(iFrameIter).m_astrctEllipse(iMouseIter).m_fB;
%             a2fTheta(iFrameIter,iMouseIter,iAnnotator) = astrctFineGT(iAnnotator).m_astrctEllipses(iFrameIter).m_astrctEllipse(iMouseIter).m_fTheta;
%         end
%     end
% end
% 
% figure(10);
% clf;
% subplot(1,2,1);
% hold on;
% 
% a2fColors = lines(iNumAnnotators);
% for iAnnotator=1:iNumAnnotators
%     X=a2fTheta(:,:,iAnnotator);
%     [H,C]=hist(X(:),50);
%     plot(C,H, 'color', a2fColors(iAnnotator,:));
% end


%% Most updated Tracking results...
strctTmp3 = load('D:\Data\Janelia Farm\ResultsFromNewTrunk\cage16\b6_popcage_16_110405_09.58.30.268.mat');

%%
strctDiff12 = fnGenerateFineErrorPlotAux(aiAnnotatedFrames, astrctFineGT(1),astrctFineGT(2)); % Anu - Adi1
strctDiff13 = fnGenerateFineErrorPlotAux(aiAnnotatedFrames, astrctFineGT(1),astrctFineGT(3)); % Anu - Adi 2
strctDiff23 = fnGenerateFineErrorPlotAux(aiAnnotatedFrames, astrctFineGT(2),astrctFineGT(3)); % Adi 1 - Adi 2


%% Filter junk
iMaxDistancePixels = 20;
iMaxOrientationError = 30;

a2bJunkAnnotation = strctDiff12.m_a2fDiffPosX < -iMaxDistancePixels | strctDiff12.m_a2fDiffPosX > iMaxDistancePixels | ...
                                    strctDiff12.m_a2fDiffPosY < -iMaxDistancePixels | strctDiff12.m_a2fDiffPosY > iMaxDistancePixels | ...
                                    strctDiff12.m_a2fDiffOriDeg < -iMaxOrientationError | strctDiff12.m_a2fDiffOriDeg > iMaxOrientationError | ...
                                 strctDiff23.m_a2fDiffPosX < -iMaxDistancePixels | strctDiff23.m_a2fDiffPosX > iMaxDistancePixels | ...
                                    strctDiff23.m_a2fDiffPosY < -iMaxDistancePixels | strctDiff23.m_a2fDiffPosY > iMaxDistancePixels | ...
                                    strctDiff23.m_a2fDiffOriDeg < -iMaxOrientationError | strctDiff23.m_a2fDiffOriDeg > iMaxOrientationError | ...
                                 strctDiff13.m_a2fDiffPosX < -iMaxDistancePixels | strctDiff13.m_a2fDiffPosX > iMaxDistancePixels | ...
                                    strctDiff13.m_a2fDiffPosY < -iMaxDistancePixels | strctDiff13.m_a2fDiffPosY > iMaxDistancePixels | ...
                                    strctDiff13.m_a2fDiffOriDeg < -iMaxOrientationError | strctDiff13.m_a2fDiffOriDeg > iMaxOrientationError   ;
                                
abJunkAnnotation = a2bJunkAnnotation(:);
fprintf('%d annotation were dropped\n',sum(abJunkAnnotation));                                
fprintf('%d annotation kept\n',sum(~abJunkAnnotation));                          


afDiffX12 = strctDiff12.m_a2fDiffPosX(~abJunkAnnotation);
afDiffX13 = strctDiff13.m_a2fDiffPosX(~abJunkAnnotation);
afDiffX23 = strctDiff23.m_a2fDiffPosX(~abJunkAnnotation);

afDiffY12 = strctDiff12.m_a2fDiffPosY(~abJunkAnnotation);
afDiffY13 = strctDiff13.m_a2fDiffPosY(~abJunkAnnotation);
afDiffY23 = strctDiff23.m_a2fDiffPosY(~abJunkAnnotation);

afDiffOri12 = strctDiff12.m_a2fDiffOriDeg(~abJunkAnnotation);
afDiffOri13 = strctDiff13.m_a2fDiffOriDeg(~abJunkAnnotation);
afDiffOri23 = strctDiff23.m_a2fDiffOriDeg(~abJunkAnnotation);

afDiffA12 = strctDiff12.m_a2fDiffMajorAxis(~abJunkAnnotation);
afDiffA13 = strctDiff13.m_a2fDiffMajorAxis(~abJunkAnnotation);
afDiffA23 = strctDiff23.m_a2fDiffMajorAxis(~abJunkAnnotation);

afDiffB12 = strctDiff12.m_a2fDiffMinorAxis(~abJunkAnnotation);
afDiffB13 = strctDiff13.m_a2fDiffMinorAxis(~abJunkAnnotation);
afDiffB23 = strctDiff23.m_a2fDiffMinorAxis(~abJunkAnnotation);

afDiffAspect12 = strctDiff12.m_a2fDiffAspectRatio(~abJunkAnnotation);
afDiffAspect13 = strctDiff13.m_a2fDiffAspectRatio(~abJunkAnnotation);
afDiffAspect23 = strctDiff23.m_a2fDiffAspectRatio(~abJunkAnnotation);



    strctStandardDeviation.m_fX = std(afDiffX23);
    strctStandardDeviation.m_fY = std(afDiffY23);
    strctStandardDeviation.m_fA = std(afDiffA23);
    strctStandardDeviation.m_fB = std(afDiffB23);
    strctStandardDeviation.m_fTheta = std(afDiffOri23/180*pi);



figure(11);
clf;
subplot(2,4,1);
fnGenerateFineErrorPlotAux2(afDiffX12, afDiffX13, afDiffX23, linspace(-10,10,20), 0.35, 'mouse X location (pixels)');

subplot(2,4,2);
fnGenerateFineErrorPlotAux2(afDiffY12, afDiffY13, afDiffY23, linspace(-10,10,20), 0.35, 'mouse Y location (pixels)');
subplot(2,4,3);
fnGenerateFineErrorPlotAux2(afDiffOri12, afDiffOri13, afDiffOri23, linspace(-30,30,30), 0.25, 'mouse orientation (degrees)');
legend({'Annotator 1 - Annotator 2a','Annotator 1 - Annotator 2b','Annotator 2a - Annotator 2b'},'location','northeastoutside');

subplot(2,4,5);
fnGenerateFineErrorPlotAux2(afDiffA12, afDiffA13, afDiffA23, linspace(-10,10,30), 0.15, 'mouse major axis (pixels)');
subplot(2,4,6);
fnGenerateFineErrorPlotAux2(afDiffB12, afDiffB13, afDiffB23, linspace(-10,10,30), 0.3, 'mouse minor axis (pixels)');
subplot(2,4,7);
fnGenerateFineErrorPlotAux2(afDiffAspect12, afDiffAspect13, afDiffAspect23, linspace(-3,3,30), 0.45, 'mouse aspect ratio');

%% Normalized distance metric
afDistanceH1_H2 = [];
afDistanceM_H1= [];
afDistanceM_H2= [];
    afDistancePos_H1_H2 = [];
    afDistancePos_H1_M = [];
    afDistancePos_H2_M = [];

    afDistanceOri_H1_H2 = [];
    afDistanceOri_H1_M = [];
    afDistanceOri_H2_M = [];

iCounter = 1;
for iIter=1:length(aiAnnotatedFrames)
    for iMouseIter=1:iNumMice
        if a2bJunkAnnotation(iIter,iMouseIter)
            continue;
        end
        
    strctRes=fnGetTrackerAtFrame(strctTmp3.astrctTrackers, iMouseIter,astrctFineGT(1).m_astrctEllipses(iIter).m_iFrame);
    strctH1 = astrctFineGT(1).m_astrctEllipses(iIter).m_astrctEllipse(iMouseIter);    
    strctH2 = astrctFineGT(2).m_astrctEllipses(iIter).m_astrctEllipse(iMouseIter);    
    strctH3 = astrctFineGT(3).m_astrctEllipses(iIter).m_astrctEllipse(iMouseIter);    
    
    afDistanceH1_H2(iCounter) = fnNormalizedDistance(strctH1,strctH2,strctStandardDeviation);
    afDistanceM_H1(iCounter) = fnNormalizedDistance(strctH1,strctRes,strctStandardDeviation);
    afDistanceM_H2(iCounter) =fnNormalizedDistance(strctH2,strctRes,strctStandardDeviation);
    afDistanceM_H3(iCounter) =fnNormalizedDistance(strctH3,strctRes,strctStandardDeviation);
    
    afDistancePos_H1_H2(iCounter) = sqrt((strctH1.m_fX - strctH2.m_fX).^2 + (strctH1.m_fY - strctH2.m_fY).^2 );
    afDistancePos_H1_M(iCounter) = sqrt((strctH1.m_fX - strctRes.m_fX).^2 + (strctH1.m_fY - strctRes.m_fY).^2 );
    afDistancePos_H2_M(iCounter) = sqrt((strctH2.m_fX - strctRes.m_fX).^2 + (strctH2.m_fY - strctRes.m_fY).^2);
    afDistancePos_H3_M(iCounter) = sqrt((strctH3.m_fX - strctRes.m_fX).^2 + (strctH3.m_fY - strctRes.m_fY).^2);    

    afDistanceOri_H1_H2(iCounter) = abs(strctH1.m_fTheta - strctH2.m_fTheta)/pi*180;
    afDistanceOri_H1_M(iCounter) = abs(strctH1.m_fTheta - strctRes.m_fTheta)/pi*180;
    afDistanceOri_H2_M(iCounter) = abs(strctH2.m_fTheta - strctRes.m_fTheta)/pi*180;
    afDistanceOri_H3_M(iCounter) = abs(strctH3.m_fTheta - strctRes.m_fTheta)/pi*180;
    
    
%                                                          figure(12);
%                                                          clf;
%                                                          
%                                                          cla;hold on;
%                            fnDrawTrackers(strctH1,1,['rgbcym']);
%    fnDrawTrackers(strctH2,1,['rgbcym']);                           
%    fnDrawTrackers(strctRes,1,['rgbcym']);   
                                     
                                                             
    iCounter  = iCounter  + 1;
    end
end
PIX_TO_CM = 0.08;

median(afDistancePos_H1_H2)*PIX_TO_CM*10
mad(afDistancePos_H1_H2)*PIX_TO_CM*10

median(afDistancePos_H1_M)*PIX_TO_CM*10
mad(afDistancePos_H1_M)*PIX_TO_CM*10
median(afDistancePos_H2_M)*PIX_TO_CM*10
mad(afDistancePos_H2_M)*PIX_TO_CM*10

median(afDistanceOri_H1_H2)
mad(afDistanceOri_H1_H2)
median(afDistanceOri_H1_M)
mad(afDistanceOri_H1_M)
a2fColors = fnGetFancyColors();
%%
afCent = 0:0.2:50;
[afHistH1_H2]=histc(afDistanceH1_H2,afCent);
[afHistH1_M]=histc(afDistanceM_H1,afCent);
[afHistH2_M]=histc(afDistanceM_H2,afCent);
[afHistH3_M]=histc(afDistanceM_H3,afCent);

afHistH1_H2 = afHistH1_H2 / sum(afHistH1_H2);
afHistH1_M = afHistH1_M / sum(afHistH1_M);
afHistH2_M = afHistH2_M / sum(afHistH2_M);
afHistH3_M = afHistH3_M / sum(afHistH3_M);
figure(13);
clf;hold on;
semilogx((afCent),afHistH1_H2,'color',a2fColors(1,:),'LineWidth',2);
semilogx((afCent),afHistH1_M,'color',a2fColors(2,:),'LineWidth',2);
semilogx((afCent),afHistH2_M,'color',a2fColors(3,:),'LineWidth',2);

figure(11);
clf;
h1=semilogx(afCent,afHistH1_H2); hold on;
h2=semilogx(afCent,afHistH1_M);
h3=semilogx(afCent,afHistH2_M);
h4=semilogx(afCent,afHistH3_M);
set(h1,'color',a2fColors(1,:),'LineWidth',2);
set(h2,'color',a2fColors(2,:),'LineWidth',2);
set(h3,'color',a2fColors(3,:),'LineWidth',2);
set(h4,'color','c','LineWidth',2);
legend('Annotator1-Annotator2','Annotator1-Machine','Annotator2a-Machine','Annotator2b-Machine','Location','NorthEastOutside');
xlabel('normalized distance');
ylabel('Probability');
box on
set(gca,'xtick',[0, 0.5,  1, 2, 3, 10, 10^2])
set(gca,'ylim',[0 0.12])



%% Several examples of annotators and software
aiSelectedKeyFrames = [2,10,6,20];
aiSelectedMice = [2,2,3,1];
    figure(17);
clf;
for iKeyFrameIter=1:length(aiSelectedKeyFrames)
    subplot(1,1+length(aiSelectedKeyFrames),iKeyFrameIter);
    a2iFrame = fnReadFrameFromVideo(strctMovInfo, astrctFineGT(1).m_astrctEllipses(aiSelectedKeyFrames(iKeyFrameIter)).m_iFrame);
    imshow(a2iFrame);
    hold on;
    ahHandles1 = fnDrawTrackers(astrctFineGT(1).m_astrctEllipses(aiSelectedKeyFrames(iKeyFrameIter)).m_astrctEllipse,2,['bbbb']);
    ahHandles2 = fnDrawTrackers(astrctFineGT(2).m_astrctEllipses(aiSelectedKeyFrames(iKeyFrameIter)).m_astrctEllipse,2,['gggg']);
    
    for iMouseIter=1:4
    astrctRes(iMouseIter)=fnGetTrackerAtFrame(strctTmp3.astrctTrackers, iMouseIter,astrctFineGT(1).m_astrctEllipses(aiSelectedKeyFrames(iKeyFrameIter)).m_iFrame)
    end
    ahHandles3 =     fnDrawTrackers(astrctRes,2,['rrrr']);
    fXCenter = astrctFineGT(1).m_astrctEllipses(aiSelectedKeyFrames(iKeyFrameIter)).m_astrctEllipse(aiSelectedMice(iKeyFrameIter)).m_fX;
    fYCenter = astrctFineGT(1).m_astrctEllipses(aiSelectedKeyFrames(iKeyFrameIter)).m_astrctEllipse(aiSelectedMice(iKeyFrameIter)).m_fY;
    set(gca,'xlim',[fXCenter-50 fXCenter+50],'ylim',[fYCenter-50,fYCenter+50]);
    if (iKeyFrameIter == length(aiSelectedKeyFrames))
        legend([ahHandles1(1), ahHandles2(1), ahHandles3(1)],{'Annotator 1','Annotator 2','Machine'},'Location','NorthEastOutside');
    end

    drawnow

end

