function [t_peri,v_peri_mean,v_peri]=...
           f(t,v,t_command,command,T_cycle,plot_threshold);

% t should be a col vector
% v should be a matrix, with rows indexing samples and cols indexing traces
% both of the above should have the same number of rows

% t_command should be a col vector
% command should be a col vector
% both of the above should have the same number of rows

% args
if nargin<6
  plot_threshold=0;  % no plots
end

% this will be useful later
[n_samples,t_min,t_max,T,dt,fs]=time_info(t);
n_cycle_samples=floor(T_cycle/dt);
n_traces=size(v,2);

% figure out where the cycles start by finding the first rising edge of
% command
threshold=(max(command)+min(command))/2;
[edge_times,edge_signs]=crossing_times(t_command,command,threshold);
rising_edge_times=edge_times(edge_signs>0);  % filter falling edges
if isempty(rising_edge_times)
  error('No rising edges in command');
end
t_0=rising_edge_times(1);

% get the indices where cycles start
n_cycles=floor((t(n_samples)-t_0)/T_cycle);
t_phase_0=t_0+(0:(n_cycles-1))'*T_cycle;
index_phase_0=round((t_phase_0-t_min)/dt);
index_phase_360=index_phase_0+n_cycle_samples-1;
valid_start=(index_phase_0>=1)&(index_phase_0<=n_samples);
valid_end=(index_phase_360>=1)&(index_phase_360<=n_samples);
index_phase_0=index_phase_0(valid_start&valid_end);
index_phase_360=index_phase_360(valid_start&valid_end);
n_cycles=length(index_phase_0);
                        
% go through and put all the peri-stimulus records into a single array
v_peri=zeros(n_cycle_samples,n_traces,n_cycles);
for j=1:n_cycles
  k=index_phase_0(j);
  this_v_peri=v(index_phase_0(j):index_phase_360(j),:);
  v_peri(:,:,j)=this_v_peri;
end  
t_peri=linspace(0,dt*n_cycle_samples,n_cycle_samples)';

% calc the averages
v_peri_mean=mean(v_peri,3);

% plot the final result
if (plot_threshold<=-1)
  fig_triggered_average(t_peri,v_peri_mean,v_peri);
end



