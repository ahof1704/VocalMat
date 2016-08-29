function f(sz_axes_new)

% sz_fig_new in inches

% save fig, axes units
original_fig_units=get(gcf,'units');
original_axes_units=get(gca,'units');

% set fig, axes units
set(gcf,'units','inches');
set(gca,'units','inches');

% calculate new axes offset
pos_fig=get(gcf,'position');  sz_fig=pos_fig(3:4);
pos_axes=get(gca,'position');
axes_offset_new=[(sz_fig(1)-sz_axes_new(1))/2 (sz_fig(2)-sz_axes_new(2))/2];

% set axes to new position
axes_pos_new=[axes_offset_new sz_axes_new];
set(gca,'position',axes_pos_new);

% replace units
set(gcf,'units',original_fig_units);
set(gca,'units',original_axes_units);
