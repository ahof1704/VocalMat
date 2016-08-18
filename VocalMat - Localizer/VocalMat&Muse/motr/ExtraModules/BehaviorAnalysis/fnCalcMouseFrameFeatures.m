function F=fnCalcMouseFrameFeatures(strctTracker, BCparams)
%
%
F = [];
[x, y] = fnCalcMousePOIxy(strctTracker, 1, BCparams);
N = size(x, 1);
M = length(BCparams.FramePOIs.aX);

if BCparams.Features.bCoordinates
    F = [F; x; y];
end
if BCparams.Features.bDistances
    for i=1:M
        F = [F; sqrt( (x - BCparams.FramePOIs.aX(i)).^2 + (y - BCparams.FramePOIs.aY(i)).^2 )];
    end
end

