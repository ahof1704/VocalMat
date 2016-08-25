function f(t,x)

global SPIKE_TIMES;

mark_spikes_figure_h=figure;
line_h=plot(t,x,'k');
SPIKE_TIMES=[]
set(gca,'ButtonDownFcn','mark_spikes_click');
set(line_h,'ButtonDownFcn','mark_spikes_click');
set(gca,'xlim',get(gca,'xlim'));  % sets xlimmode to manual
set(gca,'ylim',get(gca,'ylim'));  % ditto ylimmode
return;

