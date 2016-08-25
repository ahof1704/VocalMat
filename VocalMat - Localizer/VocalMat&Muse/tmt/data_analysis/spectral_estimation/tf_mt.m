function [f,...
          Hyx_mag, Hyx_phase, ...
          N_fft, f_res_diam, K, ...
          Hyx_mag_ci, Hyx_phase_ci, ...
          Hyx_mag_xf, Hyx_mag_xf_sigma, ...
          Hyx_phase_sigma]=...
  tf_mt(dt,y,x,...
        nw,K,W_keep,...
        p_FFT_extra,conf_level)

% tf_mt(): Multitaper estimation of the transfer function  
%
% [f,Hyx_mag,Hyx_phase] = tf_mt(dt,y,x,nw) calculates the direct
% multitaper spectral estimate of the transfer function between
% output signal y and input signal x, assuming an inter-sample
% spacing of dt seconds, with time-bandwidth product nw.  f gives the
% frequency base (in Hz) for the estimate, Hyx_mag gives the
% magnitude of the TF at each frequency, and Hyx_phase gives the
% phase angle of the TF at each frequency (in radians).
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
% We don't subtract off the means of the signals
%
% this version assumes x and y are of shape [N R], N the number of
% time points, R the number of samples.  If you want to calc
% coherence for more than one pair of signals, call it multiple times

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
%Pyys=(abs(Y).^2);
Pyxs=(Y.*conj(X));
% don't bother dividing by fs, since we take ratios below

% % multiply by 2 (i.e. make into one-sided power spectra)
% Pxxs=2*Pxxs;
% Pyys=2*Pyys;
% Pyxs=2*Pyxs;

% _sum_ across samples, tapers (keep these around in case we need to 
% calculate the take-away-one spectra for error bars)
PxxRK=sum(sum(Pxxs,3),2);
%PyyRK=sum(sum(Pyys,3),2);
PyxRK=sum(sum(Pyxs,3),2);
% PxxRK, PyyRK, PyxRK is of shape [N_f 1]

% % convert the sum across samples, tapers to an average; these are our 
% % 'overall' spectral estimates
% Pxx=PxxRK/(R*K);
% %Pyy=PyyRK/(R*K);
% Pyx=PyxRK/(R*K);
% % Pxx, Pyy, Pyx is of shape [N_f 1]
% % don't need this, since just take ratios below

% calculate transfer function estimate
Hyx=PyxRK./PxxRK;

% separate out magnitude, phase
Hyx_mag=abs(Hyx);
Hyx_phase=unwrap(angle(Hyx));

% calc the sigmas
if conf_level>0  % i.e. if CIs were requested
  % calculate the transformed TF magnitude
  Hyx_mag_xf=log(Hyx_mag);

  % calculate the take-away-one spectra
  Pxxs_tao=repmat(PxxRK,[1 R K])-Pxxs;
%  Pyys_tao=repmat(PyyRK,[1 R K])-Pyys;
  Pyxs_tao=repmat(PyxRK,[1 R K])-Pyxs;
  % don't need to divide by (R*K-1), since we take ratio below
  
  % calc the take-away-one TFs
  Hyxs_tao=Pyxs_tao./Pxxs_tao;

  % transform the take-away-one TF
  Hyxs_tao_mag=abs(Hyxs_tao);
  Hyxs_tao_mag_xf=log(Hyxs_tao_mag);
  Hyxs_tao_phase=angle(Hyxs_tao);

  % calculate the TF magnitude sigma
  Hyxs_tao_mag_xf_mean=mean(mean(Hyxs_tao_mag_xf,3),2);
  Hyx_mag_xf_sigma=...
    sqrt((R*K-1)/(R*K)*...
         sum(sum((Hyxs_tao_mag_xf-...
                  repmat(Hyxs_tao_mag_xf_mean,[1 R K])).^2,3),2));
  infs_in_mix=isinf(Hyx_mag_xf)|any(any(isinf(Hyxs_tao_mag_xf),3),2);
  Hyx_mag_xf_sigma(infs_in_mix)=0;  % special case this

  % calculate the TF phase sigma
  Hyxs_tao_hat=Hyxs_tao./Hyxs_tao_mag;
  Hyxs_tao_hat_mean=mean(mean(Hyxs_tao_hat,3),2);
  arg_sqrt=max(2*(R*K-1)*(1-abs(Hyxs_tao_hat_mean)),0);
  Hyx_phase_sigma=sqrt(arg_sqrt);

  % calculate the confidence intervals
  ci_factor=tinv((1+conf_level)/2,R*K-1);
  Hyx_mag_ci(:,1)=exp(Hyx_mag_xf-ci_factor*Hyx_mag_xf_sigma);
  Hyx_mag_ci(:,2)=exp(Hyx_mag_xf+ci_factor*Hyx_mag_xf_sigma);
  Hyx_phase_ci(:,1)=Hyx_phase-ci_factor*Hyx_phase_sigma;
  Hyx_phase_ci(:,2)=Hyx_phase+ci_factor*Hyx_phase_sigma;
else
  % if no CIs requested, just set these to empty matrix
  Hyx_mag_ci=[];
  Hyx_phase_ci=[];
  Hyx_mag_xf=[]; 
  Hyx_mag_xf_sigma=[];
  Hyx_phase_sigma=[];
end
