function clr=f(x)

% x is a col vector, on [0,1]

n=length(x);
lch0=srgb2lch([0 0 1]);
lch1=srgb2lch([1 0 0]);
lch1(3)=lch1(3)-2*pi;
clr_lch=x*lch1+(1-x)*lch0;
clr=lch2srgb(clr_lch);
clr=min(clr,1);
clr=max(clr,0);
