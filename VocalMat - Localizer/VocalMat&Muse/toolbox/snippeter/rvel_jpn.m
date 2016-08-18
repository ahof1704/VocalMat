function [spd,dx,theta]=rvel_jpn(m1,fc,low_f,s)
% function to calculate velocity from x/y position data
%
% form: spd=rvel(m1,fc,low_f,s)
%
% if s==1, then method is silly
% m1 is a struct with fields x, y in meters
% fc is sampling rate in Hz
% low_f is corner frequency for low pass filter, in Hz
% if low_f<0, no smoothing
%
% if s==2, then use deriv, which is much better
%
% spd is the speed in meters/second
% d is the step distance between x,y points, in meters
%
% note: this is chock full of distortions--use deriv.

if s==1
    dx=diff(m1.x);
    dy=diff(m1.y);
    dt=1/fc;
    %d=sqrt(dx.^2+dy.^2);
    veli=sqrt(dx.^2+dy.^2)/dt;
    
    dx=cat(2,dx',dy');
    
    if low_f>0
        b=fir1(1000,low_f/fc);
        spd=splitconv(veli,b);
    else
        spd=veli;
    end;
elseif s==2
    X(:,1)=m1.x';
    X(:,2)=m1.y';
    
    [dx,spd,theta,foo,foo2] = deriv_jpn(double(X),fc,fc*.2);
    % dx is two columns, with x and y velocities
    % theta: angle of deriv
    % which i'm not using at the moment
end;


% notes:
%
% the basic problem is that differentiating is a kind of filter,
% which introduces distortions
%
% a good way of checking if these distortions are problematic
% is to go back to position from velocity and see if you can reconstruct
% position
% an important point is that your position estimate has noise in it
% so you only want to reconstruct to your certainty about position
% otherwise you are just fitting noise
% s==1 will reconstruct perfectly, b/c it is fitting the noise
% but this means the velocity estimates are wrong by definition