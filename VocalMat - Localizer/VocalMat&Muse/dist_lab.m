function dist=f(clr1,clr2)

% colors are in rows of clr1 and clr2.
% returns a col vector of distances between colors

dist=sqrt(sum((clr1-clr2).^2,2));

