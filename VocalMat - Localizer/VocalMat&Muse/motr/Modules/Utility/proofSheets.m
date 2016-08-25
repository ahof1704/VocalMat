function h=proofSheets(expDirName)

% Makes proof sheets for an entire experiment.  Returns a vector of handles
% for the figures.

fileName=fullfile(expDirName,'clipFN.mat');
clipFN=loadClipFN(fileName);

% for each clip, generate a proof sheet
nClip=length(clipFN);
h=zeros(nClip,1);
for i=1:nClip
  resultsDirName = fullfile(expDirName, 'Results');
  tracksDirName = fullfile(resultsDirName, 'Tracks');
  clipFNThis=clipFN{i};
  [dummy, clipBaseName] = fileparts(clipFNThis);
  trackFN = fullfile(tracksDirName, [clipBaseName '.mat']);
  h(i)=proofSheet(trackFN,i);
end

end
