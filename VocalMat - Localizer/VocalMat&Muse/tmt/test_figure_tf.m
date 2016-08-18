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
 H_mag H_phase ...
 N_fft f_res_diam K ...
 H_mag_ci, H_phase_ci]=...
  tf_mt(dt,y_windowed_cent,x_windowed_cent,...
        NW,[],[],[],...
        conf_level);
N_fft
f_res_diam

% calculate H(f) for the filter
[H_true,f_true]=freqz(b,a,f,fs);
H_mag_true=abs(H_true);
H_phase_true=unwrap(angle(H_true));

% plot
[h_mag_axes,h_phase_axes,...
 h_mag,h_phase,...
 h_mag_ci,h_phase_ci]=...
  figure_tf(f,...
            H_mag,H_phase,...
            H_mag_ci,H_phase_ci,...
            [],[],[],...
            'output of figure_tf()');
set(h_mag,'color',[0 0 1]);
set(h_phase,'color',[0 0 1]);
set(h_mag_ci,'facecolor',[0.7 0.8 1]);
set(h_phase_ci,'facecolor',[0.7 0.8 1]);
set(gcf,'currentaxes',h_mag_axes);
line(f_true,H_mag_true,'color',[1 0 0]);
set(gcf,'currentaxes',h_phase_axes);
line_wrap(f_true,180/pi*H_phase_true,[-180 180],'color',[1 0 0]);
