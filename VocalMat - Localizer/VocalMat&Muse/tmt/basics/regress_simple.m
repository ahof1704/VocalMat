function [bm_hat,bm_hat_se,bm_pval,sigma_hat_bm,R2_bm] = f(x,y)

% function to do a linear fit to (x,y) data, and to calculate standard
% errors on the parameter estimates, and to calculate p-values under the 
% null hypothesis that the parameter is zero
%
% all these formulae are from chapter 14, section 2 of Rice
%
% x and y can be col vectors or matrices with the different data sets in
%   the cols
% if input is a vector, most of the outputs are scalars, 
%   the others are col vectors
% if inputs are matrices, the outputs have values for the jth col in the
%   jth col

% get dims
n=size(x,1);
m=max(size(x,2),size(y,2));

% repmat either input so they're the same size
if size(x,2)==1
  x=repmat(x,[1 m]);
end
if size(y,2)==1
  y=repmat(y,[1 m]);
end

% quantities that will be useful later
x_sum=sum(x);
x2_sum=sum(x.^2);
x_bar=x_sum/n;
xc=x-repmat(x_bar,[n 1]);
xc2_sum=sum(xc.^2);
sigma2_x_hat=xc2_sum/(n-1);
sigma_x_hat=sqrt(sigma2_x_hat);
y_sum=sum(y);
y2_sum=sum(y.^2);
y_bar=y_sum/n;
yc=y-repmat(y_bar,[n 1]);
yc2_sum=sum(yc.^2);
sigma2_y_hat=yc2_sum/(n-1);
sigma_y_hat=sqrt(sigma2_y_hat);
xy_sum=sum(x.*y);
xcyc_sum=sum(xc.*yc);

% y=m*x+b estimates
m_hat=xcyc_sum./xc2_sum;
b_hat=y_bar-m_hat.*x_bar;
y_hat=(repmat(b_hat,[n 1])+repmat(m_hat,[n 1]).*x);
sse_bm=sum((y-y_hat).^2);
s2=sse_bm/(n-2);  % estimate of sigma^2, the (uniform) noise variance
sigma_hat_bm=sqrt(s2);
common=s2./(n*x2_sum-x_sum.^2);
b_hat_var=x2_sum.*common;
m_hat_var=n*common;
b_hat_se=sqrt(b_hat_var);
m_hat_se=sqrt(m_hat_var);
bm_hat=[b_hat;m_hat];
bm_hat_se=[b_hat_se;m_hat_se];
R2_bm=1-sse_bm./yc2_sum;
t_b=b_hat./b_hat_se;
t_m=m_hat./m_hat_se;
b_pval=2*tcdf(-abs(t_b),n-2);
m_pval=2*tcdf(-abs(t_m),n-2);
bm_pval=[b_pval;m_pval];
