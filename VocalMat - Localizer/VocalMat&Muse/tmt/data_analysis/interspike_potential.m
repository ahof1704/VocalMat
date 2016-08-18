function [t_inter,v_inter]=f(t,v,ts);

% this returns the times and the potentials of the troughs between spikes,
% where the spike times are given in ts
%
% I should add code to insert samples of v if the time between spikes is
% longer than a cutoff given by an input (say, T_isi_too_long)

% get time info
[n_t,t0,tf,T,dt,fs]=time_info(t);

% get the minima between spikes
is=round((ts-t0)/dt)+1;
t_inter=zeros(length(is)-1,1);
v_inter=zeros(length(is)-1,1);
for j=1:(length(is)-1)
  t_this=t(is(j):is(j+1));
  v_this=v(is(j):is(j+1));
  [v_this_min,i_min]=min(v_this);
  t_inter(j)=t_this(i_min);
  v_inter(j)=v_this_min;
end
