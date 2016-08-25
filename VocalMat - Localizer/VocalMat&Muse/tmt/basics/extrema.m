function extrema_array=f(y,sigma_filter)

% y should be a col vector
% output is +1 at maxima (of the filtered signal), -1 at minima, and 0 otherwise

n=length(y);
if sigma_filter>0
  k=gaussian_kernel_1d(sigma_filter,ceil(6*sigma_filter));
  y_filt=conv1(y,k,'same');
else
  y_filt=y;
end
y_diff_sign=sign(diff(y_filt));
extrema_array=[0;-sign(diff(sign(diff(y_filt))));0];
