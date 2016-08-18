function [timeLine,samples] = f(filename)

signalFID = fopen(filename,'r');
tMin = fscanf(signalFID,'%f',1);
tMax = fscanf(signalFID,'%f',1);
numberOfTimeSamples = fscanf(signalFID,'%d',1);
vectorDim = fscanf(signalFID,'%d',1);
firstSample = fscanf(signalFID,'%f',[vectorDim 1]);
restOfSamples = fscanf(signalFID,'%f',[vectorDim+1 inf]);
fclose(signalFID);

% Create samples
restOfSamples=restOfSamples(2:vectorDim+1,:);  % Trim dimensions off
samples=[firstSample restOfSamples];
% Create timeLine
timeLine=linspace(tMin,tMax,numberOfTimeSamples);

