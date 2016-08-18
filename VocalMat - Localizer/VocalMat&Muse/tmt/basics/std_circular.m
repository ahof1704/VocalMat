function sigma_hat=std_circular(theta,flag,i_dim)

% this estimates the circular variance, using the formulation where it
% approaches the 'linear' variance for a set of angles with small
% dispersion.  Then it takes the square root of that.
% The flag argument works the same as the flag argument for std().  Use
% flag==0 or flag=[], or omit the arg, to get the estimate of
% circular variance that approaches the unbiased estiamte of variance for
% sets of angles with small dispersion.

if nargin<2 || isempty(flag)
  flag=0;
end
if nargin<3
  i_dim=1;
end

n=size(theta,i_dim);
x=cos(theta);
y=sin(theta);
X_bar=mean(x,i_dim);
Y_bar=mean(y,i_dim);
%mu_hat=atan2(Y_bar,X_bar);  % estimate of circular mean
r=hypot(X_bar,Y_bar);  % the "resultant"
if flag==0
  prefactor=n/(n-1);  % unbiased estimate
elseif flag==1 
  prefactor=1;  % max likelihood estimate
else
  error('flag argument must be 0, 1, or []');
end
sigma2_hat=prefactor*2*(1-r);
% The above can be shown to be equal to
%   sigma2_hat=prefactor*2*sum(1-cos(theta-mu_hat_repped),i_dim)/n;
% I did this on 2012/02/23
sigma_hat=sqrt(sigma2_hat);
