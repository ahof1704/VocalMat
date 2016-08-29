function in_gamut=f(lab)

srgb=lab2srgb(lab);
elements_in_gamut=(srgb>=0)&(srgb<=1);
in_gamut=all(elements_in_gamut,2);
