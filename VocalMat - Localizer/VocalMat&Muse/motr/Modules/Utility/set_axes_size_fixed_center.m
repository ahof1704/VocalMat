function set_axes_size_fixed_center(sz_axes_new)

% sz_fig_new in inches

% save axes units
original_axes_units=get(gca,'units');

% set axes units
set(gca,'units','inches');

% calculate new axes offset
pos_axes=get(gca,'position');
cent_axes=pos_axes(1:2)+0.5*pos_axes(3:4);
offset_axes_new=[cent_axes(1)-sz_axes_new(1)/2 cent_axes(2)-sz_axes_new(2)/2];

% set axes to new position
axes_pos_new=[offset_axes_new sz_axes_new];
set(gca,'position',axes_pos_new);

% replace units
set(gca,'units',original_axes_units);
