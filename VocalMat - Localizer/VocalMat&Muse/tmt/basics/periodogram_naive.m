function [freq,psd] = f(t,x)

% t should be a vector, x a vector or matrix
% elements of t should be evenly spaced and increasing
% if x is a matrix, it should have the same number of rows as t has elements,
% and the ffts are done on each column of x separately, consistent with the
% MATLAB conventions
%
% in the canonical case, t is a column vector, and x is a matrix with
% the individual signals in the columns
% we convert to this case, and then convert back at the end:
% if t is a row vector, we want freq to be one, also
% if x is a row vector, we want y to be one, also
%
% we assume that x is real, and return the one-side periodogram

% convert a row vector inputs to col vectors
t_is_row_vector=(size(t,1)==1);
if (t_is_row_vector)
  t=t';
end  
x_is_row_vector=(size(x,1)==1);
if (x_is_row_vector)
  x=x';
end  

%
% the 'meat' of the routine
%

% get the timing info, calc various scalars of interest
n_samples=size(x,1);
n_signals=size(x,2);
dt=(t(n_samples)-t(1))/(n_samples-1);
fs=1/dt;
% Note: It is very important, in this context, that the period, T, be
% defined as dt*n_samples, rather than the arguably more inuitive
% dt*(n_samples-1).  This is because the DFT corresponds to the
% continuous-time case where the discrete, finite signal corresponds to
% samples from a single period of the continuous, infinite signal.  If you
% concatenate an infinite number of the discrete signals to form the
% sampled CT signal, the period of this signal will be dt*n_samples, _not_
% dt*(n_samples-1);
T=dt*n_samples;
df=1/T;

% Do the fft, adding a correction factor to normalize it the usual way for a
% periodogram
X=fft(x);
psd=X.*conj(X)/n_samples/fs;

% fold the positive and negative frequencies together
% hpfi = 'highest positive frequency index'
hpfi=ceil(n_samples/2);
if mod(n_samples,2)==1
  psd=psd(1:hpfi,:)+...
      [zeros(1,n_signals) ; ...
       flipud(psd(hpfi+1:n_samples,:))];
else
  psd=[psd(1:hpfi,:) ; zeros(1,n_signals)]+...
      [zeros(1,n_signals) ; flipud(psd(hpfi+1:n_samples,:)) ];
end  
freq=df*(0:(size(psd,1)-1))';

% if inputs were row vectors, make outputs row vectors    
if (t_is_row_vector)
  freq=freq';
end
if (x_is_row_vector)
  y=y';
end






