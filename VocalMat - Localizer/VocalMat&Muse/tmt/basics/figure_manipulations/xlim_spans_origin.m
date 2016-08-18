% script to include 0 in the x range of current axes
xl=xlim;
if xl(2)<0
  xlim([xl(1) 0]);
elseif xl(1)>0
  xlim([0 xl(2)]);
end
  