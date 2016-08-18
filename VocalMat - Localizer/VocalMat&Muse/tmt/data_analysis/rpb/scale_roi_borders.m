function border_scaled=scale_roi_borders(border,factor)

% Takes a set of ROI borders and scales them by factor.  E.g. if you have
% ROIs made for a 256x256 image, you might scale them by a factor of 2 to
% work with a 512x512 image.  Subjects each vertex to the transform:
%   x_scaled=factor*(x-0.5)+0.5
%   y_scaled=factor*(y-0.5)+0.5
%
% border a cell array, each el a vertex list, 2 x n,
% border_scaled the same.

border_scaled=cell(size(border));
n_border=length(border);
for i=1:n_border
  vl=border{i};
  vl_scaled=bsxfun(@plus,factor*bsxfun(@minus,vl,[0.5;0.5]),[0.5;0.5]);
  border_scaled{i}=vl_scaled;
end

end
