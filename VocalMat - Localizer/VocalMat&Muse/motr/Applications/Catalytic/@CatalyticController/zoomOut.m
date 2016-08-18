function zoomOut(self)

% get some handles we'll need
image_axes_h=self.mainAxes;
image_h=self.frameImageGH;

% calc new limits
xlim=get(image_axes_h,'XLim');
ylim=get(image_axes_h,'YLim');
min_corner=[xlim(1);ylim(1)];
max_corner=[xlim(2);ylim(2)];
center=mean([min_corner max_corner],2);
new_dr=max_corner-min_corner;
new_min_corner=center-new_dr;
new_max_corner=center+new_dr;
% make sure the new corners will be half-lattice points
new_min_corner=floor(new_min_corner-0.5)+0.5;
new_max_corner=ceil(new_max_corner-0.5)+0.5;

% clamp things to the image limits
rc=size(get(image_h,'CData'));
n_rows=rc(1); n_cols=rc(2);
if new_min_corner(1)<0.5
  new_min_corner(1)=0.5;
end
if new_min_corner(2)<0.5
  new_min_corner(2)=0.5;
end
if new_max_corner(1)>n_cols+0.5
  new_max_corner(1)=n_cols+0.5;
end
if new_max_corner(2)>n_rows+0.5
  new_max_corner(2)=n_rows+0.5;
end

% set the new image limits
%n_rois=length(self.model.roi);
%set(image_h,'EraseMode','normal');
set(image_axes_h,'XLim',[new_min_corner(1) new_max_corner(1)]);
set(image_axes_h,'YLim',[new_min_corner(2) new_max_corner(2)]);
% fprintf(1,'Current view:  xlim:[%f %f]  ylim:[%f %f]\n',...
%         new_min_corner(1),new_max_corner(1),...
%         new_min_corner(2),new_max_corner(2));
%self.resize();  % have to re-do layout

end
