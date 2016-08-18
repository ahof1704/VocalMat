function [rsrp,rsrp_per_pair]= ...
  rsrp_from_xcorr_raw_and_delta_tau(xcorr_raw_all,tau_line,tau_diff)

% Calculates sum of the upper cross terms in the formula for steered 
% response power (SRP) for a set of time shifts in dt_arr.
%
% xcorr_raw_all is N x n_pairs, and contains the raw cross-correlation
%         between a pair of signals.  Note that this is unnormalized.
% tau_line is N x 1, and gives the time lag (in s) for each row of xcorr_raw_all
% tau_diff is n_pairs x n_r, and gives the predicted relative time lag for 
%        each pair of signals, in s.  n_r is an arbitrary number.  These
%        lags are used to interpolate into tau_line to get values of xcorr_raw_all at
%        a particular set of lags.
%
% RSRP, on return, is 1 x n_r, and gives the sum of
% the upper cross terms in the steered response power.  The SRP is a sum
% across all pairs of signals, including self-pairs.  The return value of
% this function excludes the self pairs, and only includes one of (i,j) and
% (j,i) (hence the "upper").  We're using the definition of the SRP given
% in:
%
% Zhang C, Florencio S, Ba D, Zhang Z (2007) Maximum likelihood sounds
% source localization and beamforming for directional microphone arrays in
% distributed meetings.  If a particular position leads to delayed signals
% x(n,k), where n indexes time points and k indexes signals, the SRP is:
%
%   SRP = sum sum sum x(n,i)*x(n,j)
%          i   j   n
%
% So here we're computing
%
%      sum sum sum x(n,i)*x(n,j)
%       i  j>i  n
%
% we do this fast by interpolating into the pre-computed values in
% xcorr_raw_all

[n_pairs,n_r]=size(tau_diff);
tau0=tau_line(1);
dtau=(tau_line(end)-tau0)/(length(tau_line)-1);
rsrp_per_pair=zeros(n_r,n_pairs);
for i=1:n_r
  for j=1:n_pairs
    k_real=(tau_diff(j,i)-tau0)/dtau+1;
    k_lo=floor(k_real);  
    k_hi=k_lo+1;
    w_hi=k_real-k_lo;
    rsrp_per_pair(i,j)= ...
      (1-w_hi)*xcorr_raw_all(k_lo,j)+w_hi*xcorr_raw_all(k_hi,j);
  end
end
rsrp=sum(rsrp_per_pair,2);  % sum across pairs

end
