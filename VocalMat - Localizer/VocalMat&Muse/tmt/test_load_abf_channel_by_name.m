% load a data file
[t,x,name,units]=load_abf('689_032_0002.abf');

% extract the signal we want
name_this='RED';
t_check=t;
x_this_check=x(:,strcmp(name_this,name));
units_this_check=units{strcmp(name_this,name)};

% plot one on top of other
figure; 
plot(t_check,x_this_check,'r');
ylabel(sprintf('%s (%s)',name_this,units_this_check));
xlabel('Time (s)');
title('load_abf (r)','interpreter','none');

% load a single channel by name
[t,x_this,units_this]=...
  load_abf_channel_by_name('689_032_0002.abf',name_this);

% plot one on top of other
figure; 
plot(t_check,x_this_check,'r');
hold on;
plot(t,x_this,'b');
hold off;
ylabel(sprintf('%s (%s)',name_this,units_this));
xlabel('Time (s)');
title('load_abf (r), load_abf_channel_by_name (b)','interpreter','none');


units_this
units_this_check