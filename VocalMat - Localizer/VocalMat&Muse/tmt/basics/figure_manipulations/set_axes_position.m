function set_axes_position(pos_axes_new)

% pos_fig_new in inches

% save fig, axes units
original_fig_units=get(gcf,'units');
original_axes_units=get(gca,'units');

% set fig, axes units
set(gcf,'units','inches');
set(gca,'units','inches');

% set axes to new position
set(gca,'position',pos_axes_new);

% replace units
set(gcf,'units',original_fig_units);
set(gca,'units',original_axes_units);

