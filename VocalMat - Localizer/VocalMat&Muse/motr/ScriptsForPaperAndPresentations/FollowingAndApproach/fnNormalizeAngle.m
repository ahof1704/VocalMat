function afAngle = fnNormalizeAngle(afAngle, center)
if ~exist('center','var')
    center = pi;
end

afAngle = mod(afAngle-center+pi, 2*pi) + center-pi;
return;
