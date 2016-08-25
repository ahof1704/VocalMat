function motrTrackFileFromTrxFile(motrTrackFileName,trxFileName,movieFileName)

% Convert a Ctrax/Jaaba-style trx file to a Motr-style 
% astrctTrackers structure array

s=load(trxFileName);
trx=s.trx;
clear s;
astrctTrackers=shayTrackFromTrx(trx);  %#ok
strMovieFileName=movieFileName;  %#ok
save(motrTrackFileName,'astrctTrackers','strMovieFileName');

end
