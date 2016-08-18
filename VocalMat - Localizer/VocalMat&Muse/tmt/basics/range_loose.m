function yl=f(y,factor)

if nargin<2
  factor=1.1;
end
y_min=min(min(y));
y_max=max(max(y));
y_mid=(y_max+y_min)/2;
y_rad=(y_max-y_min)/2;
if y_rad==0
  y_rad=1;
end
y_lo=y_mid-factor*y_rad;
y_hi=y_mid+factor*y_rad;
yl=[y_lo y_hi];
