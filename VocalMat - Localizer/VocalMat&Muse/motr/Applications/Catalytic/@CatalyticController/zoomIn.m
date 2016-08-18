function zoomIn(self,point,anchor)

% replace the point and anchor with min_corner and max_corner
min_corner=[min(point(1),anchor(1)) min(point(2),anchor(2))];
max_corner=[max(point(1),anchor(1)) max(point(2),anchor(2))];

% make sure there aren't zero pels in the rectangle
if ((min_corner(1)<max_corner(1))&&(min_corner(2)<max_corner(2)))
  image_axes_h=self.mainAxes;
  %image_h=self.frameImageGH;
  %n_rois=length(self.model.roi);
%  set(image_h,'EraseMode','normal');
  set(image_axes_h,'XLim',[min_corner(1) max_corner(1)]);
  set(image_axes_h,'YLim',[min_corner(2) max_corner(2)]);
%   fprintf(1,'Current view:  xlim:[%f %f]  ylim:[%f %f]\n',...
%           min_corner(1),max_corner(1),min_corner(2),max_corner(2));
  %self.resize();  % have to re-do layout
end    

end
