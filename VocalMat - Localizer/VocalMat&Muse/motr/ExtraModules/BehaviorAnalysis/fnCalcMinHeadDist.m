function [minHeadDist, d, ind]=fnCalcMinHeadDist(strctHeadPos)
%
iNumMice = length(strctHeadPos);
iNumFrames = length(strctHeadPos(1).x);
d = zeros(iNumMice, iNumFrames);
i = 1;
ind = zeros(iNumMice);
for j=1:iNumMice-1
    for k=j+1:iNumMice
        ind(j,k) = i;
        ind(k,j) = i;
        d(i,:) = sqrt((strctHeadPos(j).x-strctHeadPos(k).x).^2 + ...
                                  (strctHeadPos(j).y-strctHeadPos(k).y).^2);
        i = i+1;
    end
end
minHeadDist = min(d);
