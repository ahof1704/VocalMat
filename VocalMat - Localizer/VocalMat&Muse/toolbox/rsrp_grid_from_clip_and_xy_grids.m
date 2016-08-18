function [rsrp_grid,a,vel,N_filt,V_filt,V,rsrp_per_pair_grid]= ...
  rsrp_grid_from_clip_and_xy_grids(v,fs, ...
                                   f_lo,f_hi, ...
                                   Temp, ...
                                   x_grid,y_grid, ...
                                   R, ...
                                   verbosity)

% colors for microphones
clr_mike=[1 0 0 ; ...
          0 0.7 0 ; ...
          0 0 1 ; ...
          0 0.8 0.8 ];

% get dimensions                                
dt=1/fs;  % s
[N,K]=size(v);  % N number of time points, K number of mikes

% plot the clips
if (verbosity>=1)
  t=dt*(0:(N-1))';
  figure('color','w');
  for k=1:K
    subplot(K,1,k);
    plot(1000*t,1000*v(:,k),'color',clr_mike(k,:));
    ylim(ylim_tight(1000*v(:,k)));
    ylabel(sprintf('Mic %d (mV)',k));
  end
  xlabel('Time (ms)');
  ylim_all_same();
  tl(0,1000*t(end));
  drawnow;
end

% Specify the mixing matrix  
% First time difference is between mikes 1 and 2, with the sign 
% convention that a positive dt means that the sound arrived at mike 1
% _after_ mike 2, therefore travel time to mike 1 is greater than travel
% time to mike 2.  Generally, a positive dt means the sound arrived at the
% lower-numbered mike _after_ the higher-numbered mike.
% M=mixing_matrix_from_n_mics(K);

% Go to freq domain
V=fft(v);

% filter the signals in the freq domain
f=fft_base(N,1/(dt*N));
keep=(f_lo<=abs(f))&(abs(f)<f_hi);
V_filt=V;
V_filt(~keep,:)=0;
N_filt=sum(keep);  % this is the effective N for statistical purposes
%tau=fftshift(fft_base(n_t,dt));  % want large neg times first
%v_filt=real(ifft(V_filt));

% % estimate how much of the variance in the signal is signal, how much is
% % noise
% sigma=0.02;  % V, the RMS amplitude of a "silent" signal, in the time domain
% sigma2=sigma^2;
% Sigma2=N*sigma2;  % the MS noise level in the freq domain (a _scalar_)
% Sigma2_filt=mean(keep)*Sigma2;  % the MS noise level in the freq domain 
%                                 % after filtering, assuming the noise is white
% P_sn=mean(abs(V_filt.^2),1);  % MS power of the signal+noise, 1 x K
% P_signal=P_sn-Sigma2_filt;  % estimate of signal power in freq domain, 1 x K
% A_signal=sqrt(P_signal);  % estimate of signal amplitude in freq domain, 1 x K

% get the speed of sound, given the temperature
vel=velocity_sound(Temp);  % m/s

% compute the tau vector (delay per mike) and the delta_tau vector
% (relative delay per pair) for each point in the grid
[n_x,n_y]=size(x_grid);
n_r=n_x*n_y;
r_scan=zeros(3,1,n_r);
r_scan(1,:,:)=x_grid(:);
r_scan(2,:,:)=y_grid(:);
% z coords stay zero
rsubR=bsxfun(@minus,r_scan,R);  % 3 x n_mike x n_r, pos rel to each mike
d=reshape(sqrt(sum(rsubR.^2,1)),[K n_r]);  % m, 1 x n_mike x n_r
tau=(1/vel)*d;  % predicted time delays, s, n_mike x n_r
%delta_tau=M*tau;  % TDOA for each pair, s, n_pair x n_r

% compute the sum-of-squared-error at each grid point
[rsrp,a,rsrp_per_pair]=rsrp_from_dfted_clip_and_delays_fast(V_filt,dt,tau,verbosity);

% % check just at the min
% [mse_min,i_argmin]=min(mse);
% tau_argmin=tau(:,i_argmin);
% [mse_min_check,a_check]= ...
%   mse_from_dfted_clip_and_delays(V_filt,dt,tau_argmin,verbosity);
% a
% a_check
% mse_min
% mse_min_check

% rearrange into grid
rsrp_grid=reshape(rsrp,[n_x n_y]);
n_pairs=size(rsrp_per_pair,2);
rsrp_per_pair_grid=reshape(rsrp_per_pair,[n_x n_y n_pairs]);

end
