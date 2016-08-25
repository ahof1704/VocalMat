function [apt2fControls] = fnGetEllipseControls(strctTracker)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology. 
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

R = [ cos(strctTracker.m_fTheta), sin(strctTracker.m_fTheta);
    -sin(strctTracker.m_fTheta), cos(strctTracker.m_fTheta)];
   
apt2fControls = R * [0,strctTracker.m_fA,0,-strctTracker.m_fA,0;...
        0,0,strctTracker.m_fB,0,-strctTracker.m_fB] + ...
        repmat([strctTracker.m_fX;strctTracker.m_fY],1,5);

return;