function [nose_x nose_y nose_x_r nose_y_r tail_x tail_y tail_x_r tail_y_r] = find_nose_tail_jpn(m1,indx,meters_2_pics, rotated_image)
% find_nose: returns x,y position of nose for each frame in indx
%
% form: m1=find_nose(m1,indx)
%
% m1 is a struct with fields x,y,a,b, and theta
% x,y are the x/y position of the center of the mouse ellipse in meters
% a,b are the major and minor axes of the ellipse (not radii)
% theta is the clockwise angle from the positive x-axis


h=m1.a(indx(:))/2;
%find nose
xn=(h.*cos(m1.theta(indx(:))));
yn=-(h.*sin(m1.theta(indx(:))));
nose_x=m1.x(indx(:))+xn;
nose_y=m1.y(indx(:))+yn;
nose_x = nose_x/meters_2_pics;
nose_y = nose_y/meters_2_pics;
%find tail
xn=-(h.*cos(m1.theta(indx(:))));
yn=(h.*sin(m1.theta(indx(:))));
tail_x=m1.x(indx(:))+xn;
tail_y=m1.y(indx(:))+yn;
tail_x = tail_x/meters_2_pics;
tail_y = tail_y/meters_2_pics;



%need to figure out how to rotate
% if microphone positions determined by rotating image
if strcmp(rotated_image,'y')==1
    this_theta = 1/2*pi;
    R = [cos(this_theta) -sin(this_theta); sin(this_theta) cos(this_theta)];
    
    %nose
    tmp_nose_x = nose_x;
    tmp_nose_y = nose_y;
    tmp_nose_x = tmp_nose_x-(511.5);
    tmp_nose_y = tmp_nose_y-(383.5);
    motr_nose_cat = cat(1,tmp_nose_x,tmp_nose_y);
    nose_r = R*motr_nose_cat;
    nose_x_r = nose_r(1,:)+(383.5);
    nose_y_r = nose_r(2,:)+(511.5);
    
    %tail
    %nose
    tmp_tail_x = tail_x;
    tmp_tail_y = tail_y;
    tmp_tail_x = tmp_tail_x-(511.5);
    tmp_tail_y = tmp_tail_y-(383.5);
    motr_tail_cat = cat(1,tmp_tail_x,tmp_tail_y);
    tail_r = R*motr_tail_cat;
    tail_x_r = tail_r(1,:)+(383.5);
    tail_y_r = tail_r(2,:)+(511.5);
end