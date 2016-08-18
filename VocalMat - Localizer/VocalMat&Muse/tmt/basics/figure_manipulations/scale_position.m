function pos_new=f(pos,factor)

if length(factor)==1
  factor=[factor factor];
end
offset=pos(1:2); 
extent=pos(3:4);
center=offset+extent/2;
extent_new=factor.*extent;
offset_new=center-extent_new/2;
pos_new=[offset_new extent_new];
