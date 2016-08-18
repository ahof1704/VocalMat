function trackerAltThis=sliceTracker(tracker,k)

% Gets the trackers for a single frame (the kth frame), converting to a 
% different data format at the same time.  trackerAltThis is a 5 x nMice
% double array, with the direllipses in each column, in the order x, y, a,
% b, theta

fieldName={'m_afX' 'm_afY' 'm_afA' 'm_afB' 'm_afTheta'}';
nFieldName=length(fieldName);
nMice=length(tracker);
trackerAltThis=zeros(nFieldName,nMice);
for i=1:nFieldName
  for j=1:nMice
    trackerAltThis(i,j)=tracker(j).(fieldName{i})(k);
  end
end

end
