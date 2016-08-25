function [H,gx0,fx0]=f(fh,x0,dx_size,fx0,gx0,varargin)

% we assume the inputs are well-scaled (preferably unitless)
% the gradient returned is a row vector

n=length(x0);
if isempty(fx0)
  fx0=feval(fh,x0,varargin{:});
end
if isempty(gx0)
  gx0=gradient_estimate_fd(fh,x0,dx_size,fx0,varargin{:});
end
% positive steps
dxs_pos=dx_size*eye(n);
% eval g at the dx's
gdxs_pos=zeros(n,n);
for i=1:n
  dx=dxs_pos(:,i);
  gdx=gradient_estimate_fd(fh,x0+dx,dx_size,[],varargin{:});
  gdxs_pos(i,:)=gdx;
end
% negative steps
dxs_neg=-dx_size*eye(n);
% eval g at the dx's
gdxs_neg=zeros(n,n);
for i=1:n
  dx=dxs_neg(:,i);
  gdx=gradient_estimate_fd(fh,x0+dx,dx_size,[],varargin{:});
  gdxs_neg(i,:)=gdx;
end
% calc the Hessian from the gdxs
dg=gdxs_pos-gdxs_neg;
H=dg/(2*dx_size);
