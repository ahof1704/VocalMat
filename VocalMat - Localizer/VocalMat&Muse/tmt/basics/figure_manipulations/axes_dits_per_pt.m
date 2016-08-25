function data_units_per_pt=f(axes_h)

% this function assumes stretch-to-fill behavior is in effect
% (a "dit" is a "data unit")

% get current axes units;
old_units=get(axes_h,'units');  

% sets the units of the axes to points
set(axes_h,'units','points');

% obtains the axes size in points
pos=get(axes_h,'Position');
sz_axes_pts=pos(3:4);

% get the plot box aspect ratio
pbar=get(axes_h,'PlotBoxAspectRatio');
pbar_ratio=pbar(1:2);

% get the constraining one
[r_min,i_min]=min(sz_axes_pts./pbar_ratio);

% scale the plot box aspect ratio to get it's size in pts
sz_pbar_pts=pbar_ratio*(sz_axes_pts(i_min)/pbar_ratio(i_min));

% obtain size in data units
sz_data_units=[diff(xlim(axes_h)) diff(ylim(axes_h))];

% retval
data_units_per_pt=sz_data_units./sz_pbar_pts;

% set units back
set(axes_h,'units',old_units);
