function clr=f(x)

% x is a col vector

n=length(x);
clr_hsv=[x repmat(1,[n 1]) repmat(1,[n 1])];
clr=hsv2rgb(clr_hsv);

