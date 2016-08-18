function f(y,factor)

if nargin<2
  factor=1.1;
end
ylim(range_loose(y,factor));
