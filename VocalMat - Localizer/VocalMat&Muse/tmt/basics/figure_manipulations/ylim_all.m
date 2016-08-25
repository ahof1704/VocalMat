function ylim_all(yl)

axes_h=get(gcf,'children');
for i=1:length(axes_h)
  axes(axes_h(i));
  ylim(yl);
end
