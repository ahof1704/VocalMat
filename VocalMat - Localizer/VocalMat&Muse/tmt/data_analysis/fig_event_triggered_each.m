function f(t_peri,v_peri)

n_traces=size(v_peri,2);
for j=1:n_traces 
  figure;
  plot(t_peri,v_peri(:,j),'k');
  set(gca,'Layer','Top');
  xlim([t_peri(1) t_peri(end)]);
  ylabel('Signal');
  xlabel('Time');
  title(sprintf('j = %d',j));
end
