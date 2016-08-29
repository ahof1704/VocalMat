function [v_cos,v_bal,artifact]=...
           f(t,v,command,post_step_blank_time,frac_to_sub)

% v_bal is similar to the trace you'd get if you 'overbalanced'
%  the bridge to that the DC level was the same regardless of whether
%  or not current was being passed
% v_cos is like v_bal, but also 
% frac_to_sub gives what fraction of the estimated resistance is to be
%  subtracted.  It defaults to 1.
% NB: On 2002/05/26, I made it so that v_cos is the first return value,
%     and v_bal is the second.  Before that it was the other way around.
%     This may break some things in other code.

% process args
if nargin<5
  frac_to_sub=1;
end

% this will be useful later
[n_samples,t_min,t_max,T,dt,fs]=time_info(t);

% fit the command to v, and subtract this out
% this is to even out the jumps in potential that result when we pass
% current
if (frac_to_sub==0)|all(abs(command)<1e-3)
  v_bal=v;
else
  p=polyfit(command,v,1);  
  v_bal=v-frac_to_sub*p(1)*command;  % bal for balanced
end
    
% get rid of capacitance and other artifacts by smoothing over
% post_step_blank_time after each step in command
edges=ttl_edges(command);
edges=abs(edges);
n_edges=sum(edges);
edge_indices=find(edges);
bad_steps=ceil(post_step_blank_time/dt);
artifact=zeros(size(edges));
% cos for cosmetic
v_cos=v_bal;
for j=1:n_edges
  k=edge_indices(j);  % k is index of this edge
  artifact(k-1:k+bad_steps)=1;
  v_cos(k-1:k+bad_steps)=linspace(v_bal(k-1),...
                                  v_bal(k+bad_steps),...
                                  bad_steps+2)';
end

