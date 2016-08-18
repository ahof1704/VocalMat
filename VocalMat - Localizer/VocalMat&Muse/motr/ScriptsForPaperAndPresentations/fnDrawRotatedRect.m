function fnDrawRotatedRect(h,fX,fY,fTheta, Col,fLineWidth)
a2iRect = [+111/2, +51/2;
           +111/2  -51/2;
            -111/2, -51/2;
            -111/2, +51/2;
            +111/2, +51/2];

Xt = a2iRect(:,1)';
Yt = a2iRect(:,2)';
R = [cos(fTheta),sin(fTheta);
    -sin(fTheta),cos(fTheta)];
Z = R*[Xt;Yt];
set(h,'xdata',Z(1,:)+fX,'ydata',Z(2,:)+fY,'color', Col,'LineWidth',fLineWidth);
return;
