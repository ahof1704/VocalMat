function [x_row,y_col]=pel_centers_for_conventionally_arranged_heckbertian_image(im,real_units_per_pel)

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
% Given all this, on return x_row is a col vector holding the x-coord of
% the center of each pixel column.  These are arranged in increasing order,
% so that the x-coord of the center of im(:,j) is given by x_row(j).  y_col
% is a col vector holding the y-coord of the center of each pixel row.
% These are arranged in decreasing order, so that the y-coord of the center
% of im(i,:) is given by y_col(i).

[n_rows,n_cols]=size(im);
x_row=real_units_per_pel*((0:(n_cols-1))+0.5);
y_col=real_units_per_pel*(flipud((0:(n_rows-1))')+0.5);

end
