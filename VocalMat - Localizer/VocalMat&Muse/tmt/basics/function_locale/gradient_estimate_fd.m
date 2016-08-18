function [g,fx0]=f(fh,x0,dx_size,fx0,varargin)

% we assume the inputs are well-scaled (preferably unitless)
% the gradient returned is a row vector
% this version requires 2*n function evaluations

n=length(x0);
if isempty(fx0)
  fx0=feval(fh,x0,varargin{:});
end
% positive steps
dxs_pos=dx_size*eye(n);
% eval f at the dx's
fdxs_pos=zeros(1,n);
for j=1:n
  dx=dxs_pos(:,j);
  fdx=feval(fh,x0+dx,varargin{:});
  fdxs_pos(j)=fdx;
end
% negative steps
dxs_neg=-dx_size*eye(n);
% eval f at the dx's
fdxs_neg=zeros(1,n);
for j=1:n
  dx=dxs_neg(:,j);
  fdx=feval(fh,x0+dx,varargin{:});
  fdxs_neg(j)=fdx;
end
% calc the gradient from the fdx's
df=fdxs_pos-fdxs_neg;
g=df/(2*dx_size);
