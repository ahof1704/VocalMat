function phi = phi_base(N)

% Generates a frequency line to go with an N-point fft.  Frequencies are in
% cycles per sample, i.e. they go from about -1/2 to about 1/2.

dphi=1/N;

hi_freq_sample_index=ceil(N/2);
phi_pos=dphi*linspace(0,hi_freq_sample_index-1,hi_freq_sample_index)';
phi_neg=dphi*linspace(-(N-hi_freq_sample_index),...
                      -1,...
                      N-hi_freq_sample_index)';
phi=[phi_pos ; phi_neg];

end
