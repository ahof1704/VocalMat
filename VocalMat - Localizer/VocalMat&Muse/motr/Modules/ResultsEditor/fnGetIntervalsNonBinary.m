function astrctIntervals = fnGetIntervalsNonBinary(abVector)
%
%Copyright (c) 2008 Shay Ohayon, California Institute of Technology. 
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

astrctIntervals = [];
iInRun = 0;
iStartRun = 1;
iCounter = 1;

for i = 1:length(abVector)
    if i == 1     
        PrevValue = 0;
    else
        PrevValue = abVector(i-1);
    end;
    
    if abVector(i) ~= PrevValue && abVector(i) ~= 0
        if ~iInRun
            iStartRun = i;
            iInRun = 1;
        end
    else
        if iInRun
            iInRun = 0;
            astrctIntervals(iCounter).m_iStart = iStartRun;
            astrctIntervals(iCounter).m_iEnd = i-1;
            astrctIntervals(iCounter).m_iLength = astrctIntervals(iCounter).m_iEnd-astrctIntervals(iCounter).m_iStart+1;
            iCounter = iCounter+1;
        end
    end
end
if iInRun
    astrctIntervals(iCounter).m_iStart = iStartRun;
    astrctIntervals(iCounter).m_iEnd = i;
    astrctIntervals(iCounter).m_iLength = astrctIntervals(iCounter).m_iEnd-astrctIntervals(iCounter).m_iStart+1;
end