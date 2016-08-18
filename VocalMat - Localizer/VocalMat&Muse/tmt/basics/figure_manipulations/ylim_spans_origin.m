% script to include 0 in the x range of current axes
yl=ylim;
if yl(2)<0
  ylim([yl(1) 0]);
elseif yl(1)>0
  ylim([0 yl(2)]);
end
  