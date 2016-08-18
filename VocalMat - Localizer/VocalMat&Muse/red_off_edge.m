function color_map=f(L,x)

% L is a scalar, x is a row vector

% this is the RGB-to-XYZ matrix
M=[0.412453 0.357580 0.180423;
   0.212671 0.715160 0.072169;
   0.019334 0.119193 0.950227];

% this is the code
n_samples=length(x);
Y=l2y(L);
r=repmat(0,[1 n_samples])';
g=ungamma_srgb( (Y-M(2,3)*gamma_srgb(x)) / M(2,2) );
b=x;
color_map=[r g b];

