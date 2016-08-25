function [bAns, aiMissing] = fnHaveAllJobsFinished(acstrJobFiles, aiClips)
%
bAns = false;
iNumClips = length(acstrJobFiles);
aiMissing = [];
% SO Added this (13 Oct 2011)
if isempty(acstrJobFiles)
    return;
end;

if nargin < 2
   aiClips = 1:iNumClips;
end
for iClip=aiClips
   iNumJobs = length(acstrJobFiles{iClip});
   for iJob=1:iNumJobs
      if ~exist(acstrJobFiles{iClip}{iJob}, 'file')
         if nargout < 2
            return;
         else
            aiMissing = [aiMissing iJob];
         end
      end
   end
end
bAns = isempty(aiMissing);




