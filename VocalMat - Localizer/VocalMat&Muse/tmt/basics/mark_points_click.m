function f()

global POINTS;

cp=get(gca,'CurrentPoint');
click_coords=cp(1,1:2)';
hold on;
plot(click_coords(1),click_coords(2),'b.');
hold off;
POINTS(end+1,1:2)=click_coords';
POINTS(end,:)

