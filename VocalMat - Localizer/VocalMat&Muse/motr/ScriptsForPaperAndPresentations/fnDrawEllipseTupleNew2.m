function fnDrawEllipseTupleNew2(h,fX,fY,fA,fB,fTheta, Col,fLineWidth)
N = 60;
fTheta = fTheta + pi/2;
afTheta = linspace(0,2*pi,N);
Xt = fA * cos(afTheta);
Yt = fB * sin(afTheta);
R = [cos(fTheta),sin(fTheta);
    -sin(fTheta),cos(fTheta)];
Z = R*[Xt;Yt];
set(h,'xdata',Z(1,:)+fX,'ydata',Z(2,:)+fY,'color', Col,'LineWidth',fLineWidth);
return;
