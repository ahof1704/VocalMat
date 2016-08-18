function fnPostTracking(clipFNAbs, expDirName, iClip, aiNumJobs)

fprintf('In fnPostTracking\n');
tuningDirName = fullfile(expDirName, 'Tuning');
jobsDirName = fullfile(expDirName, 'Jobs');
resultsDirName = fullfile(expDirName, 'Results');
tracksDirName = fullfile(resultsDirName, 'Tracks');
fprintf('Dirs = \n  %s\n  %s\n  %s\n  %s\n', ...
        tuningDirName, ...
        jobsDirName, ...
        resultsDirName, ...
        tracksDirName);
if ~exist(tracksDirName,'dir')
  mkdir(tracksDirName);
end
%startupDirName = [pwd() filesep];
%sDetectionFile = fullfile(tuningDirName, 'Detection.mat');
classifiersFN = fullfile(tuningDirName, 'Identities.mat');
clipFNAbsThis=clipFNAbs{iClip};
jobFN = getJobFileNames(resultsDirName, clipFNAbsThis, aiNumJobs);
%strMovieFileName = clipFN(iClip).sName;
fprintf('Reading video info from %s', clipFNAbsThis);
%clipFNThisAbs=fullfile(expDirName,clipFNThis);
clipThisInfo = fnReadVideoInfo(clipFNAbsThis);
[dummy, sClipName] = fileparts(clipFNAbsThis); %#ok
trackers = fnMergeJobs(clipThisInfo, jobFN, []);
rawTrackFN = fullfile(resultsDirName, sClipName, 'SequenceRAW');
%save(rawTrackFN, 'astrctTrackers', 'strMovieFileName');
saveTrackFile(rawTrackFN,trackers,clipFNAbsThis);
%astrctTrackers = fnHouseIdentities(astrctTrackers, clipThisInfo, ...
%                                   classifiersFN);
trackers=fnHouseIdentities(trackers, clipThisInfo, classifiersFN);
trackFN = fullfile(tracksDirName, [sClipName '_tracks.mat']);
%save(trackFN, 'astrctTrackers', 'strMovieFileName');
saveTrackFile(trackFN,trackers,clipFNAbsThis);
fprintf('Done. Saved track file %s\n', trackFN);
% fnUpdateStatus(handles, 2, 4);

end
