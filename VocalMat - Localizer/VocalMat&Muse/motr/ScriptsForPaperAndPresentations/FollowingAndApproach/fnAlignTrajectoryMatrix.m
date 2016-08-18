function [Xb, Yb, Ab, Bb, Tb] = fnAlignTrajectoryMatrix(X,Y,A,B,Theta, iMouseA, iMouseB)
% Represent trajectoroy of mouse B in the coordinate system of mouse A.
% Further rotate the frame such that A always faces "noth" (tail to the
% south. 
% Use output to detect events relative to mouse A.

afCenterX = X(:,iMouseB)-X(:,iMouseA);
afCenterY = Y(:,iMouseB)-Y(:,iMouseA);

afCos = cos(Theta(:,iMouseA)-pi/2);
afSin = sin(Theta(:,iMouseA)-pi/2);

Xb = afCos .* afCenterX - afSin .* afCenterY;
Yb = -(afSin .* afCenterX + afCos .* afCenterY); % ij view

Tb = -pi/2 - (Theta(:,iMouseB)-Theta(:,iMouseA));

Ab = A(:,iMouseB);
Bb = B(:,iMouseB);
return;

