function centerOnRoot(fig)

% This should work as desired unless the user has multiple monitors.

% Get our position
originalUnits=get(fig,'units');
set(fig,'units','points');
pos=get(fig,'position');
set(fig,'units',originalUnits);
offset=pos(1:2);
sz=pos(3:4);

% Get out parent's position
originalUnits=get(0,'units');
set(0,'units','points');
rootPos=get(0,'screensize');
set(0,'units',originalUnits);
rootOffset=rootPos(1:2);
rootSz=rootPos(3:4);

% Calculate a new offset that will center us on the parent
newOffset=rootOffset+(rootSz-sz)/2;

% Set our position, using the new offset but the same size as before
originalUnits=get(fig,'units');
set(fig,'units','points');
set(fig,'position',[newOffset sz]);
set(fig,'units',originalUnits);

end
