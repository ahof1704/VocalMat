function y=apply_filter(t,x,H,plot_verbosity)

% applies the filter specified by filt_fun to the signal in x.  H
% should be a function handle that maps an array of frequencies (in Hz) to
% to H(f) of the filter.
% T_neg and T_pos are ignored
%
% t and x should be col vectors.  t should be in seconds
% x should be some integral number of periods of a periodic signal
% y is a col vector, same length as x

% deal w/ args
if nargin<4 || isempty(plot_verbosity)
  plot_verbosity=0;
end

% get info about time
t0=t(1);
tf=t(end);
T=tf-t0;
n_x=length(x);
dt=T/(n_x-1);

% do the fft
X=fft(x);

% make a freq-line
f=f_base(dt,n_x);  % unshifted f "timeline"

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
y=real(ifft(Y));
