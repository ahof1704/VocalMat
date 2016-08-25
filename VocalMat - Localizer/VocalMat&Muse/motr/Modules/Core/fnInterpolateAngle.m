function afAngles = fnInterpolateAngle(fStartAngle, fEndAngle, N)
% First, make sure they are between -2*pi and 2*pi

if fStartAngle > 2*pi
    fStartAngle = fStartAngle - 2*pi;
end;
if fStartAngle < -2*pi
    fStartAngle = fStartAngle + 2*pi;
end;

if fEndAngle > 2*pi
    fEndAngle = fEndAngle - 2*pi;
end;
if fEndAngle < -2*pi
    fEndAngle = fEndAngle + 2*pi;
end;

if fStartAngle < 0
    fStartAngle = fStartAngle + 2*pi;
end;

if fEndAngle < 0
    fEndAngle = fEndAngle + 2*pi;
end;

if abs(fStartAngle-fEndAngle) > pi
    % Dirty hack. we always interpolate along the shortest angle between
    % the left and right frames. So, if we have Left = 10 and right = 350,
    % we obviously don't want to go 10..350, but 10.. -10
    % so, we check which one is larger than pi, and make it negative.
    % but after the interpolation, we make all values positive again.
    % (which is the convension).
    if fStartAngle > pi
        afAngles = linspace(fStartAngle-2*pi, fEndAngle, N);
    else
        afAngles = linspace(fStartAngle, fEndAngle-2*pi, N);
    end;
    afAngles(afAngles<0) = afAngles(afAngles<0) + 2*pi;
else
   afAngles = linspace(fStartAngle, fEndAngle, N);
end;

return;
    