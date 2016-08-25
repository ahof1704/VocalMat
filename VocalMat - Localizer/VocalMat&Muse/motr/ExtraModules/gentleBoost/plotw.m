function plotw(x1, x2, w, y, plotstyle)

c = (y+3)/2;
for i = 1:length(x1)
    plot(x1(i), x2(i), plotstyle.colors{c(i)}, ...
        'MarkerFaceColor', plotstyle.colors{c(i)}(1), ...
        'MarkerSize', 20*w(i)+1); hold on
end
hold off
axis(plotstyle.range)
axis('equal')
axis('tight')
title('Class +1 in green, class -1 in red')
