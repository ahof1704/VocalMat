function [iNum, a2i, a2iInd]=getSetIndices(bSingle, iNumMice)
%
if bSingle
    iNum = iNumMice;
    a2iInd = (1:4)';
    a2i = [a2iInd zeros(iNum, 1)];
else
    iNum = iNumMice*(iNumMice-1);
    a2i = zeros(iNum, 2);
    a2iInd = zeros(iNumMice);
    k = 1; for i=1:iNumMice, for j=1:iNumMice, if i~=j, a2i(k,:) = [i, j]; a2iInd(i, j) = k; k = k + 1; end, end, end
end

