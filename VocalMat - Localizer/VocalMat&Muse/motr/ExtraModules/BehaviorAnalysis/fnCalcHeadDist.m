function [d, pairInd,miceInd]=fnCalcHeadDist(strctHeadPos)
%
iNumMice = length(strctHeadPos);
iNumFrames = length(strctHeadPos(1).x);
d = zeros(iNumMice, iNumFrames);
i = 1;
pairInd = zeros(iNumMice);
miceInd = [];
for j=1:iNumMice-1
    for k=j+1:iNumMice
        pairInd(j,k) = i;
        pairInd(k,j) = i;
        miceInd = [miceInd; [j, k]];
        d(i,:) = sqrt((strctHeadPos(j).x-strctHeadPos(k).x).^2 + ...
                                  (strctHeadPos(j).y-strctHeadPos(k).y).^2);
        i = i+1;
    end
end

