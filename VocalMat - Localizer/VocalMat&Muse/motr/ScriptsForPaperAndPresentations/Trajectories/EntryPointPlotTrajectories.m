strctResult = load('D:\Data\Janelia Farm\ResultsFromNewTrunk\cage16_array.mat');
iNumMice =4;
iNumMin = 5;
iStartFrame = 13000;
strctMov.m_fFps=30;
aiRange = iStartFrame:iStartFrame + strctMov.m_fFps * iNumMin * 60;
 strctMov.m_iWidth=768;
  strctMov.m_iHeight=768;
figure(1);
clf;
tightsubplot(1,1,1,'Spacing',0.01);
plot(strctResult.astrctTrackers(1).m_afX(aiRange),strctResult.astrctTrackers(1).m_afY(aiRange),'k');hold on;
plot([0 0 strctMov.m_iWidth strctMov.m_iWidth 0],[0 strctMov.m_iHeight strctMov.m_iHeight 0 0],'k','LineWidth',1);
axis equal
axis off

a2fColors = [234,79,231;
                      247,81,150;
                      86,174,252;
                      90,254,103;]/255;

a2fColors = [255,0,255;
                      255,0,0;
                      0,0,255;
                      0,255,0;]/255;
                  

                  
                  
iNumMin =2;
iStartFrame = 13000;
set(gcf,'color',[1 1 1]);
set(1,'Position',[   707   474   560   420]);

aiRange = iStartFrame:iStartFrame + strctMov.m_fFps * iNumMin * 60;


for iMouseIter=1:4
figure(iMouseIter);
clf;
plot(strctTrack.astrctTrackers(iMouseIter).m_afX(aiRange),strctTrack.astrctTrackers(iMouseIter).m_afY(aiRange),'color',a2fColors(iMouseIter,:));hold on;
axis off
plot([100 100 850 850 100],[50 750 750 50 50],'k','LineWidth',1);
axis equal
axis([90 860 40 760]);
set(iMouseIter,'color',[1 1 1]);
P=get(iMouseIter,'position');
P(3:4) = [ 133         111];
set(iMouseIter,'Position',P);
end

figure(1+iMouseIter);
clf;
hold on;
for iMouseIter=1:4
plot(strctTrack.astrctTrackers(iMouseIter).m_afX(aiRange),strctTrack.astrctTrackers(iMouseIter).m_afY(aiRange),'color',a2fColors(iMouseIter,:));hold on;
end
axis off
plot([100 100 850 850 100],[50 750 750 50 50],'k','LineWidth',1);
axis equal
axis([90 860 40 760]);
set(1+iMouseIter,'color',[1 1 1]);
P=get(1+iMouseIter,'position');
P(3:4) = [ 133         111];
set(1+iMouseIter,'Position',P);


