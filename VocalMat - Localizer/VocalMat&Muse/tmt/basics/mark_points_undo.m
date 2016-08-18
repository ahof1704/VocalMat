function f()

global POINTS;

if size(POINTS,1)>0
  POINTS=POINTS(1:end-1,:);
end
