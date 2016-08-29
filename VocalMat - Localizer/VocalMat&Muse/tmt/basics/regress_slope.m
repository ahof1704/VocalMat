function [b1_hat,s_b1,p_b1] = f(x,y)

% function to do a linear fit to (x,y) data, and to calculate standard
% errors on the parameter estimates, and to calculate p-values under the 
% null hypothesis that the parameter is zero
% this one assumes the y-intercept is zero, and so only fits the slope
%
% all these formulae are from chapter 14, section 2 of Rice

% calc all the building blocks we'll need
n=length(x);
x2_sum=sum(x.^2);
y2_sum=sum(y.^2);
xy_sum=sum(x.*y);

% calc the param estiimates, and the SEs on them
b1_hat=xy_sum/x2_sum;
y_hat=b1_hat*x;
res=y-y_hat;
rss=sum(res.^2);
s2=rss/(n-1);  % estimate of sigma^2, the (uniform) noise variance
s2_b1=s2/x2_sum;

% convert variance estimates to S.D. estimates
s_b1=sqrt(s2_b1);

% t_b1 should be distributed as a Student't t R.V. with n-1 degrees of 
% freedom
t_b1=b1_hat/s_b1;

% prob of drawing something more extreme than the calculated t-statistic, 
% given the null hyp that b1==0
p_b1=2*tcdf(-abs(t_b1),n-1);
