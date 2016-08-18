function sRGB = f(rXYZ)

% conversion from (relative) CIE XYZ to sRGB
% in-gamut sRGB values are reals on [0,1]
% got this code from http://www.w3.org/Graphics/Color/sRGB.html

% the cols of rXYZ should hold the (relative) XYZ triples

% This converts from relative XYZ to (linear) RGB
M=[ 3.240479 -1.537150 -0.498535;
   -0.969256  1.875992  0.041556;
    0.055648 -0.204043  1.057311];
RGB=rXYZ*M';
% this gamma-corrects the linear RGB values, thus converting them to
% (nonlinear) sRGB
sRGB=ungamma_srgb(RGB);
