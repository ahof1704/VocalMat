function saveTrackFile(fileName,trackers,clipFNAbs)

astrctTrackers=trackers;
strMovieFileName=clipFNAbs;
save(fileName, 'astrctTrackers', 'strMovieFileName');

end
