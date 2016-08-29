function status=determineTrackStatus(expDirName,clipFNAbs)
% Figures out what the tracking status of the given clip is, by looking for
% files in the right places.  expDirName should be an absolute path, clipFN
% should contain relative paths.
%
% The code:
%   1: not started
%   2: files chosen
%   3: in process
%   4: done

% Check for the final results file
[dummy,baseName]=fileparts(clipFNAbs);  % the seq file name, w/o .seq
finalTrackingFN=fullfile(expDirName,'Results','Tracks',[baseName '_tracks.mat']);
if exist(finalTrackingFN,'file')
    status=4;
    return
end

% Check for an old-style results file, rename it if present
finalTrackingFNOldSchool=fullfile(expDirName,'Results','Tracks',[baseName '.mat']);
if exist(finalTrackingFNOldSchool,'file')
  success=copyfile(finalTrackingFNOldSchool,finalTrackingFN);
  if success ,
    delete(finalTrackingFNOldSchool);
    status=4;
    return
  else
    % If can't copy, just continue on as if the old-school file doesn't
    % exist.  Hopefully we can just re-run Viterbi using the existing job
    % files, and all will be good.
  end
end

% Check for the per-job Jobargin files
dirName=fullfile(expDirName,'Jobs',baseName);
filter='Jobargin*.mat';
pattern=fullfile(dirName,filter);
d=dir(pattern);
nJobarginFile=length(d);
if nJobarginFile>0
    status=3;
    return;
end

% I think the above is actually a better test for "in process"
% % Check for per-chunk .mat files
% dirName=fullfile(expDirName,'Results',baseName);
% filter='*.mat';
% pattern=fullfile(dirName,filter);
% d=dir(pattern);
% nResultFile=length(d);
% if nResultFile>0
%     status=3;
%     return;
% end

% the worst things can be is 2, since the file name is in clipFN
status=2;

end
