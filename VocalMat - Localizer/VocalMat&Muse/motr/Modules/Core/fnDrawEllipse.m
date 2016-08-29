function [hHandle, ahControls] = fnDrawEllipse(hAxes,fX,fY,fA,fB,fTheta, afCol, iLineWidth, bDrawShapeControl)
% Based on Perona's code...
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology. 
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

ahControls = [];

N = 60; 
hHandle = [];

%if (det(a2fCov)<0) || sum(isnan(a2fCov(:)))>0
%    return;
%end;
fTheta = fTheta + pi/2;
% Generate points on circle
afTheta = linspace(0,2*pi,N);%2*pi*[0:N]/N;
apt2f = [fA * cos(afTheta); fB * sin(afTheta)];
R = [ cos(fTheta), sin(fTheta);
    -sin(fTheta), cos(fTheta)];
apt2fFinal = R*apt2f + repmat([fX;fY],1,N);
 hHandle = plot(hAxes,apt2fFinal(1,:), apt2fFinal(2,:),'Color', afCol, 'LineWidth', iLineWidth); 

if bDrawShapeControl
    afDiscX = 8*cos(afTheta); 
    afDiscY = 8*sin(afTheta); 
    ahControls(1,1) = patch(afDiscX+fX,afDiscY+fY,afCol,'Parent',hAxes,'EdgeColor','none','UserData','Center');
    a2fPt = R * [fA,0,-fA,0;0,fB,0,-fB];
    afDiscX = 8*cos(afTheta);
    afDiscY = 8*sin(afTheta);

    for q=1:size(a2fPt,2)
        ahControls(q+1,1) = patch(fX+afDiscX+a2fPt(1,q),...
            fY+afDiscY+a2fPt(2,q),0.6*afCol,'Parent',hAxes,'EdgeColor','none','UserData','Major');
    end;
end;