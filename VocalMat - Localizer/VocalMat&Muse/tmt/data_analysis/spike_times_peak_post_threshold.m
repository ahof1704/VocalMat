function [crossing_times,crossing_indices]=...
           f(t,v_driven,v_threshold,spike_window_duration,plot_threshold)

% deal w/ args
if nargin<5 || isempty(plot_threshold)
  plot_threshold=0;
end
         
% this will be useful later
[n_samples,t_min,t_max,T,dt,fs]=time_info(t);

% show a plot of v_driven in various states of being processed
if (plot_threshold<=-2)
  figure;
  plot(t,v_driven,'b',t,repmat(v_threshold,size(t)),'r');
end

% get the threshold crossing times, but no artifacts and no negative 
% crossings
crossings=crossing_array(t,v_driven,v_threshold);
crossings=crossings>0;  % only want rising crossings
crossing_indices=find(crossings);  % get an array of indices

% go through find the maximum that is at most 
% spike_window_duration after the threshold-crossing 
n_window=ceil(spike_window_duration/dt);
for k=1:length(crossing_indices)
  i=crossing_indices(k);
  best_offset=1;
  for j=2:n_window
    if i+j<=n_samples
      if v_driven(i+j)>v_driven(i+best_offset)
        best_offset=j;
      end
    end
  end
  crossing_indices(k)=i+best_offset;
end
    
% convert the crossing indices to crossing times
crossing_times=t(crossing_indices);  

