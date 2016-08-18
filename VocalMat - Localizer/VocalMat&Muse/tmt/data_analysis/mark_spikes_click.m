function f()

global SPIKE_TIMES;

cp=get(gca,'CurrentPoint');
click_coords=cp(1,1:2)';
SPIKE_TIMES(end+1,1)=click_coords(1);
SPIKE_TIMES(end,1)
return;

