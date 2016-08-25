function ylim_all_same()

axes_h=get(gcf,'children');
n_axes=length(axes_h);
yl_all=nan(n_axes,2);
for i=1:length(axes_h)
  axes(axes_h(i));
  yl_all(i,:)=ylim;
end
yl_common=[min(yl_all(:,1)) max(yl_all(:,2))];
for i=1:length(axes_h)
  axes(axes_h(i));
  ylim(yl_common);
end
