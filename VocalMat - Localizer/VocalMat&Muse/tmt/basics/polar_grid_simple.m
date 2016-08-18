function axes_h=polar_grid_simple()

% make an axes, and make it square and invisible
axes_h=axes;
axis square;
axis off;

% make a circle
theta=(-pi:pi/50:+pi)';
r=repmat(1,size(theta));
x=r.*cos(theta);
y=r.*sin(theta);
line(x,y,'color','k');

% make tick marks
theta_deg=(-180:30:150)';
theta=pi*theta_deg/180;
r_outer=repmat(1   ,size(theta));
r_inner=repmat(0.96,size(theta));
x_outer=r_outer.*cos(theta);
y_outer=r_outer.*sin(theta);
x_inner=r_inner.*cos(theta);
y_inner=r_inner.*sin(theta);
for j=1:length(theta)
  line([x_outer(j) x_inner(j)],[y_outer(j) y_inner(j)],'color','k');
end

% make angle labels
r_label=repmat(1.1,size(theta));
x_label=r_label.*cos(theta);
y_label=r_label.*sin(theta);
for j=1:length(theta)
  if theta_deg(j)==-180
    text(x_label(j),y_label(j),int2str(-theta_deg(j)),...
         'horizontalalignment','center');
  else
    text(x_label(j),y_label(j),int2str(theta_deg(j)),...
         'horizontalalignment','center');
  end
end
