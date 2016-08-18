function i_spikes=...
           f(t,v,T_sigma_filter,dt_spike_limit,v_spike_height)

% this will be useful later
[n_t,t0,tf,T,dt,fs]=time_info(t);
di_spike_limit=round(dt_spike_limit/dt);
di_pre=di_spike_limit(1);
di_post=di_spike_limit(2);

% get extrema
[i_extrema,sign_extrema]=extrema_indices(v,T_sigma_filter/dt);

% just want maxima
i_maxima=i_extrema(sign_extrema>0);

% get rid of ones that are not tall enough on both sides
n_maxima=length(i_maxima);
tall_enough=repmat(false,size(i_maxima));
for j=1:n_maxima
  i_this=i_maxima(j);
  i_pre=i_this+di_pre;
  i_post=i_this+di_post;
  if i_pre>=1 && ...
     i_post<=n_t && ...
     v(i_this)-v(i_pre )>=v_spike_height && ...
     v(i_this)-v(i_post)>=v_spike_height
      tall_enough(j)=true;
    end
end

% and assign to the output var
i_spikes=i_maxima(tall_enough);

% % plot
% figure;
% plot(t,v);
% hold on;
% v_max=max(v);  v_min=min(v);
% dt_pre=dt_spike_limit(1);
% dt_post=dt_spike_limit(2);
% for j=1:length(i_spikes)
%   t_this=t0+dt*(i_spikes(j)-1);
%   line([t_this t_this],[v_min v_max],[-1 -1],'color',[1 0 0]);
%   line([t_this+dt_pre t_this+dt_pre],[v_min v_max],[-1 -1],'color',[0 0.5 0]);
%   line([t_this+dt_post t_this+dt_post],[v_min v_max],[-1 -1],'color',[0 0 0.5]);  
% end
