function f()

% print em
fig_hs=get(0,'Children')';
for i=fig_hs
  print_eps(i);
  if i~=fig_hs(end) fprintf(1,'\n'); end
end
