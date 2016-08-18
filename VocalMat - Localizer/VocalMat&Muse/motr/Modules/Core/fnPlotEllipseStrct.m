function hHandle = fnPlotEllipseStrct(strctEllipse, afCol, iLineWidth, strLineStyle)
% Plots an ellipse which is represented as a 5 tuple.
%
% Inputs:
%   <strctEllipse.m_fX,strctEllipse.m_fY,strctEllipse.m_fA,strctEllipse.m_fB,strctEllipse.m_fTheta> - ellipse parameters
%    afCol - 1x3 color vector (RGB)
%    iLineWidth - 1x1 line width
% Outputs:
%    hHandle - handle to the plotted ellipse
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modistrctEllipse.m_fY
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

N = 60;

% Generate points on circle
%strctEllipse.m_fTheta = strctEllipse.m_fTheta + pi/2;
astrctEllipse.m_fTheta = linspace(0,2*pi,N);%2*pi*[0:N]/N;
apt2f = [strctEllipse.m_fA * cos(astrctEllipse.m_fTheta); strctEllipse.m_fB * sin(astrctEllipse.m_fTheta)];
R = [ cos(strctEllipse.m_fTheta), sin(strctEllipse.m_fTheta);
    -sin(strctEllipse.m_fTheta), cos(strctEllipse.m_fTheta)];
apt2fFinal = R*apt2f + repmat([strctEllipse.m_fX;strctEllipse.m_fY],1,N);
hHandle  = plot(apt2fFinal(1,:), apt2fFinal(2,:),'Color', afCol, 'LineWidth', iLineWidth,'LineStyle',strLineStyle);

return;
