function [acBackground,...
          acHOGFeatures, ...
          acHOGFeaturesFlipped, ...
          acPatches, ...
          acX, ...
          acY, ...
          acA, ...
          acB, ...
          acTheta]= ...
  fnLoadSMClipTracks(acstrFileNames)

% Reads the single-mouse clip tracks from a set of files
% See fnLoadSMClipTrack.m.

iNumMice=length(acstrFileNames);
acBackground=cell(iNumMice,1);
acHOGFeatures=cell(iNumMice,1);
acHOGFeaturesFlipped=cell(iNumMice,1);
acPatches=cell(iNumMice,1);
acX=cell(iNumMice,1);
acY=cell(iNumMice,1);
acA=cell(iNumMice,1);
acB=cell(iNumMice,1);
acTheta=cell(iNumMice,1);
for i=1:iNumMice
  [acBackground{i},...
   acHOGFeatures{i}, ...
   acHOGFeaturesFlipped{i}, ...
   acPatches{i}, ...
   acX{i}, ...
   acY{i}, ...
   acA{i}, ...
   acB{i}, ...
   afTheta{i}]= ...
    fnLoadSMClipTrack(acstrFileNames{i});
end

end