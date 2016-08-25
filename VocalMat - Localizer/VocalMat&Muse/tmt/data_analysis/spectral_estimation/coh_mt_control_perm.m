function C_mag_thresh=coh_mt_control_perm(dt,x,y,...
                                          NW,K,f_max,...
                                          p_FFT_extra,...
                                          alpha_thresh)
                                       
% get dims
N=size(x,1);  % number of time points
R=size(x,2);  % number of samples of the signals

% figure out number of perms to do
N_passes=ceil(100/alpha_thresh)

% do the perms
for j=1:N_passes
  fprintf(1,'.');  if mod(j,50)==0 fprintf(1,'\n'); end
  x_shuffled=zeros(size(x));
  for k=1:R
    perm=randperm(N);
    x_shuffled(:,k)=x(perm,k);
  end
%   figure;
%   plot(x_shuffled(:,1));
  [f,C_mag_sample_this]=...
    coh_mt(dt,x_shuffled,y,NW,K,f_max,p_FFT_extra);
  if j==1
    n_f=length(C_mag_sample_this);
    C_mag_sample=nan(n_f,N_passes);
  end
  C_mag_sample(:,j)=C_mag_sample_this;
end
if mod(j,50)~=0 fprintf(1,'\n'); end

% compute the significance threshold
C_mag_sample_sorted=sort(C_mag_sample,2);
P_line=linspace(0,1,N_passes);
C_mag_thresh=interp1(P_line',...
                     C_mag_sample_sorted',...
                     1-alpha_thresh,...
                     'linear')';
