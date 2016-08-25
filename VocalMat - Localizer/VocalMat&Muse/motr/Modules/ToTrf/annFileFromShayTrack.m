function annFileFromShayTrack(annFileName,astrctTrackers,backgroundFrame)

% Creates a Ctrax-style .ann file from a Motr track structure.
% The index of each track in the .ann file is the same as the mouse index
% in the astrctTrackers structure.

%astrctTrackers(k).m_afX(iFirst:iLast);

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

ang_dist_wt=65/(pi/2);  % mm/radian, used to convert angle errors to distances,
                        % for computing an "overall" distance between mice
                        % ellipses

fid=fopen(annFileName,'w');
fprintf(fid,'Ctrax header\n');
fprintf(fid,'maxmajor:%f\n',maxQuarterMajorAxisLength);
fprintf(fid,'meanmajor:%f\n',meanQuarterMajorAxisLength);
fprintf(fid,'max_jump:%f\n',50);  % I think this is interpreted as being in pels
  % if the error relative to the predicted position is larger than
  % max_jump, Ctrax starts a new trajectory
fprintf(fid,'center_dampen:%f\n',0);
fprintf(fid,'angle_dampen:%f\n',0.5);
fprintf(fid,'ang_dist_wt:%f\n',ang_dist_wt);
fprintf(fid,'bg_algorithm:%s\n','median');
backgroundFrame=double(backgroundFrame);
fprintf(fid,'background median:%d\n',8*numel(backgroundFrame));
fwrite(fid,backgroundFrame','double');  % want in row-major order, apparently
fprintf(fid,'end header\n');

if nMice>0
  nFrames=length(astrctTrackers(1).m_afX);
  for i=1:nFrames
    for j=1:nMice
      fprintf(fid, ...
              '%f\t%f\t%f\t%f\t%f\t%d\t', ...
              astrctTrackers(j).m_afX(i), ...
              astrctTrackers(j).m_afY(i), ...
              astrctTrackers(j).m_afA(i)/2, ...
              astrctTrackers(j).m_afB(i)/2, ...
              -astrctTrackers(j).m_afTheta(i), ...
              j);
    end
    fprintf(fid,'\n');
  end
end

fclose(fid);

end
