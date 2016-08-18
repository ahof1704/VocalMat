clc
clear
close all

num_virtual_mice = 3;
spacer = 180;
step_angle = 360/spacer;
nFrames = 500;
video_fname_prefix = 'Test_D_1';
dir2 = 'A:\Neunuebel\ssl_sys_test\sys_test_06052012';
cd (dir2)
load_saved_corners = 'y';
load(sprintf('%s_video_pulse_start_ts.mat',video_fname_prefix));
load('meters_2_pixels.mat')
vfilename = sprintf('%s.seq',video_fname_prefix);
[corners_out, handle1] = fn_corner_pos_location(dir2,vfilename,meters_2_pixels,load_saved_corners, video_fname_prefix);
[ cage_x, cage_y ] = fn_range_x_y_cords( corners_out );

for i = 1:size(video_pulse_start_ts,1)
    if i == 1
        randomized_cords = zeros(size(video_pulse_start_ts,1),num_virtual_mice*2);
        abstheta = randomized_cords;
        mags = randomized_cords;
        randomized_cords = fn_random_select_cords2( cage_x, cage_y, i, randomized_cords, num_virtual_mice);
    elseif i == 2
        randomized_cords = fn_random_select_region_cords( cage_x, cage_y, i, randomized_cords, num_virtual_mice);
    else
        [randomized_cords abstheta mags] = fn_random_select_theta_region_cords( cage_x, cage_y, i, randomized_cords, num_virtual_mice, step_angle,abstheta, mags);
    end
%     randomized_cords(i,:)
end

figure
plot(randomized_cords(1:nFrames,1),randomized_cords(1:nFrames,2))
hold on
plot(randomized_cords(1:nFrames,3),randomized_cords(1:nFrames,4),'r')
plot(randomized_cords(1:nFrames,5),randomized_cords(1:nFrames,6),'g')
close all

cd C:\Users\neunuebelj\Documents\Lab
aviobj = avifile('Example.avi','compression','None');

fig=figure;
clf;
ax = ([min(cage_x),max(cage_x),max(cage_x),min(cage_x),min(cage_x);min(cage_y),min(cage_y),max(cage_y),max(cage_y),min(cage_y)])/10;
% ax = ([min(cage_x),max(cage_x),min(cage_y),max(cage_y)])/10;
% ax = ax + [[-.01,.01]*(ax(2)-ax(1)),[-.01,.01]*(ax(4)-ax(3))];
ax2 = [0,800,100,900];
l = max(ax(2)-ax(1),ax(4)-ax(3))*.025;

htrx_vm1 = plot(randomized_cords(1,1),randomized_cords(1,2),'b-','linewidth',2);
hold on;
htrx_vm2 = plot(randomized_cords(1,3),randomized_cords(1,4),'r-','linewidth',2);
htrx_vm3 = plot(randomized_cords(1,5),randomized_cords(1,6),'g-','linewidth',2);
drawnow;
axis equal;
axis(ax2);
plot(ax(1,:),ax(2,:),'k')
% ha = gca;
% % Preallocate movie structure.
nFrames = size(video_pulse_start_ts,1);
M(1:nFrames) = struct('cdata', zeros(420,560,3),...
                         'colormap', []);
% M = getframe;
% aviobj = addframe(aviobj,M(1));
for t = 1:size(video_pulse_start_ts,1),
    set(htrx_vm1,'XData',randomized_cords(max(t-30,1):t,1),'YData',randomized_cords(max(t-30,1):t,2));
    set(htrx_vm2,'XData',randomized_cords(max(t-30,1):t,3),'YData',randomized_cords(max(t-30,1):t,4));
    set(htrx_vm3,'XData',randomized_cords(max(t-30,1):t,5),'YData',randomized_cords(max(t-30,1):t,6));
%       pause(.033);
%       t
      
    M(t) = getframe(fig);
    aviobj = addframe(aviobj,M(t));
end
close(fig);
aviobj = close(aviobj);

% movie2avi(M, 'Virtual_mice.avi', 'compression', 'None');