% 
% 
% iNumMin = 5;
% 
% aiRange = iStartFrame:iStartFrame + strctMov.m_fFps * iNumMin * 60;
% afCol='rgbcym';
% figure(3);
% clf;hold on;
% for k=1:iNumMice
% plot(strctTrack.astrctTrackers(k).m_afX(aiRange),strctTrack.astrctTrackers(k).m_afY(aiRange),afCol(k));hold on;
% end
% axis off
% plot([0 0 strctMov.m_iWidth strctMov.m_iWidth 0],[0 strctMov.m_iHeight strctMov.m_iHeight 0 0],'k','LineWidth',3);
% axis equal
% 
% iNumMin = 30;
% iStartFrame = 13000;
% set(gcf,'color',[1 1 1]);
% set(3,'Position',[   707   474   560   420]);
% 
% aiRange = iStartFrame:iStartFrame + strctMov.m_fFps * iNumMin * 60;
% 
% figure(4);
% clf; hold on;
% for k=1:iNumMice
% plot(strctTrack.astrctTrackers(k).m_afX(aiRange),strctTrack.astrctTrackers(k).m_afY(aiRange),afCol(k));hold on;
% end
% axis off
% plot([0 0 strctMov.m_iWidth strctMov.m_iWidth 0],[0 strctMov.m_iHeight strctMov.m_iHeight 0 0],'k','LineWidth',3);
% axis equal
% set(gcf,'color',[1 1 1]);
% set(4,'Position',[   707   474   560   420]);
% 
% 
% 
% 
% 
% 
% I=fnReadFrameFromSeq(strctMov, aiRange(end));
% imshow(I,[]);hold on;
% afCol = 'rgbcy';
% for k=1:iNumMice
%     plot(strctTrack.astrctTrackers(k).m_afX(aiRange),strctTrack.astrctTrackers(k).m_afY(aiRange),afCol(k));
% end
% strctTrack.astrctTrackers(2).m_afTheta(aiRange(end)) = pi/4;
% 
% fnDrawTrackers7( strctTrack.astrctTrackers,aiRange(end));
% set(gcf,'color',[1 1 1]);
% 
% a2fKernel = fspecial('gaussian',[20 20],3);
% a3fPositionPreference = zeros(strctMov.m_iHeight,strctMov.m_iWidth,iNumMice);
% for k=1:iNumMice
%     a3fPositionPreference(:,:,k) = conv2( hist2(strctTrack.astrctTrackers(k).m_afX,strctTrack.astrctTrackers(k).m_afY,1:strctMov.m_iWidth,1:strctMov.m_iHeight), a2fKernel,'same');
%     a3fPositionPreference(:,:,k) = a3fPositionPreference(:,:,k) / max(max(a3fPositionPreference(:,:,k)));
% end
% 
% figure(2);
% clf;
% 
% for k=1:4
% tightsubplot(2,2,k);
% imshow((a3fPositionPreference(:,:,k)),[0 0.5]);colormap hot
% end
% figure(1);
% clf;
% imshow((a3fPositionPreference(:,:,1)),[0 0.5]);colormap hot
% colorbar
% 
% aiRange = 20000:80000;
% 
% figure(1);
% clf;
% I=fnReadFrameFromSeq(strctMov, aiRange(end));
% imshow(I,[]);hold on;
% afCol = 'rgbcy';
% for k=1:4
%     plot(strctTrack.astrctTrackers(k).m_afX(aiRange),strctTrack.astrctTrackers(k).m_afY(aiRange),afCol(k));
% end
% fnDrawTrackers7( strctTrack.astrctTrackers,aiRange(end));
% 
% 
% 
% 
% % Proximity statistics.
% iNumFrames = length(strctTrack.astrctTrackers(1).m_afX);
% a3fDist = zeros(iNumMice,iNumMice,iNumFrames);
% for i=1:iNumMice
%     for j=i+1:iNumMice
%         a3fDist(i,j,:) = sqrt((strctTrack.astrctTrackers(i).m_afX-strctTrack.astrctTrackers(j).m_afX).^2+...
%                          (strctTrack.astrctTrackers(i).m_afY-strctTrack.astrctTrackers(j).m_afY).^2);
%         a3fDist(j,i,:) = a3fDist(i,j,:);
%     end
% end
% 
% [afHist,afCent]=hist([squeeze(a3fDist(1,2,:));squeeze(a3fDist(1,3,:));squeeze(a3fDist(1,4,:));squeeze(a3fDist(2,3,:));squeeze(a3fDist(2,4,:));],500);
% afHist=afHist/sum(afHist);
% figure;
% semilogx(afCent,afHist,'LineWidth',2);
% axis([10^1 10^3 0 3.5*10^-3])
% set(gcf,'color',[1 1 1]);
% box on
% 
% iMouseA = 1;
% iMouseB = 2;
% A = squeeze(a3fDist(iMouseA,iMouseB,:));
% fDistOfInterest = 270; % 41,67,270,
% fWidth = 10;
% aiIndices = find(A > fDistOfInterest-fWidth & A < fDistOfInterest+fWidth );
% figure(12);
% clf;
% hold on;
% 
% for k=1:500:length(aiIndices)
%     iFrame = aiIndices(k);
% 
%     fNewAngle = strctTrack.astrctTrackers(iMouseB).m_afTheta(iFrame) - strctTrack.astrctTrackers(iMouseA).m_afTheta(iFrame);
% 
%     % Rotate position
%     pt2fRelativePosition = [strctTrack.astrctTrackers(iMouseB).m_afX(iFrame)-strctTrack.astrctTrackers(iMouseA).m_afX(iFrame);
%                             strctTrack.astrctTrackers(iMouseB).m_afY(iFrame)-strctTrack.astrctTrackers(iMouseA).m_afY(iFrame)];
% 
%     fAlpha = -strctTrack.astrctTrackers(iMouseA).m_afTheta(iFrame);
%     a2fRot = [cos(fAlpha) sin(fAlpha);
%               -sin(fAlpha) cos(fAlpha)];
%        
%     pt2fNewPosition = a2fRot * pt2fRelativePosition;
% 
%  fnDrawTrackers8(pt2fNewPosition(1),pt2fNewPosition(2),...
%     strctTrack.astrctTrackers(iMouseB).m_afA(iFrame),...
%     strctTrack.astrctTrackers(iMouseB).m_afB(iFrame),...
%     fNewAngle, 'r');
% 
% end
% fnDrawTrackers8(0,0,...
%     strctTrack.astrctTrackers(iMouseA).m_afA(iFrame),...
%     strctTrack.astrctTrackers(iMouseA).m_afB(iFrame),...
%     0, 'b');
% axis equal
% axis ij
% set(gcf,'color',[1 1 1])   
% box on
