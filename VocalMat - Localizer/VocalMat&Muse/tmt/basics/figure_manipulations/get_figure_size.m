function sz_fig=get_figure_size()

% sz_fig in inches

% save fig units
original_fig_units=get(gcf,'units');

% set figure units
set(gcf,'units','inches');

% get figure size
pos_fig=get(gcf,'position');
sz_fig=pos_fig(3:4);

% replace units
set(gcf,'units',original_fig_units);
