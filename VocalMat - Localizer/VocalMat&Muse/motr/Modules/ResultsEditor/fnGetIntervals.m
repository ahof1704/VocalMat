function [astrctIntervals,aiStart,aiEnd] = fnGetIntervals(abVector)
%
%Copyright (c) 2008 Shay Ohayon, California Institute of Technology. 
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

afDiff = diff([0;abVector(:);0]);
aiStart = find(afDiff == 1);
if isempty(aiStart)
    astrctIntervals = [];
    aiEnd =[];
    return;
end;
aiEnd = find(afDiff == -1) -1;

emptySturct = struct('m_iStart',[],'m_iEnd',[],'m_iLength',[]);
astrctIntervals(1:length(aiStart)) = emptySturct;
for k=1:length(aiStart)
    astrctIntervals(k).m_iStart = aiStart(k);
    astrctIntervals(k).m_iEnd = aiEnd(k);
    astrctIntervals(k).m_iLength = aiEnd(k)-aiStart(k)+1;
end;

return;