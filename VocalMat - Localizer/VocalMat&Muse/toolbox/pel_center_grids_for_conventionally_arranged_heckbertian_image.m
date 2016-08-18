function [x_grid,y_grid]=pel_center_grids_for_conventionally_arranged_heckbertian_image(im,real_units_per_pel)

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
% Given all this, on return x_grid is a matrix holding the x-coord of the
% center of each pixel, so that the x-coord of the center of im(i,j) is
% given by x_grid(i,j).  Similarly, y_grid is a matrix holding the y-coord
% of the center of each pixel.

[n_rows,n_cols]=size(im);
[x_row,y_col]=pel_centers_for_conventionally_arranged_heckbertian_image(im,real_units_per_pel);
x_grid=repmat(x_row,[n_cols 1]);
y_grid=repmat(y_col,[1 n_rows]);

end
