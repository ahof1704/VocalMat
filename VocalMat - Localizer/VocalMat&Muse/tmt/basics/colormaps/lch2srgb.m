function srgb = f(lch)

srgb=xyz2srgb(lab2xyz(lch2lab(lch)));
