function [mu,S] = weighted_mean_cov(x,w)

[n,d] = size(x);

z = sum(w);
mu = sum(x.*repmat(w,1,d),1)/z;

diffs = x - repmat(mu,[n,1]);
diffs = diffs.*repmat(sqrt(w),[1,d]);
S = (diffs'*diffs)/z;
