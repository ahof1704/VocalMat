function [f,...
          Cyx_mag, Cyx_phase, ...
          N_fft, f_res_diam, K, ...
          Cyx_mag_ci, Cyx_phase_ci, ...
          Cyx_mag_xf, Cyx_mag_xf_sigma, Cyx_mag_xf_ci,...
          Cyx_phase_sigma]=...
  coh_mt(dt,y,x,...
         nw,K,W_keep,...
         p_FFT_extra,conf_level)

% [f,Cyx_mag,Cyx_phase] = coh_mt(dt,y,x,nw) calculates the direct
% multitaper spectral estimate of the coherency between output signal y
% and input signal x, assuming an inter-sample spacing of dt seconds,
% with time-bandwidth product nw.  f gives the frequency base (in Hz)
% for the estimate, Cyx_mag gives the magnitude of the coherency at each
% frequency, and Cyx_phase gives the phase angle of the coherency at
% each frequency (in radians).  Which signal is x and which is y doesn't
% affect the coherency magnitude, and only affects the sign of the
% coherency phase.  The convention is that if y lags x at a given
% frequency (e.g. if y is the result of putting x though a causal
% filter, perhaps with noise added) the coherency phase will be
% negative.  The coherency phase returned by coh_mt() is the same as the
% transfer function phase returned by tf_mt() for the same inputs (in
% the same order).
%  
% dt is a scalar
%
% nw is the desired time-bandwidth product.  The frequency resolution is
%   given by nw/(N*dt).  Usually, nw=4 is a good place to start.
% conf_level is the confidence level of computed confidence intervals
% N_fft is the length to which data is zero-padded before FFTing
%
% f is the frequency base, which is one-sided
% the varargouts are the sigmas
%
% this version uses fft(), but does it on one sample, and one taper, at a
% time.  Also, it only stores the output up to frequency W_keep.  These 
% changes make it much more space-efficient that the "standard" multitaper
% code that I wrote.  Also, it's very fast.
%
% this version calculates the autocorrelation, not the autocovariance.
% I.e. we don't subtract off the mean first
%
% this version assumes x and y are of shape [N R], N the number of
% time points, R the number of samples.  If you want to calc
% coherence for more than one pair of signals, call if multiple times

% get the timing info, calc various scalars of interest
N=size(x,1);  % number of time points per process sample
R=size(x,2);  % number of samples of the process
fs=1/dt;

% process args
if nargin<5 || isempty(K)
  K=2*nw-1;
end
if nargin<6 || isempty(W_keep)
  W_keep=fs/2;
end
if nargin<7 || isempty(p_FFT_extra)
  p_FFT_extra=2;
end
if nargin<8 || isempty(conf_level)
  conf_level=0;  % i.e. no confidence intervals
end

% N for FFT
N_fft=2^(ceil(log2(N))+p_FFT_extra);

% compute frequency resolution
f_res_diam=2*nw/(N*dt);

% generate the dpss tapers if necessary
persistent N_memoed nw_memoed K_memoed tapers_memoed;
if isempty(tapers_memoed) || ...
   N_memoed~=N || nw_memoed~=nw || K_memoed~=K
 %fprintf(1,'calcing dpss...\n');
 tapers_memoed=dpss(N,nw,K);
 N_memoed=N;
 nw_memoed=nw;
 K_memoed=K;
end
tapers=tapers_memoed;
tapers=reshape(tapers,[N 1 K]);

% generate the frequency base
% hpfi = 'highest positive frequency index'
hpfi=ceil(N_fft/2);
f=fs*(0:(hpfi-1))'/N_fft;
f=f(f<=W_keep);
N_f=length(f);

% taper and do the FFTs
if N_f*R*K<1e5
  % if dimensions are not too big, do this the easy way
  x_tapered=repmat(tapers,[1 R 1]).*repmat(x,[1 1 K]);
  X=fft(x_tapered,N_fft);
  X=X(1:N_f,:,:);
  y_tapered=repmat(tapers,[1 R 1]).*repmat(y,[1 1 K]);
  Y=fft(y_tapered,N_fft);
  Y=Y(1:N_f,:,:);
else
  % if dimensions are big, do this in a more space-efficient way
  X=zeros([N_f R K]);
  Y=zeros([N_f R K]);
  for r=1:R  % windows
    for k=1:K  % tapers
      x_this_tapered=tapers(:,:,k).*x(:,r);
      X_this=fft(x_this_tapered,N_fft);
      X(:,r,k)=X_this(1:N_f);
      y_this_tapered=tapers(:,:,k).*y(:,r);
      Y_this=fft(y_this_tapered,N_fft);
      Y(:,r,k)=Y_this(1:N_f);
    end
  end
