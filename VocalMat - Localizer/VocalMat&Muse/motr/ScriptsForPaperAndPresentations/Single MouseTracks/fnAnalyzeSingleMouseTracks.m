strRoot = 'D:\Data\Janelia Farm\Tracks_SingleMice\';
acSingleMiceVideos = {
'single_std_female1_12.15.11_23.04.36.220.mat'
'single_std_male1_12.03.11_11.11.39.271.mat'
'single_std_male2_12.09.11_11.14.45.199.mat'    
'single_std_female2_12.16.11_11.07.18.051.mat'
'single_std_male1_12.03.11_23.11.39.782.mat'   
'single_std_male2_12.09.11_23.14.45.670.mat'    
'single_std_female1_12.13.11_11.04.33.858.mat'  
'single_std_female2_12.16.11_23.07.18.502.mat'  
'single_std_male1_12.04.11_11.11.40.262.mat'    
'single_std_male2_12.10.11_11.14.46.140.mat'    
'single_std_female1_12.13.11_23.04.34.329.mat'  
'single_std_female2_12.17.11_11.07.18.982.mat'  
'single_std_male1_12.04.11_23.11.40.703.mat'    
'single_std_male2_12.10.11_23.14.46.610.mat'    
'single_std_female1_12.14.11_11.04.34.799.mat'  
'single_std_female2_12.17.11_23.07.19.453.mat'  
'single_std_male2_12.06.11_10.44.17.091.mat'    
'single_std_male2_12.11.11_11.14.47.071.mat'    
'single_std_female1_12.14.11_23.04.35.260.mat'  
'single_std_male1_12.02.11_11.11.38.340.mat'    
'single_std_male2_12.08.11_11.14.44.278.mat'    
'single_std_male2_12.11.11_23.14.47.531.mat'    
'single_std_female1_12.15.11_11.04.35.750.mat'  
'single_std_male1_12.02.11_23.11.38.801.mat'    
'single_std_male2_12.08.11_23.14.44.729.mat'    };
%%
for iIter=1:length(acSingleMiceVideos)
strctTrack = load([strRoot, acSingleMiceVideos{iIter}]);
iOffset =100000;

aiRange5Min = 1+[1:30*60*5];
aiRange30Min = 1+[1:30*60*30];


    fPositionThreshold= 0.7;%0.35;
    fVelocityThreshold = 0.2;
    afVel = [0,sqrt( (strctTrack.astrctTrackers.m_afX(2:end)-strctTrack.astrctTrackers.m_afX(1:end-1)).^2+ (strctTrack.astrctTrackers.m_afY(2:end)-strctTrack.astrctTrackers.m_afY(1:end-1)).^2)];
    abNotMoving = afVel < fVelocityThreshold;
    abNaN=isnan(strctTrack.astrctTrackers.m_afX)|isnan(strctTrack.astrctTrackers.m_afY);

    X =strctTrack.astrctTrackers.m_afX(abNotMoving& ~abNaN);
    Y =strctTrack.astrctTrackers.m_afY(abNotMoving& ~abNaN);
    
    a2fCenter=hist2(X,Y,1:1024,1:768);
   a2fCenterSmoothLog = conv2(log10(1+a2fCenter),fspecial('gaussian',[50 50],6),'same');
    

figure(4);
clf;
subplot(2,2,1);
plot(strctTrack.astrctTrackers.m_afX(aiRange5Min),strctTrack.astrctTrackers.m_afY(aiRange5Min),'k');
axis([0 1024 0 768]);
axis ij
set(gca,'xticklabel',[],'yticklabel',[]);
subplot(2,2,2);
plot(strctTrack.astrctTrackers.m_afX(aiRange30Min),strctTrack.astrctTrackers.m_afY(aiRange30Min),'k');
axis([0 1024 0 768]);
axis ij
set(gca,'xticklabel',[],'yticklabel',[]);
subplot(2,2,3);
imagesc(a2fCenterSmoothLog,[0 1.5])
axis off

drawnow
end

%%

D:\Data\Janelia Farm\ResultsFromNewTrunk\cage16_matrix.mat