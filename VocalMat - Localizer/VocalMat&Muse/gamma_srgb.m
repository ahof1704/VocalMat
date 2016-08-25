function RGB = f(sRGB)

% convert the (nonlinear) sRGB values to linear RGB values
low=(sRGB<=0.03928);
high=~low;
RGB=zeros(size(sRGB));
RGB(low)=sRGB(low)./12.92;
RGB(high)=((sRGB(high)+0.055)./1.055).^2.4;

