function f(t_peri,v_peri_mean,v_peri,show_individual_traces)

if nargin<4 || isempty(show_individual_traces)
  show_individual_traces=1;
end

figure;
if show_individual_traces && size(v_peri,2)>0
  plot(t_peri,v_peri,'Color',[0.75 0.75 0.75]);
  hold on;
end
plot(t_peri,v_peri_mean,'Color',[0 0 0]);
set(gca,'Layer','Top');
hold off;
xlim([t_peri(1) t_peri(length(t_peri))]);
ylabel('Signal');
xlabel('Time');
