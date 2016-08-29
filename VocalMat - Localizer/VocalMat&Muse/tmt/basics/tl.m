function f(l,h)

kid_hs=get(gcf,'Children')';
for kid_h=kid_hs
  if strcmp(get(kid_h,'Type'),'axes')
    if l<=h
      xlim(kid_h,[l h]);
    else
      xlim(kid_h,[h l]);
    end
  end
end

    