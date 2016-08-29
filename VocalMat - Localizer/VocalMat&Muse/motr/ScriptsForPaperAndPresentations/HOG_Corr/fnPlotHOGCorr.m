% A script that shows how HOG correlation drops as a function of ellipse
% pertubation.

strctMov = fnReadVideoInfo('D:\Data\Janelia Farm\Movies\mousetrack_18\b6_popcage_18_09.15.11_10.56.24.135.seq');


strctTrackingResults = load('D:\Data\Janelia Farm\ResultsFromNewTrunk\cage18_matrix.mat');
strctTmp=load('D:\Data\Janelia Farm\ResultsFromNewTrunk\cage18\b6_popcage_18_09.15.11_10.56.24.135.mat');
%%

figure(10);
clf;
imshow(I,[]);hold on;

ahHandles = fnDrawTrackers8(strctTmp.astrctTrackers(iMouse).m_afX(iFrame),...
                            strctTmp.astrctTrackers(iMouse).m_afY(iFrame),...
                            strctTmp.astrctTrackers(iMouse).m_afA(iFrame),...
                            strctTmp.astrctTrackers(iMouse).m_afB(iFrame),...
                            strctTmp.astrctTrackers(iMouse).m_afTheta(iFrame),...
                            'r');

%%

iFrame = 200;
iMouse = 4;
iNumTrials = 100;
afTheta = linspace(-pi/2,pi/2,91);
iCenter=find(afTheta==0);

a2fCumCorr=zeros(iNumTrials, length(afTheta));
for iTrial=1:iNumTrials
    iFrame = iTrial;
I=fnReadFrameFromSeq(strctMov,iFrame);


iNumBins = 11;
a2fRep = zeros(744, length(afTheta));
for i=1:length(afTheta)                        
a2fPatch = fnRectifyPatch(I,strctTmp.astrctTrackers(iMouse).m_afX(iFrame),...
                            strctTmp.astrctTrackers(iMouse).m_afY(iFrame),...    
                            strctTmp.astrctTrackers(iMouse).m_afTheta(iFrame)+afTheta(i));
Tmp = fnHOGfeatures(uint8(a2fPatch),iNumBins);
a2fRep(:,i) = Tmp(:);

end
afCorr = zeros(1,length(afTheta));
for i=1:length(afTheta)
    afCorr(i) = corr(a2fRep(:,i), a2fRep(:,iCenter));
end

a2fCumCorr(iTrial,:) = afCorr;
end;
%%
a2fColors = [188,44,47; % Red
 46,87,139; % Blue
 93,149,72; % Green
 231,160,60; % Brown/yellow
 0,162,232; % Bright blue
 192,192,192;
 128,128,128];


afX = afTheta/pi*180;
afY = mean(a2fCumCorr);
afS =std(a2fCumCorr,1);
aiNonNaN = ~isnan(afY);
afX = afX(aiNonNaN);
afY = afY(aiNonNaN);
afS = afS(aiNonNaN);
figure(13);
clf;hold on;
afColor1 = a2fColors(2,:)/255;
afColor2 = a2fColors(2,:)*0.7/255;
hHandle=fill([afX, afX(end:-1:1)],[afY+afS, afY(end:-1:1)-afS(end:-1:1)], afColor1);
plot(afX,afY, 'color', afColor2,'LineWidth',2);

xlabel('Angle offset');
ylabel('Pearson correlation');
grid off
box off
%%


%%
figure(12);
clf;
afOff = [-pi/2,0,pi/2];
for k=1:3
    a2fPatch = fnRectifyPatch(I,strctTmp.astrctTrackers(iMouse).m_afX(iFrame),...
                            strctTmp.astrctTrackers(iMouse).m_afY(iFrame),...    
                            strctTmp.astrctTrackers(iMouse).m_afTheta(iFrame)+afOff(k));
subplot(1,3,k);
imagesc(a2fPatch);
axis equal
axis off

end
colormap gray
%%
strctMov = fnReadVideoInfo('D:\Data\Janelia Farm\Movies\mousetrack_18\b6_popcage_18_09.15.11_22.56.24.848.seq');
I=fnReadFrameFromSeq(strctMov,200);
figure(14);
clf;
imshow(I,[]);hold on;
