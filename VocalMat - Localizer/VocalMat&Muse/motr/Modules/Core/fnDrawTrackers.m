function ahHandles = fnDrawTrackers(astrctMiceTrackers, lineWidth,aiCol)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or
% modify it under the terms of the GNU General Public License as published
% by the Free Software Foundation (see GPL.txt)
if nargin<2
   lineWidth = 2;
end
ahHandles = [];
if ~exist('aiCol','var')
    aiCol = ['r','g','b','c','y','m'];
end
for k=1:length(astrctMiceTrackers)
    % Draw latest known position
    if ~isnan(astrctMiceTrackers(k).m_fX)
        h = fnPlotEllipse(astrctMiceTrackers(k).m_fX,...
                          astrctMiceTrackers(k).m_fY,...
                          astrctMiceTrackers(k).m_fA,...
                          astrctMiceTrackers(k).m_fB,...
                          astrctMiceTrackers(k).m_fTheta, ...
                          aiCol(k), ...
                          lineWidth);
       ahHandles = [ahHandles;h];
    end;
 end;

return;
