function [hHandle, ahControls] = fnDrawTrackerNoTail(hAxes,strctTracker, afCol, iLineWidth, bDrawShapeControl)
% Based on Perona's code...
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology. 
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

ahControls = [];

N = 60; 
hHandle = [];
afTheta = linspace(0,2*pi,N);%2*pi*[0:N]/N;
apt2f = [strctTracker.m_fA * cos(afTheta); strctTracker.m_fB * sin(afTheta)];
R = [ cos(strctTracker.m_fTheta), sin(strctTracker.m_fTheta);
    -sin(strctTracker.m_fTheta), cos(strctTracker.m_fTheta)];
apt2fFinal = R*apt2f + repmat([strctTracker.m_fX;strctTracker.m_fY],1,N);
 hHandle = plot(hAxes,apt2fFinal(1,:), apt2fFinal(2,:),'Color', afCol, 'LineWidth', iLineWidth); 
                
 if bDrawShapeControl

    afDiscX = 8*cos(afTheta); 
    afDiscY = 8*sin(afTheta); 
    ahControls(1,1) = patch(afDiscX+strctTracker.m_fX,...
        afDiscY+strctTracker.m_fY,afCol,'Parent',hAxes,'EdgeColor','none','UserData','Center');
    a2fPt = R * [strctTracker.m_fA,0,-strctTracker.m_fA,0;...
        0,strctTracker.m_fB,0,-strctTracker.m_fB];
    afDiscX = 6*cos(afTheta);
    afDiscY = 6*sin(afTheta);

    for q=1:size(a2fPt,2)
        ahControls(q+1,1) = patch(strctTracker.m_fX+afDiscX+a2fPt(1,q),...
            strctTracker.m_fY+afDiscY+a2fPt(2,q),0.6*afCol,'Parent',hAxes,'EdgeColor','none','UserData','Major');
    end;

    
end;