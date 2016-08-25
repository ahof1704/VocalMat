function [H,g,fx0]=f(fh,x0,varargin)

% this version uses n*(n+3)/2 "test vectors"
% we assume the inputs are well-scaled (preferably unitless)

n=length(x0);
fx0=feval(fh,x0,varargin{:});
% make the dx's
dx_step=0.01;  % step size
%n_dx=n*(n+3)/2  % this is the minimum number
n_dx=n*(2*n-1)  % this is for some robustness
dX=zeros(n,n_dx);
% for k=1:n_dx
%   dX(:,k)=normrnd(zeros(size(x0)),repmat(dx_step,size(x0)));
% end
k=1;
for i=1:n
  for j=1:n
    if i<j
      dX(i,k)=+dx_step;
      dX(j,k)=+dx_step;
      k=k+1;
      dX(i,k)=+dx_step;
      dX(j,k)=-dx_step;
      k=k+1;
      dX(i,k)=-dx_step;
      dX(j,k)=+dx_step;
      k=k+1;
      dX(i,k)=-dx_step;
      dX(j,k)=-dx_step;
      k=k+1;
    elseif i==j
      dX(i,k)=+dx_step;
      k=k+1;
      dX(i,k)=-dx_step;
      k=k+1;      
    end
  end
end
%dX
% calc the dfs
df=zeros(n_dx,1);
n_dots_this_line=0;
for k=1:n_dx
  dx=dX(:,k);
  df(k)=feval(fh,x0+dx,varargin{:})-fx0;
  fprintf(1,'.');
  n_dots_this_line=n_dots_this_line+1;
  if n_dots_this_line>=50
    fprintf(1,'\n');
    n_dots_this_line=0;
  end
end
fprintf(1,'\n\n');
% we want to find a vector g, and symmetric matrix H s.t.
% df(k) ~= g'*dX(:,k)+dX(:,k)'*H*dX(:,k)'  for all k
% we need to pose this in the form y=A*x, with x a vector containing the
% elements of g and the columns of H.  For that, we need to make a vector
% for each dx, which we call dy, which is dx and the columns of dx*dx',
% stacked up
dYt=zeros(n+n^2,n_dx);
for k=1:n_dx
  dx=dX(:,k);
  dyt=[dx;reshape(dx*dx',[n^2 1])];
  dYt(:,k)=dyt;
end
%dYt
dY=dYt';  % want dy's in the rows
% Didn't need this code -- for some reason the answer comes out symmetric,
% or close to it
% % if we didn't care about H being symmetric, we could now solve df=dY*p for
% % p, and p would contain g and H.  But since we care about symmetry, we
% % have to multiple dY times a "symmetrizing" matrix, and then solve
% % df=dY*S*q for q, which will contain q and H, and H will be symmetric
% % S will be of the form [I 0 ; 0 S_flat], where I is nxn, and S_flat is
% % (n+n^2)x(n+n^2) -- this will preserve the g parameters, and symmetrize
% % the H parameters.  Designing S_flat is the hard part...
% I_tensor=zeros(n,n,n,n);  % identity tensor
% for i=1:n
%   for j=1:n
%     I_tensor(i,j,j,i)=1;
%   end
% end
% T_tensor=zeros(n,n,n,n);  % transposition tensor
% for i=1:n
%   for j=1:n
%     T_tensor(i,j,i,j)=1;
%   end
% end
% S_tensor=0.5*(I_tensor+T_tensor);  % "symmetrizing" tensor
% S_flat=reshape(S_tensor,[n^2 n^2]);
% % okay, we can finally make S
% S=zeros(n+n^2);
% S(1:n,1:n)=eye(n);
% S(n+1:end,n+1:end)=S_flat;
% dYS=dY*S;
% now we can finally calc q
dY_rank=rank(dY)
p=pinv(dY)*df;
g=p(1:n)';  % want a row vector
H=reshape(p(n+1:end),[n n]);
H=0.5*(H+H');  % make symmetric (it's close already)


