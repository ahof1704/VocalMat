function ts_out=f(ts,t_bad,dt)

if nargin<3 || isempty(dt)
  dt=0.005;  % s
end

good=(ts<t_bad-dt)|(ts>t_bad+dt);
ts_out=ts(good);