end
% X, Y is of shape [N_f R K]

% % convert to power by squaring, and to a density by dividing by fs
Pxxs=(abs(X).^2);
Pyys=(abs(Y).^2);
Pyxs=(Y.*conj(X));
% we don't bother dividing by fs, since we're going to take
% ratios anyway

% % multiply by 2 (i.e. make into one-sided power spectra)
% Pxxs=2*Pxxs;
% Pyys=2*Pyys;
% Pyxs=2*Pyxs;
% unnecessary, since we're going to take ratios anyway

% _sum_ across samples, tapers (keep these around in case we need to 
% calculate the take-away-one spectra for error bars)
PxxRK=sum(sum(Pxxs,3),2);
PyyRK=sum(sum(Pyys,3),2);
PyxRK=sum(sum(Pyxs,3),2);
% PxxRK, PyyRK, PyxRK is of shape [N_f 1]

% % convert the sum across samples, tapers to an average; these are our 
% % 'overall' spectral estimates
% Pxx=PxxRK/(R*K);
% Pyy=PyyRK/(R*K);
% Pyx=PyxRK/(R*K);
% % Pxx, Pyy, Pyx is of shape [N_f 1]
% % don't need to do this, since we're taking ratios later

% calculate coherence
Cyx=PyxRK./sqrt(PxxRK.*PyyRK);

% separate out magnitude, phase
Cyx_mag=abs(Cyx);
% roundoff error can make Cyx_mag slightly greater than 1, so ceiling
% it, but leave nans alone
notnan=~isnan(Cyx_mag);
Cyx_mag(notnan)=min(Cyx_mag(notnan),1);
Cyx_phase=unwrap(angle(Cyx));

% calc the sigmas
if conf_level>0
  % calculate the transformed coherence magnitude
  Cyx_mag_xf=atanh(Cyx_mag);

  % calculate the take-away-one spectra
  Pxxs_tao=repmat(PxxRK,[1 R K])-Pxxs;
  Pyys_tao=repmat(PyyRK,[1 R K])-Pyys;
  Pyxs_tao=repmat(PyxRK,[1 R K])-Pyxs;
  % don't bother dividing by (R*K-1), since we take ratios below
  
  % calc the take-away-one coherence
  Cyxs_tao=Pyxs_tao./sqrt(Pxxs_tao.*Pyys_tao);

  % transform the take-away-one coherence
  Cyxs_tao_mag=abs(Cyxs_tao);
  Cyxs_tao_mag=max(min(Cyxs_tao_mag,1),0);
  Cyxs_tao_mag_xf=atanh(Cyxs_tao_mag);
  %Cyxs_tao_phase=angle(Cyxs_tao);

  % calculate the coherence magnitude sigma
  Cyxs_tao_mag_xf_mean=mean(mean(Cyxs_tao_mag_xf,3),2);
  Cyx_mag_xf_sigma=...
    sqrt((R*K-1)/(R*K)*...
         sum(sum((Cyxs_tao_mag_xf-...
                  repmat(Cyxs_tao_mag_xf_mean,[1 R K])).^2,3),2));
  infs_in_mix=isinf(Cyx_mag_xf)|any(any(isinf(Cyxs_tao_mag_xf),3),2);
  Cyx_mag_xf_sigma(infs_in_mix)=0;  % special case this

  % calculate the coherence phase sigma
  Cyxs_tao_hat=Cyxs_tao./Cyxs_tao_mag;
  Cyxs_tao_hat_mean=mean(mean(Cyxs_tao_hat,3),2);
  arg_sqrt=max(2*(R*K-1)*(1-abs(Cyxs_tao_hat_mean)),0);
  Cyx_phase_sigma=sqrt(arg_sqrt);

  % calculate the confidence intervals
  ci_factor=tinv((1+conf_level)/2,R*K-1);
  Cyx_mag_xf_ci(:,1)=Cyx_mag_xf-ci_factor*Cyx_mag_xf_sigma;
  Cyx_mag_xf_ci(:,2)=Cyx_mag_xf+ci_factor*Cyx_mag_xf_sigma;
  Cyx_mag_ci=tanh(Cyx_mag_xf_ci);
  Cyx_phase_ci(:,1)=Cyx_phase-ci_factor*Cyx_phase_sigma;
  Cyx_phase_ci(:,2)=Cyx_phase+ci_factor*Cyx_phase_sigma;
else
  % just set these to empty matrix
  Cyx_mag_ci=[];
  Cyx_phase_ci=[];
  Cyx_mag_xf=[]; 
  Cyx_mag_xf_sigma=[];
  Cyx_phase_sigma=[];
end
