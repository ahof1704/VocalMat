function [rms_err_rel,rms_err_abs,err_abs,err_rel]=...
  f(fh,x0,fx0,g,H,sigma,n_points,varargin)

% this compares the gradient+Hessian approximation to the actual function

err_abs=zeros(n_points,1);
err_rel=zeros(n_points,1);
n_dots_this_line=0;
for i=1:n_points
  dx=normrnd(zeros(size(x0)),repmat(sigma,size(x0)));
  x=x0+dx;
  fx=feval(fh,x,varargin{:});
  fx_est=fx0+g*dx+dx'*(H*dx);
  err_abs(i)=fx_est-fx;
  err_rel(i)=err_abs(i)/fx;
  fprintf(1,'.');
  n_dots_this_line=n_dots_this_line+1;
  if n_dots_this_line>=50
    fprintf(1,'\n');
    n_dots_this_line=0;
  end
end
fprintf(1,'\n\n');
rms_err_abs=sqrt(mean(err_abs.^2));
rms_err_rel=sqrt(mean(err_rel.^2));
