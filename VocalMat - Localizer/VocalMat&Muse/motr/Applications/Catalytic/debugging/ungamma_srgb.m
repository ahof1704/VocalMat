function sRGB = f(RGB)

% this gamma-corrects the linear RGB values, thus converting them to
% (nonlinear) sRGB
low=(RGB<=0.00304);
high=~low;
sRGB=zeros(size(RGB));
sRGB(low)=12.92*RGB(low);
sRGB(high)=1.055*RGB(high).^(1/2.4)-0.055;
