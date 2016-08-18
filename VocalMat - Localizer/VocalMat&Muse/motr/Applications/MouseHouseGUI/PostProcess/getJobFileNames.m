function jobFN = getJobFileNames(resultsDirName, clipFN, nJobs)
% Generates a cell array of the file names of the job output files for
% the jobs associated with the clip named in clipFN, assuming there are
% nJobs such jobs.

if isempty(nJobs)
   nJobs=0;
end
%strctMovieInfo = fnReadVideoInfo(clipFN);
[dummy, clipBaseName] = fileparts(clipFN);
% D = dir(fullfile(resultsDirName, clipBaseName, 'JobOut*.mat'));
jobFN=cell(nJobs,1);
for iJob=1:nJobs
  % jobFN{iJob} = fullfile(resultsDirName, clipBaseName, D(iJob).name);
  jobFN{iJob} = fullfile(resultsDirName, ...
                         clipBaseName, ...
                         ['JobOut' num2str(iJob) '.mat']);
end

