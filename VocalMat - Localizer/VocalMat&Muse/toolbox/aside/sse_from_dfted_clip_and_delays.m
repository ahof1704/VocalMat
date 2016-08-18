function [sse,a]=sse_from_dfted_clip_and_delays(V,dt,tau_at_point,~)

% V is N x n_mikes
% dt is a scalar
% sigma_v is a scalar
% tau_at_point is n_mikes x n_pts, and tau_at_point(:,i) is the i'th delay 
% vectors at which chi2 is to be computed

% get dimensions
[N,K]=size(V);  % K the number of mics

% make 1d "grids"
phi=phi_base(N);

% estimate the gains
V_ss_per_mike=sum(abs(V).^2,1);  % 1 x K, sum of squares
a=sqrt(V_ss_per_mike)/N;  % volts, gain estimate, proportional to RMS amp (in time domain)
A2=(a*a');  % volts^2

% this is going to be sloooow
[~,n_pts]=size(tau_at_point);
sse_per_mike=zeros(n_pts,K);
tic
for i_pt=1:n_pts
  tau=(tau_at_point(:,i_pt))';  % row vector
  V_advanced=V.*exp(1i*2*pi*phi*tau/dt);  % V, N x K
  X_source_est=sum(bsxfun(@times,a,V_advanced),2)/A2;  % pure, N x 1
  V_advanced_est=X_source_est*a;  % V, N x K
  e=V_advanced_est-V_advanced;  % V, N x K
  sse_per_mike(i_pt,:)=sum(abs(e).^2,1);  % V^2, 1 x K
    % error in freq domain, equal to sse_in_time_domain*N
end
toc

% sum sse over mikes to get final sse for each point
sse=sum(sse_per_mike,2);  % V^2, n_pts x 1

end
 