function annFileFromMotrFiles(annFileName, ...
                              seqFileName, ...
                              motrTrackFileName)

% Convert the Motr track file (whose name often ends in '_tracks.mat') to
% a Ctrax/Jaaba-style .trx file
%trxFileName=trxFileNameFromMotrTrackFileName(motrTrackFileName);
s=load(motrTrackFileName);
astrctTrackers=s.astrctTrackers;

% Compute the background frame
%[medianFrame,medianAbsDiffFrame]=seqMedianFrameFromNonRandomSample(seqFileName);
medianFrame=seqMedianFrameFromNonRandomSample(seqFileName);

% % Take the raw median abs diff frame, and bound the values in it, to
% % prevent crazy high or crazy low values
% % We want a factor three between the min and max, centered on the median
% % value over the whole frame
% grandMedianAbsDiff=median(medianAbsDiffFrame(:));
% minMedianAbsDiff=grandMedianAbsDiff/sqrt(3);
% maxMedianAbsDiff=grandMedianAbsDiff*sqrt(3);
% scaleFrame=min(max(minMedianAbsDiff,medianAbsDiffFrame),maxMedianAbsDiff);

% convert to ann format, save
%annFileName=replaceExtension(seqFileName,'.ann');
annFileFromShayTrack(annFileName,astrctTrackers,medianFrame);
