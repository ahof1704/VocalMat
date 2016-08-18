n_mikes=4;
fs=1e6;  % Hz
dt=1/fs;  % s
T_want=0.040;  % s
n_t=round(T_want/dt);
%fs=450450;  % Hz
f_lo=0;  % Hz
f_hi=inf;  % Hz
Temp=21.7;  % Temperature in Celsius 
dx=250e-6;  % m
xl=[-0.3 +0.3];
yl=[-0.3 +0.3];
radius_perturbation=0.1;  % m
%theta=unifrnd(0,2*pi);
R1_x=+0.3;
%R1_y=radius_perturbation*sin(theta);
%R1_z=radius_perturbation*cos(theta);
R1_y=0;
R1_z=0;
%theta=unifrnd(0,2*pi);
R2_x=-0.3;
%R2_y=radius_perturbation*sin(theta);
%R2_z=radius_perturbation*cos(theta);
%R2_y=+0.05;
R2_y=0;
R2_z=0;
R3_y=+0.3;
%R3_x=radius_perturbation*sin(theta);
%R3_z=radius_perturbation*cos(theta);
%R3_x=0.1;
R3_x=0;
R3_z=0;
theta=unifrnd(0,2*pi);
R4_y=-0.3;
%R4_x=radius_perturbation*sin(theta);
%R4_z=radius_perturbation*cos(theta);
%R4_x=0.05;
R4_x=0;
R4_z=0;
R=[ R1_x R1_y R1_z ; ...
    R2_x R2_y R2_z ; ...
    R3_x R3_y R3_z ; ...
    R4_x R4_y R4_z ]';  % m
r_head=[0 0]';  % m
r_tail=[-0.08 0]';  % m
title_str='test';
verbosity=1;

% make some grids and stuff
x_line=(xl(1):dx:xl(2))';
y_line=(yl(1):dx:yl(2))';
n_x=length(x_line);
n_y=length(y_line);
x_grid=repmat(x_line ,[1 n_y]);
y_grid=repmat(y_line',[n_x 1]);

% everything in the case
in_cage=true(size(x_grid));

% generate the noise-free synthetic data
% no time delays, implies that the source is at the origin
t=dt*((-n_t/2):(n_t/2-1))';
%slope_f=1e6;  % Hz/s
slope_f=0.2e6;  % Hz/s
f0_0=80000;  % Hz
f0=f0_0+slope_f*t;
tau=8e-3;  % s
%tau=0.1e-3;  % s
A=0.1;  % V
global v_single_true;
v_single_true=A*exp(-(t/tau).^2).*cos(2*pi*(f0.*t));
%v_single_true=A*exp(-(t/tau).^2);
global gain;
gain=[1 0.5 0.3 0.1];
r_true=[0 0]';

% delay the signals appropriately
rsubR=bsxfun(@minus,[r_true;0],R);  % 3 x n_mike, pos rel to each mike
d=reshape(sqrt(sum(rsubR.^2,1)),[n_mikes 1]);  % m, n_mike x 1
vel=velocity_sound(Temp);  % m/s
global delay_true;
delay_true=(1/vel)*d ; % true time delays, s, n_mike x 1
phi=phi_base(n_t);
V_single_true=fft(v_single_true);
V_true_delayed=zeros(n_t,n_mikes);
for i=1:n_mikes
  V_true_delayed=V_single_true.*exp(-1i*2*pi*phi*delay_true(i)/dt);
end
v_true_delayed=real(ifft(V_true_delayed));  

% multiple by the respective gain factors
v_true_delayed_amped=bsxfun(@times,gain,v_true_delayed);

% colors for microphones
clr_mike=[0 0   1  ; ...
          0 0.7 0  ; ...
          1 0   0  ; ...
          0 0.8 0.8];

% plot the true signals, without noise
if (verbosity>=1)
  figure('color','w');
  for k=1:n_mikes
    subplot(n_mikes,1,k);
    plot(1000*t,1000*v_true_delayed_amped(:,k),'color',clr_mike(k,:));
    if k==1
      title('Synthetic signals, without noise');
    end
    ylim(ylim_tight(1000*v_true_delayed_amped(:,k)));
    ylabel(sprintf('Mic %d (mV)',k));
  end
  xlabel('Time (ms)');
  ylim_all_same();
%   tl(1000*t(1),1000*t(end));
  drawnow;
end

% add noise
sigma_v=0.020;  % V
noise=normrnd(0,sigma_v,n_t,n_mikes);
v_clip=v_true_delayed_amped+noise;

% plot the true signals, with noise
if (verbosity>=0)
  figure('color','w');
  for k=1:n_mikes
    subplot(n_mikes,1,k);
    plot(1000*t,1000*v_clip(:,k),'color',clr_mike(k,:));
    if k==1
      title('Synthetic signals, with noise');
    end
    ylim(ylim_tight(1000*v_clip(:,k)));
    ylabel(sprintf('Mic %d (mV)',k));
  end
  xlabel('Time (ms)');
  ylim_all_same();
%   tl(1000*t(1),1000*t(end));
  drawnow;
end

% estimate the mouse position with the true mic positions
[r_est,rsrp_max,rsrp_grid,a,vel,N_filt,V_filt,V]= ...
  r_est_from_clip_simplified(v_clip,fs, ...
                             f_lo,f_hi, ...
                             Temp, ...
                             x_grid,y_grid,in_cage, ...
                             R, ...
                             verbosity);

% make a figure of that
[fig_h,axes_h,axes_cb_h]= ...
  figure_objective_map(x_grid,y_grid,rsrp_grid, ...
                       'jet', ...
                       [], ...
                       'Estimate with true mic positions', ...
                       'RSRP (V^2)', ...
                       clr_mike, ...
                       [1 1 1], ...
                       r_est,[], ...
                       R,r_true,r_true+[-0.08 0]');
                     