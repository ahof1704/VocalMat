function afProb = fnVonMises(Mue, Kappa, afAngles)
% Estimates the von Mises distribution
I0 = besseli(0,Kappa);
%I0=fnBessi0(Kappa);
afProb = 1/(2*pi*I0)* exp(Kappa * cos(afAngles-Mue));
return;
