These are colormaps I created that are more perceptually smooth than the
built-in ones.

As of today, I like spectrum_smooth(n) for scalar quantities, and
oppo(n) for circular quantities.


Scalar colormaps:

spectrum_smooth(n)      Goes from sRGB blue to cyan to green to yellow
                        to red, but with perceptual smoothing.  Nice.

bspectrumw_smooth(n)    Goes from sRGB black to blue to cyan to green to
                        yellow to red to white, but with perceptual
                        smoothing.  Not bad, but I like
                        spectrum_smooth() better.  Tacking black and
                        white on the ends seems a little unnatural.


Circular colormaps:

oppo(n)          Perceptually uniform spacings between sRGB red, blue,
                 yellow, and green, with green at 0 deg, blue at 90 deg,
                 red at 180 deg, and yellow at 270 deg.  I like this a
                 lot.

hsv_smooth(n)    The MATLAB hsv() colormap, but rescaled to be more
                 perceptually uniform.

hv_smooth(n)     This is like hsv_smooth(), but without varying the
                 saturation.  Looks like crap.

l75_border(n)    Take the perimeter of all the colors with luminance 75
                 that are in the sRGB gamut.  Then vary the spacing to
                 maximize perceptual uniformity.  You will then have
                 this colormap.  (The L=75 plane is used because it's
                 one that's bright, but also offers a good range of
                 colors.  Lower L values start to look murky, and higher
                 ones look washed-out.  This colormap isn't bad, but it
                 still looks a little washed out.  Also, the fact that
                 everything is isoluminant makes all the colors look a
                 little too similar.

l75_cicle(n)     Take the set of colors with luminance 75 that are
                 within the sRGB gamut.  Now, take the largest circle
                 centered on (a,b)=(0,0) that fits within this shape.
                 That's this colormap.  Way too washed out.

l75_rounded(n)   Like l75_border(), but with the perimeter rounded off,
                 so the spacing can be more uniform.  Suffers from the
                 same problems as l75_border().

