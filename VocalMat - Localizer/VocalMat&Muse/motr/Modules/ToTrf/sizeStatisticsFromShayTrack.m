function [meanQuarterMajorAxisLength,maxQuarterMajorAxisLength]= ...
  sizeStatisticsFromShayTrack(astrctTrackers)

nMice=length(astrctTrackers);
if nMice==0
  maxQuarterMajorAxisLength=nan;
  meanQuarterMajorAxisLength=nan;    
else
  sumOverMice=0;
  nMiceInSum=0;
  maxQuarterMajorAxisLength=-inf;
  for j=1:nMice
    quarterMajorAxisLengthThisMouse=astrctTrackers(j).m_afA/2;
    meanQuarterMajorAxisLengthThisMouse=nanmean(quarterMajorAxisLengthThisMouse);
    if ~isnan(meanQuarterMajorAxisLengthThisMouse)
      sumOverMice=sumOverMice+meanQuarterMajorAxisLengthThisMouse;
      nMiceInSum=nMiceInSum+1;
    end
    maxQuarterMajorAxisLength= ...
      max(maxQuarterMajorAxisLength,max(quarterMajorAxisLengthThisMouse));
  end  
  meanQuarterMajorAxisLength=sumOverMice/nMiceInSum;
end

end
