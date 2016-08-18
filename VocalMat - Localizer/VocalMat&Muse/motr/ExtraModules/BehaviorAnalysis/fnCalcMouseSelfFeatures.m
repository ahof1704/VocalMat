function F=fnCalcMouseSelfFeatures(strctTracker, iMouseRank, BCparams)
%
%
F = [];
[x1, y1] = fnCalcMousePOIxy(strctTracker, iMouseRank, BCparams);
N = size(x1, 1);

t = max(1, BCparams.Features.iSelfTimeScale);

x2 = circshift(x1, [0 t]);
y2 = circshift(y1, [0 t]);

bThrLike = isfield(BCparams.Features, 'bThresholdLike') && BCparams.Features.bThresholdLike;
if BCparams.Features.bDistances || bThrLike
    Fd = [];
    Fd = [Fd; sqrt((x2 - x1).^2 + (y2 - y1).^2)];
    if BCparams.Features.bDistances
        F = [F; Fd];
    end
    if bThrLike
        F = [F; max(Fd, [], 1)];
    end
end
if BCparams.Features.bCoordinates && BCparams.Features.iSelfTimeScale>0 
    xt2 = x2 - x1;
    yt2 = y2 - y1;
    C = cos(strctTracker.m_afTheta);
    S = sin(strctTracker.m_afTheta);
    xr2 = bsxfun(@times, xt2, C) + bsxfun(@times, yt2, -S);
    yr2 = bsxfun(@times, xt2, S) + bsxfun(@times, yt2, C);
    F = [F; xr2; yr2];
end

