function h=fnDrawEllipseTupleNew1(fX,fY,fA,fB,fTheta, Col,fLineWidth)
N = 60;
fTheta = fTheta + pi/2;
afTheta = linspace(0,2*pi,N);
Xt = fA * cos(afTheta);
Yt = fB * sin(afTheta);
R = [cos(fTheta),sin(fTheta);
    -sin(fTheta),cos(fTheta)];
Z = R*[Xt;Yt];
h=plot(Z(1,:)+fX,Z(2,:)+fY,'color', Col,'LineWidth',fLineWidth);
return;
