strctResult = load('D:\Data\Janelia Farm\ResultsFromNewTrunk\cage17\b6_popcage_17_05.30.11_10.00.07.777.mat');

strctMovInfo = fnReadVideoInfo('F:\popcage_17\b6_popcage_17_05.30.11_10.00.07.777.seq');


t0 = 1279883;
aiFramesToPlot = [t0-400,t0,t0+300];
    figure;
    clf;

for k=1:length(aiFramesToPlot)
    iFrame = aiFramesToPlot(k)
    I=fnReadFrameFromSeq(strctMovInfo,iFrame);
    tightsubplot(1,3,k);
    imshow(I,[]);
    hold on;
    fnDrawTrackers4(strctResult.astrctTrackers, iFrame,gca);
    drawnow
end
%%

strctResult = load('D:\Data\Janelia Farm\ResultsFromNewTrunk\cage17\b6_popcage_17_06.01.11_22.00.13.330.mat');

strctMovInfo = fnReadVideoInfo('F:\popcage_17\b6_popcage_17_06.01.11_22.00.13.330.seq');


t0 = 24409;
 t0+8100:10:t0+8500
    figure;
    clf;

for k=1:length(aiFramesToPlot)
    cla;
    iFrame = aiFramesToPlot(k);
    I=fnReadFrameFromSeq(strctMovInfo,iFrame);
    imshow(I,[]);
    hold on;
    fnDrawTrackers4(strctResult.astrctTrackers, iFrame,gca);
    drawnow
end



t0 = 24409;
aiFramesToPlot = [t0-200,t0,t0+8180]
figure(12);
    clf;

for k=1:length(aiFramesToPlot)
    iFrame = aiFramesToPlot(k)
    I=fnReadFrameFromSeq(strctMovInfo,iFrame);
    tightsubplot(1,3,k);
    imshow(I,[]);
    hold on;
    fnDrawTrackers4(strctResult.astrctTrackers, iFrame,gca);
    drawnow
end
