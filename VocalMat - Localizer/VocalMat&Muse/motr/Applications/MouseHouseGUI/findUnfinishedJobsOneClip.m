function iMissing = findUnfinishedJobsOneClip(jobFN)

nJobs = length(jobFN);
iMissing = zeros(0,1);
for i=1:nJobs
  if ~exist(jobFN{i}, 'file')
    iMissing = [iMissing;i];
  end
end
