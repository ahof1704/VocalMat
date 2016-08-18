function m1=find_tail_jpn(m1,indx)
% find_nose: returns x,y position of tail for each frame in indx
%
% form: m1=find_tail(m1,indx)
%
% m1 is a struct with fields x,y,a,b, and theta
% x,y are the x/y position of the center of the mouse ellipse in meters
% a,b are the major and minor axes of the ellipse (not radii)
% theta is the clockwise angle from the positive x-axis
% m1 has values of tail_x/y at indx

for i=1:length(indx)
    h=m1.a(indx(i))/2;
    xn=-(h*cos(m1.theta(indx(i))));
    yn=h*sin(m1.theta(indx(i)));
    m1.tail_x(indx(i))=m1.x(indx(i))+xn;
    m1.tail_y(indx(i))=m1.y(indx(i))+yn;
end;

