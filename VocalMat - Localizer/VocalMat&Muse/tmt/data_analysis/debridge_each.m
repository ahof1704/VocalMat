function v_cos=f(t,v,command,post_edge_blank_time,method,frac_to_sub)

% process args
if nargin<5
  method='subtract mean';
elseif isempty(method)
  method='subtract mean';  
end
if nargin<6
  frac_to_sub=1;
elseif isempty(frac_to_sub)
  frac_to_sub=1;  
end

% convert command to a bool
command_bool=ttl_to_bool(command);

% if command is zero everywhere, the livin is easy
if ~any(command_bool)
  v_cos=v;
  artifact=zeros(size(v));
  return;
end

% this will be useful later
[n_samples,t_min,t_max,T,dt,fs]=time_info(t);

% extract the edges from command
edges=ttl_edges(command);
edges=abs(edges);
n_edges=sum(edges);
edge_indices=find(edges);

% for each command pulse, change the DC level of v to minimize the steps
% at the edges. We assume that command is 0 at the start and end, which
% implies, among other things, that the number of edges is even
n_post=ceil(post_edge_blank_time/dt);
v_cos=v;  % cos for cosmetic
v_baseline=mean(v(~command_bool));
for j=1:2:n_edges
  % figure out how much to offset the voltage for this pulse
  rising_edge_index=edge_indices(j);
  falling_edge_index=edge_indices(j+1);
  if strcmp(method,'subtract mean')
    v_offset=frac_to_sub*...
             (mean(v(rising_edge_index+n_post:...
                     falling_edge_index))-...
              v_baseline);
  elseif strcmp(method,'minimize jump')
    v_rising_pre=v(rising_edge_index);
    v_rising_post=v(rising_edge_index+n_post);
    v_falling_pre=v(falling_edge_index);
    v_falling_post=v(falling_edge_index+n_post);
    rising_jump=v_rising_post-v_rising_pre;
    falling_jump=v_falling_pre-v_falling_post;
    jump=[rising_jump falling_jump];
    [dummy,which_one]=min(abs(jump));
    v_offset=jump(which_one);  % v_offset=jump(argmin(abs(jump)));
  else
    error(['The two available methods are ''subtract mean'' and' ...
           ' ''minimize jump''']);
  end
  % change the samples during the pulse, but not during the n_post
  v_cos(rising_edge_index+n_post:falling_edge_index)=...
    v(rising_edge_index+n_post:falling_edge_index)-v_offset;
  % change the rising edge samples
  v_cos(rising_edge_index:rising_edge_index+n_post)=...
    linspace(v_cos(rising_edge_index),...
             v_cos(rising_edge_index+n_post),...
             n_post+1)';
  % change the falling edge samples
  v_cos(falling_edge_index:falling_edge_index+n_post)=...
    linspace(v_cos(falling_edge_index),...
             v_cos(falling_edge_index+n_post),...
             n_post+1)';
end

