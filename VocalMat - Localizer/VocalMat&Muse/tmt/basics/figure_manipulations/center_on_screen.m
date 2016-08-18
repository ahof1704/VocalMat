function new_pos=f(pos)

sz=pos(3:4);
pos_screen=get(0,'position');
sz_screen=pos_screen(3:4);
offset=(sz_screen-sz)/2;
new_pos=[offset sz];
