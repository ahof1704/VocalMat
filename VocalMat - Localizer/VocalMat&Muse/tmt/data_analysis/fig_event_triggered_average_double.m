function f(t_peri,...
           v_follower_peri_mean,v_follower_peri,...
           v_driven_peri_mean,v_driven_peri,...
           show_individual_traces)

if nargin<6
  show_individual_traces=1;
elseif isempty(show_individual_traces)
  show_individual_traces=1;
end

figure;
subplot(2,1,1);
if show_individual_traces
  plot(t_peri,v_driven_peri,'Color',[0.75 0.75 0.75]);
  hold on;
end
plot(t_peri,v_driven_peri_mean,'Color',[0 0 0]);
set(gca,'Layer','Top');
%set(gca,'XTickLabel',[]);
xlim([t_peri(1) t_peri(length(t_peri))]);
ylabel('Trigger');
hold off;
subplot(2,1,2);
if show_individual_traces
  plot(t_peri,v_follower_peri,'Color',[0.75 0.75 0.75]);
  hold on;
end
plot(t_peri,v_follower_peri_mean,'Color',[0 0 0]);
set(gca,'Layer','Top');
xlim([t_peri(1) t_peri(length(t_peri))]);
ylabel('Follower');
xlabel('Time');
hold off;
set(gcf,'PaperPosition',[1 3.0625 6.5 4.875]);
