function [x2, n, b] = compute_xpdf(x)
x2 = reshape(x, 1, prod(size(x)));
[n, b] = hist(x2, 40);
% This is definitely not probability density function
x2 = sort(x2);
% downsampling to speed up computations
% x2 = interp1 (1:length(x2), x2, 1:1000:length(x2));
end