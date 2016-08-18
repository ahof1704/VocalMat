function clr=spindle_of_x(x)

%  x is a col vector, on [0,1]

x=1/5+4/5*x;  % re-scale to avoid black

%width=50;  % good value
width=75;  % better value
L=100*x;
hue=2*pi*x-3;  % radians, starts at blue
chroma=width*4*x.*(1-x);
  % this is not real Lch, but is isomorphic to it

a=chroma.*cos(hue);
b=chroma.*sin(hue);

clr=min(max(0,lab2srgb([L a b])),1);

end
