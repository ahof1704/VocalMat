function [fig_hand,axes_hand]=layout_axes_grid(w_fig,h_fig,...
                                               n_row,n_col,...
                                               w_axes,h_axes,...
                                               w_space,h_space)

% calc derived quants
w_pad=(w_fig-n_col*w_axes-(n_col-1)*w_space)/2;
h_pad=(h_fig-n_row*h_axes-(n_row-1)*h_space)/2;

% set figure dims
fig_hand=figure;
set_figure_size([w_fig h_fig]);

% set axes dims
axes_hand=nan(n_row,n_col);
for i=1:n_row
  for j=1:n_col
    axes_hand(i,j)=axes;
    % set units
    original_axes_units=get(gca,'units');
    set(gca,'units','inches');
    % place this axes
    x_ll=w_pad+(j-1)*(w_axes+w_space);
    y_ll=h_pad+(n_row-i)*(h_axes+h_space);
    set(gca,'position',[x_ll y_ll w_axes h_axes]);
    % restore units
    set(gca,'units',original_axes_units);
  end
end

end
