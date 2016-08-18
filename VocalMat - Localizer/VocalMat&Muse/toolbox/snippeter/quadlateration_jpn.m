% clc
% % close all
% clear

% cd C:\Users\neunuebelj\Documents\Lab\Beamforming\beamforming4\Beamforming01042012\Data_analysis\Automated
% load TestC_Mouse.mat
% cd C:\Users\neunuebelj\Documents\Lab\Beamforming\beamforming4\Beamforming01042012
% load positions_out.mat
% load meters_2_pixels.mat
% T = 21.6;%temp of recordings

% positions of mics
r1=[positions_out(1,1).x_m positions_out(1,1).y_m]';  % m
r2=[positions_out(1,2).x_m positions_out(1,2).y_m]';  % m
r3=[positions_out(1,3).x_m positions_out(1,3).y_m]';  % m
r4=[positions_out(1,4).x_m positions_out(1,4).y_m]';  % m
R=[r1 r2 r3 r4];
n_mic=size(R,2);

mouse_number = 1;
% position of mouse
r_true=[(mouse(2).pos_data(mouse_number).x*meters_2_pixels) (mouse(2).pos_data(mouse_number).y* meters_2_pixels)]'  % m
low_value_j = [(mouse(2).voc_colormap.x*meters_2_pixels) (mouse(2).voc_colormap.y* meters_2_pixels)]'  % m
mouse(2).voc_colormap.x
% r_true = [0.6 0.2]'
% velocity of sound in air
v = fn_velocity_sound(T);  % m/s

% % distance of mouse to each mic
% d1=norm(r_true-r1)
% d2=norm(r_true-r2)
% d3=norm(r_true-r3)
% d4=norm(r_true-r4)
% d=[d1 d2 d3 d4]'

% time-of-flight to each mic
% t_true=d/v;
TDOA = mouse(2).TDOA([1 2 3 5 6 9]);
TDOA = TDOA';

% mixing matrix to give time differences
M=[-1  1  0  0 ; ...  %sound is arriving at mic 2 before mic 1 
   -1  0  1  0 ; ...  %sound is arriving at mic 3 before mic 1 
   -1  0  0  1 ; ...  %sound is arriving at mic 4 before mic 1
    0 -1  1  0 ; ...  %sound is arriving at mic 3 before mic 2
    0 -1  0  1 ; ...  %sound is arriving at mic 4 before mic 2
    0  0 -1  1 ]      %sound is arriving at mic 4 before mic 3

% tmp = M(1,*TDOA
% tmp1 = M(1,:)*TDOA(1,1)
% tmp2 = M(2,:)*TDOA(2,1)
% tmp3 = M(3,:)*TDOA(3,1)
% tmp4 = M(4,:)*TDOA(4,1)
% tmp5 = M(5,:)*TDOA(5,1)
% tmp6 = M(6,:)*TDOA(6,1)
% M = cat(1,tmp1,tmp2,tmp3,tmp4,tmp5,tmp6);

dtx=-TDOA;  % Mixing matrix assumes that a positive dtx element
            % means that lower-index mic event happens before higher-index
            % mic event.  I.e. lower-index mic is closer.  Therefore we
            % flip sign here.

% make a fig
figure;
axes;
% xlim([-0.1 1.1]);
% ylim([-0.1 1.1]);
% axis square;
line(R(1,:),R(2,:),'marker','.','linestyle','none','color','b');
line(r_true(1),r_true(2),'marker','s','linestyle','none','color','r');
line(low_value_j(1),low_value_j(2),'marker','o','linestyle','none','color','g');
set(gca,'dataaspectratio',[1 1 1])
axis ij

% r_guess = ginput(1);
% r_guess = r_guess'
r_guess=[0.39 0.37]'
verbosity=1;
r=lateration_nr(dtx,M,v,R,r_guess,verbosity)

% plot final estimate of mouse position.
line(r(1),r(2),'marker','*','linestyle','none','color','g');
