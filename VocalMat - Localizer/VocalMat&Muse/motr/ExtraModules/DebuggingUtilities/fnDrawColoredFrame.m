function fnDrawColoredFrame(s, c)
%
plot([1 s(2)], [1 1], 'Color',c, 'LineWidth',3);
plot([1 s(2)], [s(1) s(1)], 'Color',c, 'LineWidth',3);
plot([1 1], [1 s(1)], 'Color',c, 'LineWidth',3);
plot([s(2) s(2)], [1 s(1)], 'Color',c, 'LineWidth',3);
