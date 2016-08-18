function fnRunJobsAsNeeded(acstrJobOutputFileNames, ...
                           acstrJobInputFileNames, ...
                           bRunLocal, ...
                           strAppRootFolderName)
                 
% Runs all the jobs for which the job output file doesn't exist.  
% acstrJobOutputFileNames is a list of the (absolute) output file names.
% acstrJobInputFileNames is a list of the (absolute) input file names.
% bRunLocal determines whether jobs are run locally or on the cluster.
% strAppRootFolderName is the root of the Repository/MouseHouse code, and 
% the executable should be at the proper location within this folder.  This
% last argument can be omitted if bRunLocal is true;

% Deal with arguments
if nargin<4
  % This will only work if bRunLocal is true
  strAppRootFolderName='';
end

% The main loop, one iter per job.
iNumJobs=length(acstrJobOutputFileNames);
for i=1:iNumJobs
  strJobOutFileName=acstrJobOutputFileNames{i};
  if ~exist(strJobOutFileName,'file')
    strJobInputFileName=acstrJobInputFileNames{i};
    if bRunLocal
      fnSubmitJobLocal(strJobInputFileName);
    else
      fnSubmitJobToCluster(strJobInputFileName, ...
                           strAppRootFolderName);
      pause(0.1);  % hopefully will prevent stillborn jobs                   
    end
  end
end

end
