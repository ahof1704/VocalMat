function freq = f(t)

% convert a row vector input to col vector
t_is_row_vector=(size(t,1)==1);
if (t_is_row_vector)
  t=t';
end  

%
% the 'meat' of the routine
%

% get the timing info, calc various scalars of interest
n_samples=length(t);
t_min=t(1);
t_max=t(n_samples);
time_span=t_max-t_min;
dt=time_span/(n_samples-1);
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

% create an asymmetric frequency base
hi_freq_sample_index=ceil(n_samples/2);
pos_freq=df*(0:(hi_freq_sample_index-1))';
neg_freq=df*((-(n_samples-hi_freq_sample_index)):-1)';
freq=[pos_freq;neg_freq];

% if input is a row vector, make output a row vector    
if (t_is_row_vector)
  freq=freq';
end






