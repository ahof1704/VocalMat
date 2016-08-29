function fDist = fnAngleDist(Angle1,Angle2, Range)
% Computes the distance between two angles.
if Range == 360
    fDist = acos(dot([cos(Angle1),sin(Angle1)],[cos(Angle2),sin(Angle2)]));
else
    fDist = acos(dot([cos(Angle1),sin(Angle1)],[cos(Angle2),sin(Angle2)]));
    fDist = min(fDist, abs(pi-fDist));
end;



