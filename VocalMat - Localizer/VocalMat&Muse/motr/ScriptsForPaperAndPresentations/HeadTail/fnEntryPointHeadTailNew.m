save('HeadTailData','g_astrctTrackersJob','strctAdditionalInfo','bFlipDir')
astrctTrackersJob = fnJobCorrectOrientationWithViterbi(...
    g_astrctTrackersJob,strctAdditionalInfo,bFlipDir);

save('HeadTailData2','afTheta', 'afAlpha', 'afVel', 'afProbHead');
save('HeadTailData3','a2LogfTransitionMatrix','a2LogfLikelihood','aiPath');

figure(5);
clf;
imagesc(a2LogfLikelihood,[-50 0])
colormap jet
colorbar

imagesc(a2LogfTransitionMatrix)
