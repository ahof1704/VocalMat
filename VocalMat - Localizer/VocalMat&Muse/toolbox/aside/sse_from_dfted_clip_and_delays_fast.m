function [sse,a]=sse_from_dfted_clip_and_delays_fast(V,dt,tau,verbosity)

% V_clip is N x K, K the number of mikes
% tau is K x n_pts, and tau(:,i) is the i'th delay 
%        vector at which SSE is to be computed

% compute delta_tau from tau
% Specify the mixing matrix  
% First time difference is between mikes 1 and 2, with the sign 
% convention that a positive dt means that the sound arrived at mike 1
% _after_ mike 2, therefore travel time to mike 1 is greater than travel
% time to mike 2.  Generally, a positive dt means the sound arrived at the
% lower-numbered mike _after_ the higher-numbered mike.
[N,K]=size(V);  
M=mixing_matrix_from_n_mics(K);
% M=[ 1 -1  0  0 ; ...
%     1  0 -1  0 ; ... 
%     1  0  0 -1 ; ...
%     0  1 -1  0 ; ...
%     0  1  0 -1 ; ...
%     0  0  1 -1 ];
tau_diff=M*tau;

% estimate gain for each mic
V_ss_per_mike=sum(abs(V).^2,1);  % 1 x K, sum of squares
a=sqrt(V_ss_per_mike)/N;  % volts, gain estimate, proportional to RMS amp (in time domain)
A=(a*a');  % volts^2

% calculate the unnormalized cross-correlation between all mic pairs
[xcorr_raw,tau_line]=xcorr_raw_from_dfted_clip(V,dt,a,M,verbosity);

% calculate the reduced steered response power for each time difference
% vector
rsrp=rsrp_from_xcorr_raw_and_delta_tau(xcorr_raw,tau_line,tau_diff);

% convert the RSRPs to SSEs
sse=sse_from_rsrp(rsrp,V_ss_per_mike,N,a);

end
