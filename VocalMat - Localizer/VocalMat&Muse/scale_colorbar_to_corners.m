function scale_colorbar_to_corners(axes_cb_h, ...
                                   axes_main_h, ...
                                   r_corners)

% Matches the size of the colorbar to the r_corners

% save fig, axes units
original_axes_main_units=get(axes_main_h,'units');
original_axes_cb_units=get(axes_cb_h,'units');

% set fig, axes units
set(axes_main_h,'units','inches');
set(axes_cb_h,'units','inches');

% get the relevant aspects of the main axes position in the figure
pos_main=get(axes_main_h,'position');
y0_main_layout=pos_main(2);
h_main_layout=pos_main(4);

% Get the coords of the main y axis in data units
yl_main_data=get(axes_main_h,'ylim');
y0_main_data=yl_main_data(1);
yf_main_data=yl_main_data(2);
h_main_data=(yf_main_data-y0_main_data);

% Get the corner positions in data units
y0_corner_data=min(r_corners(2,:));
yf_corner_data=max(r_corners(2,:));

% convert corner positions from data to layout coordinates
y0_corner_layout=h_main_layout/h_main_data*(y0_corner_data-y0_main_data)+y0_main_layout;
yf_corner_layout=h_main_layout/h_main_data*(yf_corner_data-y0_main_data)+y0_main_layout;

% The colorbar layout position will match the corners
y0_cb_layout=y0_corner_layout;
yf_cb_layout=yf_corner_layout;
h_cb_layout=yf_cb_layout-y0_cb_layout;

% Set the position of the colorbar
pos_cb=get(axes_cb_h,'position');
pos_cb(2)=y0_cb_layout;
pos_cb(4)=h_cb_layout;
set(axes_cb_h,'position',pos_cb);

% replace units
set(axes_main_h,'units',original_axes_main_units);
set(axes_cb_h,'units',original_axes_cb_units);
                              
end
