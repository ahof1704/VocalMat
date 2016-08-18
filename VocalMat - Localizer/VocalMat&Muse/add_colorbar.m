function axes_cb_h=add_colorbar(axes_h, ...
                                w_cb, ...
                                w_spacer)
                              
% Adds a colorbar to the right of axes_h, without moving or changing 
% axes_h in any way.  Still uses the figure colormap.

if ~exist('w_cb','var') || isempty(w_cb)
  w_cb=20/72;  % in
end

if ~exist('w_spacer','var') || isempty(w_spacer)
  w_spacer=15/72;  % in
  %w_spacer=0;  % in  
end

% get figure handle
fig_h=get(axes_h,'parent');
                              
% save fig, axes units
original_fig_units=get(fig_h,'units');
original_axes_units=get(axes_h,'units');

% set fig, axes units
set(fig_h,'units','inches');
set(axes_h,'units','inches');

% do stuff
drawnow;
pos_main=get(axes_h,'position');
x_main=pos_main(1);
y_main=pos_main(2);
w_main=pos_main(3);
h_main=pos_main(4);

x_cb=x_main+w_main+w_spacer;
%x_cb=x_main+w_main;
y_cb=y_main;
% w_cb is a param
h_cb=h_main;
pos_cb=[x_cb y_cb w_cb h_cb];

% create the colorbar axes
axes_cb_h=axes('parent',fig_h, ...
               'units','inches', ...
               'box','on', ...
               'layer','top', ...
               'yaxislocation','right');
drawnow;             
set(axes_cb_h,'position',pos_cb);             

cmap=get(fig_h,'colormap');
n_colors=size(cmap,1);
cmap_indexed=(1:n_colors)';
cl=get(axes_h,'clim');
im_cb_h=image('parent',axes_cb_h, ...
              'cdatamapping','direct', ...
              'cdata',cmap_indexed, ...
              'xdata',zeros(n_colors,1), ...
              'ydata',cl);
set(axes_cb_h,'xlim',[-0.5 +0.5]);
set(axes_cb_h,'ylim',cl);
set(axes_cb_h,'xtick',[]);

% replace units
set(fig_h,'units',original_fig_units);
set(axes_h,'units',original_axes_units);
                              
end
