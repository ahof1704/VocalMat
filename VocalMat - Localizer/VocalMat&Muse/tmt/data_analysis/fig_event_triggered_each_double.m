function f(t_peri,v_follower_peri,v_driven_peri)

n_traces=size(v_follower_peri,2);
for j=1:n_traces 
  figure;
  subplot(2,1,1);
  plot(t_peri,v_driven_peri(:,j),'k');
  set(gca,'Layer','Top');
  %set(gca,'XTickLabel',[]);
  xlim([t_peri(1) t_peri(length(t_peri))]);
  ylabel('Trigger');
  title(sprintf('j = %d',j));
  subplot(2,1,2);
  plot(t_peri,v_follower_peri(:,j),'k');
  set(gca,'Layer','Top');
  xlim([t_peri(1) t_peri(length(t_peri))]);
  ylabel('Follower');
  xlabel('Time');
  set(gcf,'PaperPosition',[1 3.0625 6.5 4.875]);
end