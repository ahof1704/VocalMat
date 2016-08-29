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

% set some params
NW=4
conf_level=0.95

% test the PDS code
[f Pyy ...
 N_fft f_res_diam K ...
 Pyy_ci]= ...
  pow_mt(dt,y_windowed,NW,[],[],[],conf_level);
N_fft
f_res_diam

% The built-in code doesn't work on multiple samples...
% test the built-in PDS code
for i=1:R
  [Pyy_each(:,i) Pyy_conf f_pmtm]=...
    pmtm(y_windowed(:,i),NW,N_fft,fs,conf_level,'adapt');
end
Pyy_pmtm=mean(Pyy_each,2);  

% the correct answers
Pxx_true=2/fs*repmat(Ax_rms^2,size(f));
H=freqz(b,a,f,fs);
H_mag=abs(H);
H_phase=unwrap(angle(H));
Pyy_true=2/fs*(Ax_rms^2*H_mag.^2+Az_rms^2);

% plot spectrum
figure;
axes;
patch_eb(f,Pyy_ci,[0.7 0.8 1]);
line(f,Pyy,'color','b');
line(f,Pyy_true,'color',[1 0 0]);
box on;
title('Mine')

% plot spectrum
figure;
plot(f_pmtm,Pyy_pmtm);
hold on;
%line(f,Pyy_conf,'color',[0.5 0.5 1]);
line(f,Pyy_true,'color',[1 0 0]);
hold off;
title('Matlab');

