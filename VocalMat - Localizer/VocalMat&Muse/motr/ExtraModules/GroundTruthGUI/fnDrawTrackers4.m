function ahHandles = fnDrawTrackers4(astrctMiceTrackers, iFrame, hAxes)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)
ahHandles = [];
aiCol = ['r','g','b','c','y','m'];
for k=1:length(astrctMiceTrackers)
    % Draw latest known position
    if ~isnan(astrctMiceTrackers(k).m_afX(iFrame))
        h = fnPlotEllipse2(astrctMiceTrackers(k).m_afX(iFrame),...
        astrctMiceTrackers(k).m_afY(iFrame),...
        astrctMiceTrackers(k).m_afA(iFrame),...
        astrctMiceTrackers(k).m_afB(iFrame),...
        astrctMiceTrackers(k).m_afTheta(iFrame), aiCol(k),1, hAxes);
       ahHandles = [ahHandles;h];
    end;
 end;

return;
