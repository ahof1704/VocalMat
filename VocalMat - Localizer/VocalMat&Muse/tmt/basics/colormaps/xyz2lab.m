function rLab = f(rXYZ)

% converts from (relative) XYZ to (relative) Lab

% I got this code from
%   http://www.easyrgb.com/
% L* is on [0,100]
% a* is on [-500,+500]
% b* is on [-200,+200]

% the (relative) XYZ triples should be in the cols of rXYZ

% divide out the rXYZ value of 'white'
% this white doesn't _necessarily_ have to be the same as the
% sRGB white point, it's just the point we choose to designate as
% having no chromatic component.  Of course, we just use the sRGB
% white point, which is the D65 white point.
rXYZ_white=[0.9505 1 1.0890];
rXYZ_normed=rXYZ./repmat(rXYZ_white,[size(rXYZ,1) 1]);

% do the luminance-type-thing to lightness-type-thing mapping
low=(rXYZ_normed<=0.008856);
high=~low;
rXYZ_lightness=zeros(size(rXYZ_normed));
rXYZ_lightness(low)=7.787*rXYZ_normed(low)+16/116;
rXYZ_lightness(high)=rXYZ_normed(high).^(1/3);

% Now do the relative scaling of the components
rLab=[116*rXYZ_lightness(:,2)-16 ...
      500*(rXYZ_lightness(:,1)-rXYZ_lightness(:,2)) ...
      200*(rXYZ_lightness(:,2)-rXYZ_lightness(:,3))];
