function rXYZ = f(rLab)

% I got this code from
%   http://www.easyrgb.com/
% L* is on [0,100]
% a* is on [-500,+500]
% b* is on [-200,+200]

% the (relative) Lab triples should be in the rows of rLab

% undo the scaling of the Lab components
L_star_rel=(rLab(:,1)+16)/116;  % (relative) 'lightness' in Poynton 
rXYZ_lightness=[L_star_rel+rLab(:,2)/500 ...
                L_star_rel ...
                L_star_rel-rLab(:,3)/200];

% do the lightness to luminance mapping
low=(rXYZ_lightness<=0.206893);
high=~low;
rXYZ_normed=zeros(size(rXYZ_lightness));
rXYZ_normed(low)=(rXYZ_lightness(low)-16/116)/7.787;
rXYZ_normed(high)=rXYZ_lightness(high).^3;

% now factor in the rXYZ value we designate as 'white'
% this white doesn't _necessarily_ have to be the same as the
% sRGB white point, it's just the point we choose to designate as
% having no chromatic component.  Of course, we just use the sRGB
% white point, which is the D65 white point.
rXYZ_white=[0.9505 1 1.0890];
rXYZ=repmat(rXYZ_white,[size(rXYZ_normed,1) 1]).*rXYZ_normed;

% this XYZ will not be in nits.  To get nits, you need to multiply it by the
% luminance of a white pixel (which will be in nits).  Supposedly a typical
% value for this is ~100 nits.
% (This will get the Y into nits, but will the X and Z be in nits
% also?  I'm not sure what exactly that would mean...)
