function [nose_x nose_y nose_x_r nose_y_r] = find_nose_jpn(m1,indx,meters_2_pics, rotated_image)
% find_nose: returns x,y position of nose for each frame in indx
%
% form: m1=find_nose(m1,indx)
%
% m1 is a struct with fields x,y,a,b, and theta
% x,y are the x/y position of the center of the mouse ellipse in meters
% a,b are the major and minor axes of the ellipse (not radii)
% theta is the clockwise angle from the positive x-axis

h=m1.a(indx(:))/2;
xn=(h.*cos(m1.theta(indx(:))));
yn=-(h.*sin(m1.theta(indx(:))));
nose_x=m1.x(indx(:))+xn;
nose_y=m1.y(indx(:))+yn;
nose_x = nose_x/meters_2_pics;
nose_y = nose_y/meters_2_pics;

%need to figure out how to rotate
% if microphone positions determined by rotating image
if strcmp(rotated_image,'y')==1
    this_theta = 1/2*pi;
    R = [cos(this_theta) -sin(this_theta); sin(this_theta) cos(this_theta)];
    
%     hiA = ([ 383.5000])*meters_2_pics;%center point of image that was rotated x/y
    tmp_nose_x = nose_x;
    tmp_nose_y = nose_y;
%     plot(tmp_nose_x(1:10),tmp_nose_y(1:10),'r.')
    tmp_nose_x = tmp_nose_x-(511.5);
    tmp_nose_y = tmp_nose_y-(383.5);
%     hold on
%     plot(tmp_nose_x(1:10),tmp_nose_y(1:10),'g.')
%     xlim([0 hiA(1)*2])
%     ylim([0 hiA(2)*2])
    motr_nose_cat = cat(1,tmp_nose_x,tmp_nose_y);
    nose_r = R*motr_nose_cat;
    nose_x_r = nose_r(1,:)+(383.5);
    nose_y_r = nose_r(2,:)+(511.5);
end