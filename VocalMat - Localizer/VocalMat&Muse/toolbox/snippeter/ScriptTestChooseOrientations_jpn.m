%% loads data
% filename = 'A:\Neunuebel\ssl_sys_test\sys_test_06052012\mhdata2\Results\Tracks\Test_D_1.mat';
clc
clear
close all

% Exp_date = '06052012';
% Test = 'D';
% Exp_date = '06062012';
% Test = 'E';
% Exp_date = '06102012';
% Test = 'E';
Exp_date = '06112012';
Test = 'D';
% Exp_date = '06122012';
% Test = 'D';
% Exp_date = '06122012';
% Test = 'E';
% Exp_date = '06132012';
% Test = 'D';
% Exp_date = '06132012';
% Test = 'E';

if strcmp(Exp_date,'06052012')==1
    %     A:\Neunuebel\ssl_sys_test\sys_test_06052012\mhdata2\Results\Tracks
    filename = sprintf('A:\\Neunuebel\\ssl_sys_test\\sys_test_%s\\mhdata2\\Results\\Tracks\\Test_%s_1.mat',Exp_date,Test)
else
    filename = sprintf('A:\\Neunuebel\\ssl_sys_test\\sys_test_%s\\Results\\Tracks\\Test_%s_1.mat',Exp_date,Test)
end
load(filename)

data = astrctTrackers;
clear astrctTrackers strMovieFileName
x = data.m_afX; %x position
y = data.m_afY; %y position
theta = -data.m_afTheta; %theta;
%% parameters

% x0 = 0;
% y0 = 0;
% theta0 = 0;
% T = 1000;
% dampen_pos = .05;
% dampen_theta = .5;
% sigma_pos = .25;
% sigma_theta = .05;
%
% these are the parameters I use for tracking flies
velocity_angle_weight = .03;
max_velocity_angle_weight = .18;

theta_reconstruct = choose_orientations(x,y,theta,velocity_angle_weight,max_velocity_angle_weight);
T = numel(theta_reconstruct);

%% plot

% figure(1);
% clf;
% ax = [min(x),max(x),min(y),max(y)];
% ax = ax + [[-.01,.01]*(ax(2)-ax(1)),[-.01,.01]*(ax(4)-ax(3))];
% l = max(ax(2)-ax(1),ax(4)-ax(3))*.025;
%
% htrx = plot(x(1),y(1),'k.-');
% hold on;
% ho = plot(x(1),y(1),'ro','markerfacecolor','r');
% hdir = plot(x(1)+[0,cos(theta(1))*l],y(1)+[0,sin(theta(1))*l],'m-');
% drawnow;
% axis equal;
% axis(ax);
% axis ij
%
% for t = 2:T,
%   set(ho,'XData',x(t),'YData',y(t));
%   set(hdir,'XData',x(t)+[0,cos(theta(t))*l],'YData',y(t)+[0,sin(theta(t))*l]);
%   set(htrx,'XData',x(max(t-60,1):t),'YData',y(max(t-60,1):t));
%   pause(.033);
% end

%% lose direction

% theta_obs = modrange(theta,0,pi);
%
% theta_reconstruct = choose_orientations(x,y,theta_obs,velocity_angle_weight,max_velocity_angle_weight);

fprintf('Max reconstruction error: %f\n',max(abs(theta-theta_reconstruct)));

%% plot
%
% figure;
% clf;
% tmp = plot(repmat(1:T,[2,1]),[theta_reconstruct;theta],'.-');
% % tmp = plot(repmat(1:numel(thata),[2,1]),[t;thata],'.-');
% xlabel('Time');
% ylabel('Orientation vs reconstructed orientation');

%% determine part to plot

error1 = abs(theta-theta_reconstruct);
plot(error1)
title(sprintf('%s %s',Exp_date,Test))
xlabel('Frames')
ylabel('Abs (theta-theta reconstruction)')
cd C:\Data\reversal_correction_test
saveas(gcf,sprintf('%s %s',Exp_date,Test),'jpg')
close all
reversal_loc = find(error1>1);
count = 0;
if isempty(reversal_loc) == 0
    rb = diff(reversal_loc);
    rb_loc = find(rb>1);
    count = count + 1;
    plot_spots(1,count) = reversal_loc(1)-1;
    count = count + 1;
    plot_spots(1,count) = reversal_loc(1);
    if isempty(rb_loc) == 0
        rb_loc = rb_loc + 1;
        for i = 1:numel(rb_loc)
            count = count + 1;
            plot_spots(1,count) = reversal_loc(rb_loc)-1;
            count = count + 1;
            plot_spots(1,count) = reversal_loc(rb_loc);
        end
    end
