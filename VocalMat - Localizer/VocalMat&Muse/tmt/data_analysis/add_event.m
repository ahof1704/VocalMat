function ts_out=f(ts,t_new)

% we assume ts is a col vector

% have to put t_new in in the right place
is=find(ts<t_new);
if length(is)==0
  ts_out=[t_new;ts];
elseif is(end)==length(ts);
  ts_out=[ts;t_new];
else
  ts_out=[ts(1:is(end));t_new;ts(is(end)+1:end)];
end
