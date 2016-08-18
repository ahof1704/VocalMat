function astrctTrackersAtFrame = fnGetTrackersAtFrame(astrctTrackers, iFrame)
iNumMice = length(astrctTrackers);
if iNumMice == 0
    astrctTrackersAtFrame  = [];
    return
end
for iMiceIter=1:iNumMice
    astrctTrackersAtFrame(iMiceIter) = fnGetTrackerAtFrame(astrctTrackers, iMiceIter,iFrame);
end;
return;
