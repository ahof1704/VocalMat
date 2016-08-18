function [trackers,clipFNAbs]=loadTrackFile(fileName)

load(fileName, 'astrctTrackers', 'strMovieFileName');
  % introduces astrctTrackers and strMovieFileName into namespace
trackers=astrctTrackers;
clipFNAbs=strMovieFileName;

end
