function sz_axes=get_axes_size()

% sz_axes in inches

% save axes units
original_axes_units=get(gca,'units');

% set axes units
set(gca,'units','inches');

% get axes size
pos_axes=get(gca,'position');
sz_axes=pos_axes(3:4);

% replace units
set(gca,'units',original_axes_units);
