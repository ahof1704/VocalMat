function f(dt)

kid_hs=get(gcf,'Children')';
for kid_h=kid_hs
  if strcmp(get(kid_h,'Type'),'axes')
    xl=get(kid_h,'xlim');
    set(kid_h,'xlim',xl+dt);
  end
end

