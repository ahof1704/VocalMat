function aPairInds=getPairInds(BCparams, iMouseInd, iNumMice)
% if ~(BCparams.Features.bCoordinates || BCparams.Features.bDistances || BCparams.Features.bMousePair);
if ~BCparams.Features.bMousePair;
    aPairInds = iMouseInd;
else
    aPairInds = (iNumMice-1)*(iMouseInd-1)+1:(iNumMice-1)*iMouseInd;
end
