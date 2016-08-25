function varargout = f(X,df,N)

% see docs for fft_sd

% deal w/ args
N_fft=length(X);
if nargin<3 || isempty(N)
  N=N_fft;
end

% calc stuff
T_padded=1/df;
dt=T_padded/N_fft;

% do an fftshift, to put the DC component back at element 1
X=ifftshift(X);

% Do the ifft, adding a scale factor to make the above Parseval theorem hold
x=ifft(sqrt(N/dt)*X);
x=x(1:N);

% create a time base
if nargout<=2
  varargout={x,dt};
else
  t=dt*(0:(N-1))';
  varargout={x,dt,t};
end
