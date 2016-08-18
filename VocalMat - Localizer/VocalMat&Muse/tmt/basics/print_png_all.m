function f(hs)

if nargin<1 || isempty(hs)
  hs=get(0,'Children')';
end
% print em
for i=hs
  print_png(i);
  if i~=hs(end) fprintf(1,'\n'); end
end
