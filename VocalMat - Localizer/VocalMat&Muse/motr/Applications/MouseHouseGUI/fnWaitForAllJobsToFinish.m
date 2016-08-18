function fnWaitForAllJobsToFinish(acstrJobFiles)
%
iNumJobs = length(acstrJobFiles);
for iJob=1:iNumJobs
   while ~exist(acstrJobFiles{iJob}, 'file')
      %pause(60);
      pause(10);  % Hope this is OK.  --ALT, 2012-02-21
   end
end

