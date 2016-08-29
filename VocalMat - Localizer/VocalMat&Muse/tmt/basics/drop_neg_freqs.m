function [Cxy_os] = f(Cxy_ts)

% turns a two-sided coherence into a one-sided
% (i.e. it drops the negative frequencies)
% works on the the cols of Cxy_ts (i.e. along the first dimension)

% huge rigamarole to do something MATLAB should have a way to do easily
N_dims=ndims(Cxy_ts);
rest_o_dims=cell(1,N_dims-1);
for j=1:N_dims-1
  rest_o_dims{j}=':';
end
% end of huge rigamarole

N=size(Cxy_ts,1);
Cxy_os=Cxy_ts(1:ceil(N/2),rest_o_dims{:});
