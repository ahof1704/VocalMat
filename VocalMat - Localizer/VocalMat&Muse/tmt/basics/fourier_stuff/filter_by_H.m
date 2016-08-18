function y=apply_filter(t,x,H,T_neg,T_pos,plot_verbosity)

% applies the filter specified by filt_fun to the signal in x.  H
% should be a function handle that maps an array of frequencies (in Hz) to
% to H(f) of the filter.
% T_neg+T_pos is the time-extent of the filter h(t), with T_neg being the
% duration of the part before t==0, and T_pos the duration of the part
% after t==0
%
% t and x should be col vectors.  t should be in seconds
% y is a col vector, same length as x, with NaNs where the y values are
% indeterminate because the filter kernel runs off the edge of the data in
% x

% deal w/ args
if nargin<6 || isempty(plot_verbosity)
  plot_verbosity=0;
end

% get info about time
t0=t(1);
tf=t(end);
T=tf-t0;
n_x=length(x);
dt=T/(n_x-1);

% translate T_pos, T_neg into numbers of steps
r_neg=ceil(T_neg/dt);
r_pos=ceil(T_pos/dt);
n_pad=r_neg+r_pos;

% center, pad x
x_mean=mean(x);
x_cent=x-x_mean;
x_padded=[x_cent;zeros(n_pad,1)];
n_x_padded=length(x_padded);

% figure out the FFT length (want power of 2)
n_fft=2^ceil(log2(n_x_padded));

% do the fft
X=fft(x_padded,n_fft);

% make a freq-line
f=f_base(dt,n_fft);  % unshifted f "timeline"

% apply the filter in f domain
H_array=feval(H,f);
Y=H_array.*X;

% plot stuff
if plot_verbosity>=1
  % let's see those
  figure;
  subplot(3,1,1);
  plot(fftshift(f),fftshift(abs(X)),'b');
  ylabel('X');
  subplot(3,1,2);
  plot(fftshift(f),fftshift(abs(H_array)),'g');
  ylabel('H');
  subplot(3,1,3);
  plot(fftshift(f),fftshift(abs(Y)),'r');
  ylabel('Y');
  xlabel('f (Hz)');

  pos=(f>=0);
  figure;
  subplot(3,1,1);
  loglog(f(pos),fftshift(abs(X(pos))),'b');
  ylabel('X');
  subplot(3,1,2);
  loglog(fftshift(f(pos)),fftshift(abs(H_array(pos))),'g');
  ylabel('H');
  subplot(3,1,3);
  loglog(fftshift(f(pos)),fftshift(abs(Y(pos))),'r');
  ylabel('Y');
  xlabel('f (Hz)');
end

% transform back (assume we only want real part)
y_padded=real(ifft(Y,n_fft));

% chop the pad
y_cent=y_padded(1:n_x);  % chop the pad

% un-center
y_mean=feval(H,0)*x_mean;
y=y_mean+y_cent;

% NaN out the invalid parts
y(1:r_pos)=NaN;
y(end-r_neg+1:end)=NaN;
