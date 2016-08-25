%% Examples with spike time (non-binary) data 
% Drawn from an inhomogeneous Poisson process with rate lambda
avgRate = 100; % spikes/s
amplitude = 75;
period = 0.1; % seconds
lambdaFcn = @(x) avgRate+amplitude*cos(2*pi*x/period);
maxRate = avgRate+amplitude;

trialLength = 0.201; % seconds
nTrials = 50;
spikeTimes = cell(nTrials,1);
spikesPerTrial = poissrnd(maxRate*trialLength,nTrials,1);
for trial = 1:nTrials
     possibleSpikeTimes = trialLength*rand(1,spikesPerTrial(trial));
     nSpikes = length(possibleSpikeTimes);
     acceptRatio = rand(1,nSpikes);
     rateRatio = lambdaFcn(possibleSpikeTimes)./maxRate;
     spikesToKeep = acceptRatio < rateRatio;
     spikeTimes{trial} = possibleSpikeTimes(spikesToKeep);
end

% Plot
LineFormat.Color = 'b';
figure; subplot(3,1,1);
plotSpikeRaster(spikeTimes,'PlotType','scatter','XLimForCell',[0 0.201]);
title('Dots (Scatterplot)');
set(gca,'XTick',[]);

subplot(3,1,2); 
plotSpikeRaster(spikeTimes,'PlotType','vertline','RelSpikeStartTime',0.01,'XLimForCell',[0 0.201]);
ylabel('Trial')
title('Vertical Lines With Spike Offset of 10ms (Not Typical; for Demo Purposes)');
set(gca,'XTick',[]);

subplot(3,1,3); 
plotSpikeRaster(spikeTimes,'SpikeDuration',0.003,'LineFormat',LineFormat,'XLimForCell',[0 0.201]);
xlabel('Time (s)');
title('Blue Horizontal Lines With Long Spike Duration of 3ms');
suptitle('Raster Plot Examples');


%% Single spike train and Imagesc example:
figure; subplot(2,1,1)
plotSpikeRaster(spikeTimes(13),'PlotType','vertline');
title('Single Spike Train Example')
xlabel('Time (s)');

% Simulate binary spike data with an unrealistic rate (500 spk/s)
timeBinSize = 0.001; % 1 ms
binarySpikes = logical( randi([0 1], nTrials, floor(trialLength/timeBinSize)) );
subplot(2,1,2); plotSpikeRaster(binarySpikes,'PlotType','imagesc');
title('Imagesc Example (Unrealistic Firing Rate)');

%% Validation and Parameter Demonstration with Binary Spikes
binarySpikes2 =   [ 1 1 1 1 1 0 0 0 0 0 0 1 1 1 1;
                    1 1 1 0 0 0 0 0 1 1 0 0 0 1 1;
                    1 1 0 0 0 0 0 0 1 1 0 0 0 0 1;
                    1 1 0 0 0 0 0 0 0 0 0 0 0 0 1;
                    1 0 0 0 0 0 0 0 0 0 0 0 1 1 1;
                    1 0 0 0 0 0 0 0 0 1 1 1 1 1 1;
                    1 0 0 0 0 0 0 1 1 1 1 1 1 1 1;
                    1 0 0 0 0 0 0 0 0 1 1 1 1 1 1;
                    1 0 0 0 0 0 0 0 0 0 0 0 1 1 1;
                    1 1 0 0 0 0 0 0 0 0 0 0 0 0 1;
                    1 1 0 0 0 0 0 0 0 0 0 0 0 0 1;
                    1 1 1 0 0 0 0 0 0 0 0 0 0 1 1;
                    1 1 1 1 1 0 0 0 0 0 0 1 1 1 1 ];
                
binarySpikes2 = logical(binarySpikes2);
LineFormatHorz.LineWidth = 5;
LineFormatHorz.Color = 'b';
LineFormatVert.LineWidth = 5;
MarkerFormat.MarkerSize = 12;
MarkerFormat.Marker = '*';
        
figure; subplot(2,2,1);
plotSpikeRaster(binarySpikes2,'PlotType','vertline','LineFormat',LineFormatVert,'VertSpikePosition', -0.5);
title('Vertical Lines Y-Center on ''Trial# - 0.5''');
set(gca,'XTick',[]);
ylabel('Trial');

subplot(2,2,2); 
plotSpikeRaster(binarySpikes2,'PlotType','scatter','MarkerFormat',MarkerFormat);
title('Large Asterisks (Scatterplot)');
set(gca,'XTick',[]);
set(gca,'YTick',[]);

subplot(2,2,3); 
plotSpikeRaster(binarySpikes2,'LineFormat',LineFormatHorz,'SpikeDuration',0.0008);
title('Blue Horizontal Lines With 0.8ms Spike Duration');
xlabel('Time (ms)');
ylabel('Trial');

subplot(2,2,4); 
plotSpikeRaster(binarySpikes2,'PlotType','imagesc');
xlabel('Time (ms)');
title('Imagesc');
suptitle('Raster Plot Examples From Binary Spike Trains');
set(gca,'YTick',[]);

%% Everything below here is extra.
%% Validation for Spike Timing Plots
spikeTimes2 = cell(5,1);
spikeTimes2{1} = [4.5 4.75 5]./1000;
spikeTimes2{2} = [4 4.5 4.25]./1000;
spikeTimes2{3} = [3]./1000;
spikeTimes2{4} = [2]./1000;
spikeTimes2{5} = [1]./1000;
figure; subplot(2,2,1);
plotSpikeRaster(spikeTimes2,'LineFormat',LineFormatHorz);
ylabel('Trial')
title('Horizontal Lines');

subplot(2,2,2); 
plotSpikeRaster(spikeTimes2,'PlotType','vertline','LineFormat',LineFormatHorz);
title('Vertical Lines');

subplot(2,2,3); 
plotSpikeRaster(spikeTimes2,'PlotType','scatter','MarkerFormat',MarkerFormat);
xlabel('Time (ms)');
ylabel('Trial')
title('Dots (Scatterplot)');

suptitle('Raster Plot Examples');

%% Vertline vs Vertline2 - many trials, completely filled with spikes
nTrials = 10000;
nTimeBins = 10;
binarySpikes3 = true(nTrials,nTimeBins);
disp('ABBA: Vertline Vertline2 Vertline2 Vertline');
tic
figure;
plotSpikeRaster(binarySpikes3,'PlotType','vertline');
toc
close all;
tic
figure;
plotSpikeRaster(binarySpikes3,'PlotType','vertline2');
toc
close all;
tic
figure;
plotSpikeRaster(binarySpikes3,'PlotType','vertline2');
toc
close all;
tic
figure;
plotSpikeRaster(binarySpikes3,'PlotType','vertline');
toc
close all;
%% Horzline vs Horzline2 - many timebins, completely filled with spikes
nTrials = 10;
nTimeBins = 10000;
binarySpikes4 = true(nTrials,nTimeBins);
disp('ABBA: Horzline Horzline2 Horzline2 Horzline');
tic
figure;
plotSpikeRaster(binarySpikes4,'PlotType','horzline');
toc
close all;
tic
figure;
plotSpikeRaster(binarySpikes4,'PlotType','horzline2');
toc
close all;
tic
figure;
plotSpikeRaster(binarySpikes4,'PlotType','horzline2');
toc
close all;
tic
figure;
plotSpikeRaster(binarySpikes4,'PlotType','horzline');
toc
close all;
