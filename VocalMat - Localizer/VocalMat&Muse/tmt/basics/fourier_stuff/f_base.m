function f = f(dt,N)

T=dt*N;
df=1/T;

hi_freq_sample_index=ceil(N/2);
f_pos=df*linspace(0,hi_freq_sample_index-1,hi_freq_sample_index)';
f_neg=df*linspace(-(N-hi_freq_sample_index),...
                  -1,...
                  N-hi_freq_sample_index)';
f=[f_pos ; f_neg];
