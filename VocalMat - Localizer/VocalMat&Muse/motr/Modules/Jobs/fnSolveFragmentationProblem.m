function [acClusters, a2fCenters] = fnSolveFragmentationProblem(strctRegionPrios,iNumMice)
%
%Copyright (c) 2008 Shay Ohayon, California Institute of Technology. 
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

aiAreas = cat(1,strctRegionPrios.Area);
iNumCC = min(iNumMice, length(aiAreas));
% Assume iNumCC > iNumMice
a2iCenters = cat(1,strctRegionPrios.Centroid);

% Select iNumMice biggest components
[afSorted, aiSortIndex] = sort(aiAreas,'descend');

acClusters = cell(1,iNumCC);
for k=1:iNumCC
    acClusters{k} = [aiSortIndex(k)];
end;

return;