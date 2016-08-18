function change_axes_position_manually_to_give_one_one_data_aspect_ratio(axes_h)

% What it says on the tin.  Other approaches can make it so that the
% apparent axes position onscreen is not the true axes position according
% to the 'Position' property.  This leaves center of the axes where it
% started, and on exit the axes is either smaller or the same size as at
% the start.

% save fig, axes units
original_units=get(axes_h,'units');

% set fig, axes units
set(axes_h,'units','inches');

% do stuff
pos=get(axes_h,'position');
x=pos(1);
y=pos(2);
w=pos(3);
h=pos(4);
axes_aspect_ratio=w/h;

x_span=diff(get(axes_h,'xlim'));
y_span=diff(get(axes_h,'ylim'));
limits_aspect_ratio=x_span/y_span;

if axes_aspect_ratio==limits_aspect_ratio ,
  w_new=w;
  h_new=h;
  x_new=x;
  y_new=y;
elseif axes_aspect_ratio>limits_aspect_ratio ,
  w_new=limits_aspect_ratio*h;
  h_new=h;
  x_new=x+(w-w_new)/2;
  y_new=y;
else
  % axes_aspect_ratio<limits_aspect_ratio
  w_new=w;
  h_new=w/limits_aspect_ratio;
  y_new=y+(h-h_new)/2;
  x_new=x;
end

% set the axes position
set(axes_h,'position',[x_new y_new w_new h_new]);

% restore units
set(axes_h,'units',original_units);

end
