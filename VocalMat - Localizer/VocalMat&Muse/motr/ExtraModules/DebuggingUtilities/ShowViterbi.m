fIdentitySwapJumpPix = 0;
% [aiPath, a2fV, a3fD] = fnViterbiOnTheSide('C:\MouseTrack\Data\Mice_G\Results\b6_pop_cage_14_12.02.10_09.52.04.882\SequenceRAW', fIdentitySwapJumpPix, 'Likelihood882');
% [aiPath, a2fV, a3fD] = fnViterbiOnTheSide('C:\MouseTrack\Data\JobOut203.mat', fIdentitySwapJumpPix);
[aiPath, a2fV, a3fD] = fnViterbiOnTheSide('C:\MouseTrack\Data\Results\b6_pop_cage_14_12.02.10_09.52.04.882\JobOut1.mat', fIdentitySwapJumpPix);

%%
figure(1);
% i = 940750:940850;
% i = 1002178:1003489;
% i = 1001:2500;
i = 1:50;
% load Likelihood882;
load likelihood1001001;
ax(1) = subplot(6,1,1), imagesc(a2fLikelihood(:,i));
ax(2) = subplot(6,1,2), plot([aiPath(i)']);
% ax(2) = subplot(6,1,2), plot([aiPath(i)' aiPath7(i)' aiPath5(i)']);
for j=1:4
   ax(j+2) = subplot(6,1,j+2), plot(a2fV(j,i)/fIdentitySwapJumpPix,':');
   hold on
   plot(squeeze(a3fD(j,:,i)/70)','-');
end
hold off
linkaxes(ax, 'x');