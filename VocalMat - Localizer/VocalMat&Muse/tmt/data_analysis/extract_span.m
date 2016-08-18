function [t_out,y_out]=f(t,y,t_span,zero);

% t should be col vector, y should have data in cols

if nargin<4 || isempty(zero)
  zero=false;
end
t_start=min(t_span);
t_end=max(t_span);
n_t=length(t);
t0=t(1);  tf=t(end);
i_start=max(1,floor((n_t-1)*(t_start-t0)/(tf-t0)+1));
i_end=min(n_t,ceil((n_t-1)*(t_end-t0)/(tf-t0)+1));
t_out=t(i_start:i_end);
if size(y,2)>0
  y_out=y(i_start:i_end,:);
else
  y_out=zeros(length(t_out),0);
end
if zero
  t_out=t_out-t_out(1);
end
