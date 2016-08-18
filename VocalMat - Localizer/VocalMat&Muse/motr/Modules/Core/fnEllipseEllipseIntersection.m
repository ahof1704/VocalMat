function [bIntersect, apt3fIntersectionPoints, fIntersectionArea] = fnEllipseEllipseIntersection(...
    x0_0,y0_0,a_0,b_0,theta_0,x0_1,y0_1,a_1,b_1,theta_1)
% Ellipse-Ellipse intersection routine.
% Based on the wonderful work of David Eberly
% (http://www.geometrictools.com/Documentation/IntersectionOfEllipses.pdf)
%
% Note - if ellipses are contained one inside the other, bIntersect = false
%
% Inputs:
%  <x0_0,y0_0,a_0,b_0,theta_0> - first ellipse parameters
%  <x0_1,y0_1,a_1,b_1,theta_1> - second ellipse parameters
% Outputs:
%  bIntersect - True if ellipse 0 intersects ellipse 1
%  apt3fIntersectionPoints - list of intersection points (Nx2)
%  bContained - True if ellipse 0 (1) is contained inside ellipse 1 (0)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

apt3fIntersectionPoints = [];
fIntersectionArea = 0;

if isnan(x0_0) || isnan(x0_1)
    bIntersect = false;
    return;
end;

% Use Quadratic representation
[A0,B0,C0]=fnEllipseExplicitToImplicit(x0_0,y0_0,a_0,b_0,theta_0); % Q0
[A1,B1,C1]=fnEllipseExplicitToImplicit(x0_1,y0_1,a_1,b_1,theta_1); % Q1

% Compute the B´ezout determinant R(y) = U0+U1*y+U2*y^2+U3*y^3+U4*y^4
V0 = 2 * (A0(1,1) * A1(1,2) - A1(1,1) * A0(1,2));
V1 = A0(1,1) * A1(2,2) - A1(1,1)*A0(2,2);
V2 = A0(1,1)*B1(1) - A1(1,1)*B0(1);
V3 = A0(1,1) * B1(2) - A1(1,1)*B0(2);
V4 = A0(1,1)*C1 - A1(1,1) * C0;
V5 = 2*(A0(1,2)*A1(2,2) - A1(1,2)*A0(2,2));
V6 = 2 * (A0(1,2)*B1(2) - A1(1,2)*B0(2));
V7 = 2 * (A0(1,2)*C1 - A1(1,2)*C0);
V8 = A0(2,2)*B1(1) - A1(2,2)*B0(1);
V9 = B0(1)*B1(2) - B1(1)*B0(2);
V10 = B0(1)*C1 -B1(1)*C0;

U0 = V2*V10 -V4^2;
U1 = V0*V10 +V2*(V7+V9)-2*V3*V4;
U2 = V0*(V7+V9) + V2*(V6 - V8) - V3^2 - 2*V1*V4;
U3 = V0*(V6-V8) + V2*V5 - 2*V1*V3;
U4 = V0*V5-V1^2;

% Compute the roots of R(y)
afPolynomial = [U4 U3 U2 U1 U0];
if sum(abs(afPolynomial)) < 1e-8 % == 0.0
    % Two ellipses overlap exactly (!)
    bIntersect = true;
    fIntersectionArea = pi*a_0*b_0;
    return;
end;

if sum(isinf(afPolynomial)) > 0 || sum(isnan(afPolynomial)) > 0
    bIntersect = false;
    fIntersectionArea = 0;
    return;
end;

afY = roots(afPolynomial);

% At least one real root exists means there is an intersection
bIntersect = sum(imag(afY) == 0) > 0;

fEps = 1e-3;
for k=1:length(afY) % loop over roots of the polynomial
    if isreal(afY(k))
        Alpha0 = A0(2,2)*afY(k).^2 + B0(2) *afY(k) + C0;
        Alpha1 = 2*A0(1,2)*afY(k)+B0(1);
        Alpha2 = A0(1,1);
        % Solve Q0(x,y) = 0, where y is the root of R(y).
        % Q0(x,y) is a quadratic polynomial in X where coefficients are polynomials in Y
        % afX = roots([Alpha2,Alpha1,Alpha0]);
        DetQ = real(sqrt(Alpha1^2-4*Alpha2*Alpha0));
        X1 = (-Alpha1 + DetQ) / (2*Alpha2);
        X2 = (-Alpha1 - DetQ) / (2*Alpha2);
        % eliminate false solutions by verifying that Q

        Beta0 = A1(2,2)*afY(k).^2+B1(2)*afY(k)+C1;
        Beta1 = 2*A1(1,2)*afY(k)+B1(1);
        Beta2 = A1(1,1);

        if (abs(Beta2 * X1^2 + Beta1 * X1 + Beta0) < fEps) 
            apt3fIntersectionPoints = [apt3fIntersectionPoints; X1, afY(k)];
        end;

        if (abs(Beta2 * X2^2 + Beta1 * X2 + Beta0) < fEps) && DetQ ~= 0.0
            apt3fIntersectionPoints = [apt3fIntersectionPoints; X2, afY(k)];
        end;

    end;
end;



if bIntersect
    if size(apt3fIntersectionPoints,1) == 1
        % one intersection point - area is zero
        fIntersectionArea = 0;
    end;
    if size(apt3fIntersectionPoints,1) == 2
        % we need to find the "third" point. It is one of the ellipses apex
        % points, and is inside the other ellipse...

        % Basically, consider all points that are "inside", as well as the
        % middle point along each ellipse (between the detected two
        % intersecting points...)
        %         figure(11);
        %         clf;
        %         hold on;
        %         fnPlotEllipse(x0_0,y0_0, a_0, b_0, theta_0, [1 0 0],2);
        %         fnPlotEllipse(x0_1,y0_1, a_1, b_1, theta_1, [0 1 0],2);
        %         plot(apt3fIntersectionPoints(:,1),apt3fIntersectionPoints(:,2),'b*');
        R0 = [ cos(theta_0), sin(theta_0);
            -sin(theta_0), cos(theta_0)];
        R1 = [ cos(theta_1), sin(theta_1);
            -sin(theta_1), cos(theta_1)];

        a2fPt0 = [x0_0,x0_0,x0_0,x0_0;y0_0,y0_0,y0_0,y0_0]+R0 * [a_0,0,-a_0,0;0,b_0,0,-b_0];
        a2fPt1 = [x0_1,x0_1,x0_1,x0_1;y0_1,y0_1,y0_1,y0_1]+R1 * [a_1,0,-a_1,0;0,b_1,0,-b_1];

        % Test whether apex of 0 are inside 1
        ab0Inside1 = diag(a2fPt0' * A1 * a2fPt0)' + B1' * a2fPt0 +C1 < 0;
        ab1Inside0 = diag(a2fPt1' * A0 * a2fPt1)' + B0' * a2fPt1 +C0 < 0;

        % compute mean point between the found intersecting ones

        Q0_0=R0' * (apt3fIntersectionPoints(1,:)' - [x0_0;y0_0]) ./ [a_0;b_0];
        Q0_1=R0' * (apt3fIntersectionPoints(2,:)' - [x0_0;y0_0]) ./ [a_0;b_0];
        fMiddle0 = atan2((Q0_0(2)+Q0_1(2)) /2, (Q0_0(1)+Q0_1(1))/2);
        PtM0 = R0*[a_0*cos(fMiddle0);b_0*sin(fMiddle0)] + [x0_0;y0_0];

        Q1_0=R1' * (apt3fIntersectionPoints(1,:)' - [x0_1;y0_1]) ./ [a_1;b_1];
        Q1_1=R1' * (apt3fIntersectionPoints(2,:)' - [x0_1;y0_1]) ./ [a_1;b_1];
        fMiddle1 = atan2((Q1_0(2)+Q1_1(2)) /2, (Q1_0(1)+Q1_1(1))/2);
        PtM1 = R1*[a_1*cos(fMiddle1);b_1*sin(fMiddle1)] + [x0_1;y0_1];

        X=[apt3fIntersectionPoints;PtM0';  PtM1'; a2fPt0(:,ab0Inside1)';a2fPt1(:,ab1Inside0)'];
        [K,fIntersectionArea] = convhulln(double(X));

%                     for j=1:size(K,1)
%                         plot([X(K(j,1),1) X(K(j,2),1)], [X(K(j,1),2) X(K(j,2),2)],'b','LineWidth',2);
%                     end;

    end;
    if size(apt3fIntersectionPoints,1) == 3 || size(apt3fIntersectionPoints,1) == 4
        % easiest way to approximate this area is by considering the convex
        % shape of these four points. (area of two triangles...)
        [K,fIntersectionArea] = convhulln(apt3fIntersectionPoints);

        %             for j=1:size(K,1)
        %                 plot([X(K(j,1),1) X(K(j,2),1)], [X(K(j,1),2) X(K(j,2),2)],'b','LineWidth',2);
        %             end;

    end;
end;

return;

%%
% figure(10);
% clf;
% fnPlotEllipse(x0_0,y0_0,a_0,b_0,theta_0, [1 0 0],2);
% hold on;
% fnPlotEllipse(x0_1,y0_1,a_1,b_1,theta_1, [0 1 0],2);
% plot(apt3fIntersectionPoints(:,1),apt3fIntersectionPoints(:,2),'b*');
% plot(X(:,1),X(:,2),'cd');