end

disp(1)
close all
%% plot
% figure;
% clf;
% ax = [min(x),max(x),min(y),max(y)];
% ax = ax + [[-.01,.01]*(ax(2)-ax(1)),[-.01,.01]*(ax(4)-ax(3))];
% l = max(ax(2)-ax(1),ax(4)-ax(3))*.05;
%
% htrx = plot(x(1),y(1),'k.-');
% hold on;
% ho = plot(x(1),y(1),'ro','markerfacecolor','m');
% hdir = plot(x(1)+[0,cos(theta(1))*l],y(1)+[0,sin(theta(1))*l],'r-','linewidth',2);
% hdir_reconstruct = plot(x(1)+[0,cos(theta_reconstruct(1))*l],y(1)+[0,sin(theta_reconstruct(1))*l],'b-','linewidth',2);
% drawnow;
% axis equal;
% axis(ax);
% axis ij
% if isempty(reversal_loc) == 0
%     cd C:\Data\reversal_correction_test
%     for t = plot_spots%4884:4950%2:T,
%         set(ho,'XData',x(t),'YData',y(t));
%         set(hdir,'XData',x(t)+[0,cos(theta(t))*l],'YData',y(t)+[0,sin(theta(t))*l]);
%         set(hdir_reconstruct,'XData',x(t)+[0,cos(theta_reconstruct(t))*l],'YData',y(t)+[0,sin(theta_reconstruct(t))*l]);
%         set(htrx,'XData',x(max(t-60,1):t),'YData',y(max(t-60,1):t));
%         %   pause%(.25);
%         title(sprintf('%s %s %d',Exp_date,Test,t))
%         saveas(gcf,sprintf('%s %s %d',Exp_date,Test,t),'jpg')
%
%         %   if t == 1022,
%         %       keyboard;
%         %   end
%     end
% end

%% plot

clf;
ax = [min(x),max(x),min(y),max(y)];
ax = ax + [[-.01,.01]*(ax(2)-ax(1)),[-.01,.01]*(ax(4)-ax(3))];
l = max(ax(2)-ax(1),ax(4)-ax(3))*.05;

htrx = plot(x(1),y(1),'k.-');
hold on;
ho = plot(x(1),y(1),'ro','markerfacecolor','m');
hdir = plot(x(1)+[0,cos(theta(1))*l],y(1)+[0,sin(theta(1))*l],'r-','linewidth',2);
hdir_reconstruct = plot(x(1)+[0,cos(theta_reconstruct(1))*l],y(1)+[0,sin(theta_reconstruct(1))*l],'b-','linewidth',2);
drawnow;
% axis equal;
% axis(ax);
hold on
vfilename = sprintf('Test_%s_1.seq',Test);
dir2 = sprintf('A:\\Neunuebel\\ssl_sys_test\\sys_test_%s\\',Exp_date);
vfilename2 = [dir2 vfilename];
if isempty(reversal_loc) == 0
    cd C:\Data\reversal_correction_test
    for t = plot_spots%4884:4950%2:T,
        fn_FigureTrackFrame_jpn2(vfilename2,t)
        axis tight
        plot(x(t),y(t),'ro','markerfacecolor','m')
        %         set(ho,'XData',x(t),'YData',y(t));
        plot(x(t)+[0,cos(theta(t))*l],y(t)+[0,sin(theta(t))*l],'r-','linewidth',2)
        %       set(hdir,'XData',x(t)+[0,cos(theta(t))*l],'YData',y(t)+[0,sin(theta(t))*l]);
%         plot(x(t)+[0,cos(theta_reconstruct(t))*l],y(t)+[0,sin(theta_reconstruct(t))*l],'b-','linewidth',2)
%         set(hdir_reconstruct,'XData',x(t)+[0,cos(theta_reconstruct(t))*l],'YData',y(t)+[0,sin(theta_reconstruct(t))*l]);
%         plot(x(max(t-60,1):t),y(max(t-60,1):t),'k.-')
%         set(htrx,'XData',x(max(t-60,1):t),'YData',y(max(t-60,1):t));
        %   pause%(.25);
        title(sprintf('%s %s %d',Exp_date,Test,t))
        disp(1)
        
%         saveas(gcf,sprintf('%s %s %d',Exp_date,Test,t),'jpg')
        %   if t == 1022,
        %       keyboard;
        %   end
    end
end


close all