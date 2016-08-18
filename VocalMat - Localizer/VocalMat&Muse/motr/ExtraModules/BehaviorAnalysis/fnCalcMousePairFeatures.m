function F=fnCalcMousePairFeatures(strctTracker1, strctTracker2, BCparams)
%
%
F = [];
[x1, y1] = fnCalcMousePOIxy(strctTracker1, 1, BCparams);
[x2, y2] = fnCalcMousePOIxy(strctTracker2, 2, BCparams);
N1 = size(x1, 1);
N2 = size(x2, 1);
bCdiff = isfield(BCparams.Features, 'bCdiff') && BCparams.Features.bCdiff;
if BCparams.Features.bCoordinates || bCdiff
    Xr = [];
    Yr = [];
    for i=1:N1
        xt2 = bsxfun(@minus, x2, x1(i,:));
        yt2 = bsxfun(@minus, y2, y1(i,:));
        C = cos(strctTracker1.m_afTheta);
        S = sin(strctTracker1.m_afTheta);
        xr2 = bsxfun(@times, xt2, C) + bsxfun(@times, yt2, -S);
        yr2 = bsxfun(@times, xt2, S) + bsxfun(@times, yt2, C);
        Xr = [Xr; xr2];
        Yr = [Yr; yr2];
    end
    if BCparams.Features.bCoordinates
        F = [F; Xr; Yr];
    end
    if bCdiff
        for i=1:N1*N2-1
            for j=i+1:N1*N2
                F = [F; Xr(i,:)-Xr(j,:); Yr(i,:)-Yr(j,:)];
           end
        end
    end
end
bDdiff = isfield(BCparams.Features, 'bDdiff') && BCparams.Features.bDdiff;
if BCparams.Features.bDistances || bDdiff
    Fd = [];
    for i=1:N1
        Fd = [Fd; sqrt(bsxfun(@minus, x2, x1(i,:)).^2 + bsxfun(@minus, y2, y1(i,:)).^2)];
    end
    if BCparams.Features.bDistances
        F = [F; Fd];
    end
    if bDdiff
        for i=1:N1*N2-1
            for j=i+1:N1*N2
                F = [F; Fd(i,:)-Fd(j,:)];
            end
        end
    end
end
