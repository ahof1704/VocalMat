function C_mag_thresh=coh_mt_control_analytical(R,K,alpha)

% R the number of observations of the two signals together,
%   where each "observation" consists of N samples of each signal,
%   acquired simultaneously
% K the number of tapers
% alpha the per-comparison Type 1 error rate of the test

dof=2*R*K;  % degrees of freedom
C_mag_thresh=sqrt(1-alpha^(1/(dof/2-1)));
