function x = fft_base(N,dx)

% Generates a frequency line to go with an N-point fft.  Frequencies are in
% cycles per sample, i.e. they go from about -1/2 to about 1/2.

hi_x_sample_index=ceil(N/2);
x_pos=dx*linspace(0,hi_x_sample_index-1,hi_x_sample_index)';
x_neg=dx*linspace(-(N-hi_x_sample_index),...
                  -1,...
                  N-hi_x_sample_index)';
x=[x_pos ; x_neg];

end
