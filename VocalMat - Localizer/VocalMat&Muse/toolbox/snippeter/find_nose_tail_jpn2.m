function [nose_x nose_y tail_x tail_y] = find_nose_tail_jpn2(m1,indx,num_mice)
% find_nose: returns x,y position of nose for each frame in indx
%
% form: m1=find_nose(m1,indx)
%
% m1 is a struct with fields x,y,a,b, and theta
% x,y are the x/y position of the center of the mouse ellipse in meters
% a,b are the major and minor axes of the ellipse (not radii)
% theta is the clockwise angle from the positive x-axis


h=m1.m_afA(indx(:))/2;
%find nose
xn=(h.*cos(m1.m_afTheta(indx(:))));
yn=-(h.*sin(m1.m_afTheta(indx(:))));
nose_x=m1.m_afX(indx(:))+xn;
nose_y=m1.m_afY(indx(:))+yn;

%find tail
xn=-(h.*cos(m1.m_afTheta(indx(:))));
yn=(h.*sin(m1.m_afTheta(indx(:))));
tail_x=m1.m_afX(indx(:))+xn;
tail_y=m1.m_afY(indx(:))+yn;

