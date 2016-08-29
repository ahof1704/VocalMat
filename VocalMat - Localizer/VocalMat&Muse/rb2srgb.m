function srgb = f(rb)

% rb is nx2, with sRGB red-blue pairs in the rows

% this is the RGB-to-XYZ matrix
M=[0.412453 0.357580 0.180423;
   0.212671 0.715160 0.072169;
   0.019334 0.119193 0.950227];

% convert the rb path to an sRGB path
Y=l2y(75);
RB=gamma_srgb(rb);
g=ungamma_srgb( ( Y-M(2,1)*RB(:,1)-M(2,3)*RB(:,2) ) / M(2,2) );
srgb=[rb(:,1) g rb(:,2)];

