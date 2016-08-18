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

% calc the significance threshold, two ways
alpha_thresh=0.05;
C_mag_thresh_anal=coh_mt_control_analytical(R,K,alpha_thresh);
C_mag_thresh_perm=coh_mt_control_perm(dt,y_windowed_cent,x_windowed_cent,...
                                      NW,[],[],[],...
                                      alpha_thresh);

% calculate H(f) for the filter
[H,f_true]=freqz(b,a,f,fs);
H_mag=abs(H);
H_phase=unwrap(angle(H));

% plot H
figure;
subplot(2,1,1);
plot(f_true,H_mag,'color',[0 0.5 0]);
ylim([0 1.05]);
ylabel('H mag');
subplot(2,1,2);
plot(NaN,NaN);  % plot nothing, but set up axes right
line_wrap(f_true,180/pi*H_phase,[-180 180],'color',[0 0.5 0]);
ylim([-180 +180]);
set(gca,'YTick',[-180 -90 0 +90 +180]);
ylabel('H phase (deg)');
xlabel('Frequency (Hz)');

% the correct answers
Cyx_mag_true=1./sqrt(1+((Az_rms/Ax_rms)^2)./(H_mag.^2));
Cyx_phase_true=H_phase;

% plot
figure;
subplot(2,1,1);
patch_eb(f,Cyx_mag_ci,[0.7 0.8 1]);
line(f,Cyx_mag);
line(f,C_mag_thresh_perm,'linestyle','--');
line(f,repmat(C_mag_thresh_anal,size(f)),'linestyle','--');
line(f_true,Cyx_mag_true,'color',[1 0 0]);
ylim([0 1.05]);
box on;
ylabel('Coh magnitude');
subplot(2,1,2);
patch_eb_wrap(f,180/pi*Cyx_phase,180/pi*Cyx_phase_ci,[-180 180],...
              [0.7 0.8 1]);
line_wrap(f,180/pi*Cyx_phase,[-180 180]);
line_wrap(f_true,180/pi*Cyx_phase_true,[-180 180],'color',[1 0 0]);
ylim([-180 +180]);
set(gca,'YTick',[-180 -90 0 +90 +180]);
box on;
ylabel('Coh phase (deg)');
xlabel('Frequency (Hz)');

