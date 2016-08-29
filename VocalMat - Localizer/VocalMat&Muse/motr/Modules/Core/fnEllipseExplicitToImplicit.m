function [A,B,C]=fnEllipseExplicitToImplicit(x0,y0,a,b,theta)
% Converts [x0,y0,a,b,theta] representation to quadratic curve
% (X'*A*X+B*X+C = 0)
%
% Inputs:
% x0 - Ellipse Center X coordinate
% y0 - Ellipse Center Y coordinate
% a - Major axis length (half length of ellipse diameter)
% b - Minor axis length
% theta - rotation angle (0 deg means horizontal ellipse)
%
% Outputs:
% A - 2x2, B - 2x1, C - 1x1
% such that for all (x,y) on ellipse : ([X;Y]' * A * [X;Y] + B * [X;Y] + C = 0)
% 
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology. 
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

ct=cos(theta);
st=sin(theta);
a00 = (-ct^2*a^2+a^2+b^2*ct^2);
a01 = 1/2 * ((-2*b^2*ct*st+2*a^2*ct*st));
b0 = -2*a^2*ct*st*y0-2*b^2*ct^2*x0-2*a^2*x0+2*b^2*ct*st*y0+2*ct^2*a^2*x0;
a11 = (-b^2*ct^2+ct^2*a^2+b^2);
b1 = (-2*a^2*ct^2*y0-2*a^2*ct*x0*st-2*b^2*y0+2*b^2*ct*x0*st+2*ct^2*b^2*y0);
c = -ct^2*a^2*x0^2+b^2*ct^2*x0^2-a^2*b^2+a^2*x0^2-ct^2*b^2*y0^2+2*a^2*ct*x0*st*y0+a^2*ct^2*y0^2+...
    b^2*y0^2-2*b^2*ct*x0*st*y0;


A = [a00, a01;
     a01, a11] /(a^2*b^2) ;
B = [b0;b1] /(a^2*b^2);
C = c /(a^2*b^2);

return;

% N = 100;
% afPhi = linspace(0,2*pi,N);
% apt2f = [a * cos(afPhi); b * sin(afPhi)];
% R = [ ct, st;
%    -st, ct];
% apt2fFinal = R*apt2f + repmat([x0;y0],1,N);
% figure(6);clf;
% plot(apt2fFinal(1,:), apt2fFinal(2,:));
% 
% X = apt2fFinal(1,:);
% Y = apt2fFinal(2,:);
% 
% Q=(1/a * (ct * (X-x0)  -st * (Y-y0))) .^2 + ...
%(1/b * (st * (X-x0) + ct * (Y-y0))) .^2  -1
% Z=simplify(Q*a^2*b^2)
% 
% collect(Z,X)