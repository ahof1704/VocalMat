global POINTS;

POINTS=[]
set(gca,'ButtonDownFcn','mark_points_click');
set(get(gca,'Children'),'ButtonDownFcn','mark_points_click');
set(gca,'xlim',get(gca,'xlim'));  % sets xlimmode to manual
set(gca,'ylim',get(gca,'ylim'));  % ditto ylimmode

