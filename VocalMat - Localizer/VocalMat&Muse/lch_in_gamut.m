function in_gamut=f(lch)

srgb=lch2srgb(lch);
elements_in_gamut=(srgb>=0)&(srgb<=1);
in_gamut=all(elements_in_gamut,2);
