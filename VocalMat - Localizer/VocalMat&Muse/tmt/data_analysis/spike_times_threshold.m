function [t_spikes,i_spikes]=...
           f(t,v,v_threshold,sign_wanted,T_exclude,plot_threshold)

% check args
if nargin<4 || isempty(sign_wanted)
  sign_wanted=+1;
end  
if nargin<5 || isempty(T_exclude)
  T_exclude=0;
end  
if nargin<6 || isempty(plot_threshold)
  plot_threshold=0;
end  

% this will be useful later
[n_samples,t_min,t_max,T,dt,fs]=time_info(t);
           
% show a plot of v with the threshold
if (plot_threshold<=-2)
  figure;
  plot(t,v,'b',t,repmat(v_threshold,size(t)),'r');
end

% get the threshold crossing times, but no artifacts and no negative 
% crossings
[t_spikes,signs,i_spikes]=...
  crossing_times(t,v,v_threshold);
right_sign=signs==sign_wanted;
t_spikes=t_spikes(right_sign);  % only want crossings w/ right sign
i_spikes=i_spikes(right_sign);

% get rid of ones within the exclusion time
include=logical(ones(size(t_spikes)));
if length(t_spikes)>1 && T_exclude>0
  t_last_good=t_spikes(1);
  for i=2:length(t_spikes)
    if t_spikes(i)-t_last_good<=T_exclude
      include(i)=0;
    else
      t_last_good=t_spikes(i);
    end
  end
  t_spikes=t_spikes(include);
  i_spikes=i_spikes(include);
end
