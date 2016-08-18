function [xd,yd]=xdata_ydata_for_conventionally_arranged_heckbertian_image(im,real_units_per_pel)

% Assumes that im is an image, laid out in the conventional way: Each row a
% horizontal line, each col a vertical line, with col index increasing to
% the right, and row index increasing as you move down the image.
%
% Further, assumes that the lower-left corner of the lower left pixel is at
% Cartesian coordinates (0,0), and the upper right corner of the upper
% right pixel is at Cartesian coordinates
% (meters_per_pixel*n_cols,meters_per_pixel*n_rows).  (N.B.: This is a
% traditional Cartesian coord system, with y increasing as you go up.)
%
% Given all this, on return xl(1) is the x-coord of the pixel centers for the
% left-most column of pixels.  xl(2) is the x-coord of the pixel centers
% for the right-most column of pixels.  yl(1) is the y-coord of the pixel
% centers of the bottom-most row of pixels, and yl(2) is the y-coord of the
% pixel centers of the top-most row of pixels.
%
% The intended usage is that if you have an image, and you want to plot it
% in a conventional Cartesian coordinate system with the lower-left corner
% of the image at the origin, this function will figure out the 'xlim' and
% 'ylim' properties to pass to the low-level "method" of the image()
% function.
%
% Example usage:
%   [xd,yd]=xdata_ydata_for_conventionally_arranged_heckbertian_image(im,meters_per_pixel);
%   image('parent', axes_h, ...
%         'xdata',xd, ...
%         'ydata',yd, ...
%         'cdata',im);

[n_rows,n_cols]=size(im);
xd=real_units_per_pel*[0.5 n_cols-0.5];
yd=real_units_per_pel*[n_rows-0.5 0.5];  
  % this is biggest first so that the image gets flipped vertically

end
