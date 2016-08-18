function ahHandles = fnDrawTrackers3(astrctMiceTrackers,fMul)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)
ahHandles = [];
a2iCol = [1,0,0;
          0,1,0;
          0,0,1;
          0,1,1;
          1,1,0;
          1,0,1]*fMul;
for k=1:length(astrctMiceTrackers)
    % Draw latest known position
    if ~isnan(astrctMiceTrackers(k).m_fX)
        h = fnPlotEllipse(astrctMiceTrackers(k).m_fX,...
        astrctMiceTrackers(k).m_fY,...
        astrctMiceTrackers(k).m_fA,...
        astrctMiceTrackers(k).m_fB,...
        astrctMiceTrackers(k).m_fTheta, a2iCol(k,:),2);
       ahHandles = [ahHandles;h];
    end;
 end;

return;
