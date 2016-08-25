function mu_hat=mean_circular(theta,i_dim)

if nargin<2
  i_dim=1;
end

x=cos(theta);
y=sin(theta);
X_bar=mean(x,i_dim);
Y_bar=mean(y,i_dim);
mu_hat=atan2(Y_bar,X_bar);
