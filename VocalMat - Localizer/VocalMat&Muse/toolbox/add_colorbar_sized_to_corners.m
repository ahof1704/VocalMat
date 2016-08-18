function axes_cb_h= ...
  add_colorbar_sized_to_corners(axes_h, ...
                                w_colorbar, ...
                                w_colorbar_spacer, ...
                                axis_label, ...
                                r_corners)

if ~exist('w_colorbar','var') 
  w_colorbar=[];
end
if ~exist('w_colorbar_spacer','var')
  w_colorbar_spacer=[];
end
if ~exist('axis_label','var') ,
  axis_label='';
end
if ~exist('r_corners','var') ,
  r_corners=[];
end

color_limits=get(axes_h,'clim');

% draw the colorbar
axes_cb_h=add_colorbar(axes_h,w_colorbar,w_colorbar_spacer);
set(axes_cb_h,'fontsize',7);
ylabel(axes_cb_h,axis_label);
set(axes_cb_h,'ytick',color_limits);
if ~isempty(r_corners) ,
  scale_colorbar_to_corners(axes_cb_h, ...
                            axes_h, ...
                            100*r_corners);
end
    
end
