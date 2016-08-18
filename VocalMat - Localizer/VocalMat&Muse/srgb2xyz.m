function rXYZ = f(sRGB)

% sRGB triples should be in cols

% convert the (nonlinear) sRGB triples to linear RGB triples
RGB=gamma_srgb(sRGB);
% convert the RGB triples into (relative) XYZ triples
M=[0.412453 0.357580 0.180423;
   0.212671 0.715160 0.072169;
   0.019334 0.119193 0.950227];
rXYZ=RGB*M';

