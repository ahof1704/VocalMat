function varargout = f(x,dt,N_fft)

% t should be a vector, x a vector or matrix with signals in cols
%
% the output of this function satifies this version of Parseval's 
% theorem:
%
%   Sum_j(x_j^2) == Sum_j(X_j^2)
%
% the "_amp" in the name stands for "Amplitudes", since the X_j's are
% complex exponential amplitudes.
% Note that x_j is _before_ zero-padding, and N is the length of
% x before zero-padding.  X_j will have N_fft elements, and df will be equal
% to 1/(N_fft*dt)

% deal w/ args
N=length(x);
if nargin<3 || isempty(N_fft)
  N_fft=N;
elseif strcmp(N_fft,'pow2')
  N_fft=2^ceil(log2(N));
end

% calc stuff
T=N_fft*dt;
df=1/T;

% Do the fft, adding a scale factor to make the above Parseval theorem hold
X=1/N_fft*fft(x,N_fft);

% shift the fft to a more plotable form
X=fftshift(X);

% create a symmetric frequency base
if nargout<=2
  varargout={X,df};
else
  hi_freq_sample_index=ceil(N_fft/2);
  f_pos=df*linspace(0,hi_freq_sample_index-1,hi_freq_sample_index)';
  f_neg=df*linspace(-(N_fft-hi_freq_sample_index),...
                    -1,...
                    N_fft-hi_freq_sample_index)';
  f=[f_neg ; f_pos ];
  varargout={X,df,f};
end
