function a2bMask=fnHeuristicMaskFromBackground(a2fBackground)

% Automatically identify floor and crop reflections on walls.

fFloorIntensity = median(a2fBackground(:));
a2bFloor = imclose(a2fBackground >=fFloorIntensity,ones(5,5));
% pick largest CC
a2iL=bwlabel(a2bFloor);
aiHist=fnLabelsHist(uint16(a2iL));
[fDummy,iFloorCC]=max(aiHist(2:end));  %#ok
a2bFloor = a2iL == iFloorCC;
[aiY,aiX]=find(a2bFloor);
aiInd=convhull(aiX,aiY);
a2bMask=roipoly(a2bFloor,aiX(aiInd),aiY(aiInd));

end
