function ylims = f(y)
  
y_max=max(y(:));
y_min=min(y(:));
y_mid=(y_max+y_min)/2;
y_radius=(y_max-y_min)/2;
y_max_lim=y_mid+1.1*y_radius;
y_min_lim=y_mid-1.1*y_radius;
if y_max_lim <= y_min_lim
  epsilon=1e-6;
  y_max_lim=(y_max_lim+y_min_lim)/2+epsilon;
  y_min_lim=y_max_lim-2*epsilon;
end
ylims=[y_min_lim y_max_lim];
