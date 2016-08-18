function [f,Pxx,...
          N_fft,f_res_diam,K,...
          Pxx_ci,...
          Pxx_xf,Pxx_xf_sigma,Pxx_xf_ci,...
          Pxxs_tao]=...
  pow_mt(dt,x,...
         NW,K,W_keep,...
         p_FFT_extra,conf_level)

% dt is a scalar

% NW is the desired time-bandwidth product.  The frequency resolution is
%   given by NW/(N*dt).  Usually, NW=4 is a good place to start.
% conf_level is the confidence level of computed confidence intervals
% N_fft is the length to which data is zero-padded before FFTing
%
% f is the frequency base, which is one-sided
% the varargouts are the sigmas

% this version uses fft(), but does it on one sample, and one taper, at a
% time.  Also, it only stores the output up to frequency W_keep.  These 
% changes make it much more space-efficient that the "standard" multitaper
% code that I wrote.  Also, it's very fast.

% this version does not subtract off the mean first
  
% this version assumes x is N x R, where R is the number of samples
% of the process.  If you need power spectra for multiple signals,
% call this function multiple times.

% get the timing info, calc various scalars of interest
N=size(x,1);  % number of time points per process sample
R=size(x,2);  % number of samples of the process
fs=1/dt;

% process args
if nargin<4 || isempty(K)
  K=2*NW-1;
end
if nargin<5 || isempty(W_keep)
  W_keep=fs/2;
end
if nargin<6 || isempty(p_FFT_extra)
  p_FFT_extra=2;
end
if nargin<7 || isempty(conf_level)
  conf_level=0;
end

% N for FFT
N_fft=2^(ceil(log2(N))+p_FFT_extra);

% compute frequency resolution
f_res_diam=2*NW/(N*dt);

% generate the dpss tapers if necessary
persistent N_memoed NW_memoed K_memoed tapers_memoed;
if isempty(tapers_memoed) || ...
   N_memoed~=N || NW_memoed~=NW || K_memoed~=K
  %fprintf(1,'calcing dpss...\n');
  tapers_memoed=dpss(N,NW,K);
  N_memoed=N;
  NW_memoed=NW;
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
else
  % if dimensions are big, do this in a more space-efficient way
  X=zeros([N_f R K]);
  for r=1:R  % windows
    for k=1:K  % tapers
      x_this_tapered=tapers(:,:,k).*x(:,r);
      X_this=fft(x_this_tapered,N_fft);
      X(:,r,k)=X_this(1:N_f);
    end
  end
end
% X is of shape [N_f R K]

% convert to power by squaring, and to a density by dividing by fs
Pxxs=(abs(X).^2)/fs;
% Pxxs is of shape [N_f R K]

% multiply by 2 (i.e. make into one-sided power spectra)
Pxxs=2*Pxxs;

% _sum_ across samples, tapers (keep these around in case we need to 
% calculate the take-away-one spectra for error bars)
PxxRK=sum(sum(Pxxs,3),2);
% PxxRK is of shape [N_f 1]

% convert the sum across samples, tapers to an average; these are our 
% 'overall' spectral estimates
Pxx=PxxRK/(R*K);
% Pxx is of shape [N_f 1]

% calc the sigmas
if conf_level>0
  % calculate the transformed power
  Pxx_xf=log10(Pxx);

  % calculate the take-away-one spectra
  Pxxs_tao=(repmat(PxxRK,[1 R K])-Pxxs)/(R*K-1);
  
  % transform the take-away-one spectra
  Pxxs_tao_xf=log10(Pxxs_tao);

  % calculate the sigmas on the spectra
  Pxxs_tao_xf_mean=mean(mean(Pxxs_tao_xf,3),2);
  Pxx_xf_sigma=...
    sqrt((R*K-1)/(R*K)*...
         sum(sum((Pxxs_tao_xf-...
                  repmat(Pxxs_tao_xf_mean,[1 R K])).^2,3),2));

  % calculate the confidence intervals
  ci_factor=tinv((1+conf_level)/2,R*K-1);
  Pxx_xf_ci(:,1)=Pxx_xf-ci_factor*Pxx_xf_sigma;
  Pxx_xf_ci(:,2)=Pxx_xf+ci_factor*Pxx_xf_sigma;
  Pxx_ci=10.^Pxx_xf_ci;
else
  % just make this stuff empty
  Pxx_ci=[];
  Pxx_xf=[];
  Pxx_xf_sigma=[];
  Pxx_xf_ci=[];
  Pxxs_tao=[];
end
