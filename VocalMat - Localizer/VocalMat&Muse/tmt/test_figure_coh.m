% set up the time base
R=100  % number of windows to use for MT
dt=0.002;
T_pre=1;
T=80;
N_pre=ceil(T_pre/dt);
NR_want=ceil(T/dt);
N=round(NR_want/R)
NR=N*R
t_full=dt*(-N_pre:(NR-1))';
fs=1/dt;
fn=fs/2;

% seed the random number generator
randn('state',sum(100*clock));

% gaussian white noise
Ax_rms=1;
Az_rms=0.5;
%Az_rms=0;
x_full=normrnd(0,Ax_rms,size(t_full));
z_full=normrnd(0,Az_rms,size(t_full));

% design a filter
order=5;
ripple=0.5;  % dB
f_cutoff=50;  % Hz
%[b,a]=cheby1(order,ripple,f_cutoff/fn);
[b,a]=butter(order,f_cutoff/fn);

% apply the filter
% y=h conv x + z
y_full=filter(b,a,x_full)+z_full;

% trim the transient part
keep=t_full>=0;
t=t_full(keep);
y=y_full(keep,:);
x=x_full(keep,:);

% show the signals
figure;
subplot(2,1,1);
plot(t,x);
ylim([-5 5]);
ylabel('x');
title('signals');
subplot(2,1,2);
plot(t,y);
ylim([-5 5]);
ylabel('y');
xlabel('t');

% chop into windows
x_windowed=reshape(x,[N R]);
y_windowed=reshape(y,[N R]);

% center each window
x_windowed_cent=x_windowed-repmat(mean(x_windowed,1),[N 1]);
y_windowed_cent=y_windowed-repmat(mean(y_windowed,1),[N 1]);

% set some params
NW=4
conf_level=0.95

% test the coherence code
[f ...
 Cyx_mag Cyx_phase ...
 N_fft f_res_diam K ...
 Cyx_mag_ci, Cyx_phase_ci]=...
  coh_mt(dt,y_windowed_cent,x_windowed_cent,...
         NW,[],[],[],...
         conf_level);
N_fft
f_res_diam

% calc the significance threshold, quick
alpha_thresh=0.05;
C_mag_thresh_anal=coh_mt_control_analytical(R,K,alpha_thresh);

% calculate H(f) for the filter
[H,f_true]=freqz(b,a,f,fs);
H_mag=abs(H);
H_phase=unwrap(angle(H));

% the correct answers
Cyx_mag_true=1./sqrt(1+((Az_rms/Ax_rms)^2)./(H_mag.^2));
Cyx_phase_true=H_phase;

% plot
[h_fig_coh,...
 h_mag_axes,h_phase_axes,...
 h_mag,h_phase,...
 h_mag_ci,h_phase_ci,...
 h_mag_thresh]=...
  figure_coh(f,...
             Cyx_mag,Cyx_phase,...
             Cyx_mag_ci,Cyx_phase_ci,...
             [],[],[],...
             'output of figure_coh()',...
             C_mag_thresh_anal);
set(h_mag,'color',[0 0 1]);
set(h_phase,'color',[0 0 1]);
set(h_mag_ci,'facecolor',[0.7 0.8 1]);
set(h_phase_ci,'facecolor',[0.7 0.8 1]);
set(gcf,'currentaxes',h_mag_axes);
line(f_true,Cyx_mag_true,'color',[1 0 0]);
set(gcf,'currentaxes',h_phase_axes);
line_wrap(f_true,180/pi*Cyx_phase_true,[-180 180],'color',[1 0 0]);
