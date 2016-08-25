% load a data file
[t,x,name,units]=load_abf('689_032_0002.abf');

% plot each of the traces
n_chan=length(name);
for i=1:n_chan
  figure; plot(t,x(:,i));
  ylabel(sprintf('%s (%s)',name{i},units{i}));
  xlabel('Time (s)');
end

