function [ r, handle ] = fn_quadlateration_jpn( dir2, positions_out, v, mouse, i, meters_2_pixels, vfilename )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
% created by AT and modified by JPN
% clc
% % close all
% clear

% positions of mics  
%------------------------------------------------------------------------
%NEED MIC Z
%------------------------------------------------------------------------
r1=[positions_out(1,1).x_m positions_out(1,1).y_m]';  % m
r2=[positions_out(1,2).x_m positions_out(1,2).y_m]';  % m
r3=[positions_out(1,3).x_m positions_out(1,3).y_m]';  % m
r4=[positions_out(1,4).x_m positions_out(1,4).y_m]';  % m

R=[r1 r2 r3 r4];
% n_mic=size(R,2);


% position of mouse 1
mouse_number = 1;
r_true1 = [(mouse(i).pos_data(mouse_number).x_head*meters_2_pixels) (mouse(i).pos_data(mouse_number).y_head* meters_2_pixels)]';  % m
% r_true1 = [(mouse(i).pos_data(mouse_number).x_head*meters_2_pixels)(mouse(i).pos_data(mouse_number).y_head* meters_2_pixels) 0]';  % m

% poisition of mouse 2
mouse_number = 2;
r_true2 = [(mouse(i).pos_data(mouse_number).x_head*meters_2_pixels) (mouse(i).pos_data(mouse_number).y_head* meters_2_pixels)]';  % m
% r_true2 = [(mouse(i).pos_data(mouse_number).x_head*meters_2_pixels) (mouse(i).pos_data(mouse_number).y_head* meters_2_pixels) 0]';  % m

%calcuated 2d colormap location
low_value_j = [(mouse(i).voc_colormap.x*meters_2_pixels) (mouse(i).voc_colormap.y* meters_2_pixels)]';  % m


% time-of-flight to each mic
% t_true=d/v;
% if strcmp (dir2,'C:\Users\neunuebelj\Documents\Lab\Beamforming\beamforming4\Beamforming01042012')==1
%     TDOA = mouse(i).TDOA([1 2 3 5 6 9]);
% else
TDOA = mouse(i).TDOA;
% end

TDOA = TDOA';

% mixing matrix to give time differences
M=[-1  1  0  0 ; ...  %sound is arriving at mic 2 before mic 1 
   -1  0  1  0 ; ...  %sound is arriving at mic 3 before mic 1 
   -1  0  0  1 ; ...  %sound is arriving at mic 4 before mic 1
    0 -1  1  0 ; ...  %sound is arriving at mic 3 before mic 2
    0 -1  0  1 ; ...  %sound is arriving at mic 4 before mic 2
    0  0 -1  1 ];      %sound is arriving at mic 4 before mic 3

dtx=-TDOA;  % Mixing matrix assumes that a positive dtx element
            % means that lower-index mic event happens before higher-index
            % mic event.  I.e. lower-index mic is closer.  Therefore we
            % flip sign here.

% make a fig
% figure;
% axes;

% xlim([-0.1 1.1]);
% ylim([-0.1 1.1]);
% axis square;
cd (dir2)
fn_FigureTrackFrame_jpn(vfilename,mouse(i).frame_range(1))
handle = gcf;
line((R(1,:)/meters_2_pixels),(R(2,:)/meters_2_pixels),'marker','.','linestyle','none','color','y');
line((r_true1(1)/meters_2_pixels),(r_true1(2)/meters_2_pixels),'marker','^','linestyle','none','color','w','MarkerSize',10,'MarkerFaceColor','w');
line((r_true2(1)/meters_2_pixels),(r_true2(2)/meters_2_pixels),'marker','s','linestyle','none','color','w','MarkerSize',10,'MarkerFaceColor','w');
line((low_value_j(1)/meters_2_pixels),(low_value_j(2)/meters_2_pixels),'marker','o','linestyle','none','color','w','MarkerFaceColor','w','MarkerSize',10);
set(gca,'dataaspectratio',[1 1 1])
axis ij

% r_guess = ginput(1);
% r_guess = r_guess'
r_guess=[.39 .37]';
verbosity=0;
r=lateration_nr2(dtx,M,v,R,r_guess,verbosity);

% plot final estimate of mouse position.
line((r(1)/meters_2_pixels),(r(2)/meters_2_pixels),'marker','*','linestyle','none','color','g','MarkerSize',10);

% % what's the final error?
% known=~isnan(dtx);
% M=M(known,:);
% dtx=dtx(known);
% E_internal=FJ_lateration3D(r,R,M,v,dtx)  % distance, m
% 
% % What is final error in distance?
% E_external=r-r_true  % distance, m

end

