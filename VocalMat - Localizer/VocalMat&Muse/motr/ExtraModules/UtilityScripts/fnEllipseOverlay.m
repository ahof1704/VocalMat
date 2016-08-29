function imo = fnEllipseOverlay(im, strctEllipse)
%
N = 200;
% Generate points on circle
afTheta = linspace(0,2*pi,N);
fTheta = strctEllipse.m_afTheta;
apt2f = [strctEllipse.m_afA * cos(afTheta); strctEllipse.m_afB * sin(afTheta)];
R = [cos(fTheta), sin(fTheta);
    -sin(fTheta), cos(fTheta)];
apt2fFinal = round(R*apt2f + repmat([strctEllipse.m_afX; strctEllipse.m_afY], 1, N));
apt2fFinal = unique(apt2fFinal','rows')';
S = sparse(apt2fFinal(2,:), apt2fFinal(1,:), 1, size(im,1), size(im,2));
S1 = 255* (S | circshift(S,[1 0]) | circshift(S,[-1 0]) | circshift(S,[0 1]) | circshift(S,[0 -1]));
imo(:,:,1) = min(im, 255-S1);
imo(:,:,2) = min(im, 255-S1);
imo(:,:,3) = max(im, S1);
return;
