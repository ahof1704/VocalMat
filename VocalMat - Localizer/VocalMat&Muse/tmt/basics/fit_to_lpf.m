function [A,tau,y_fit,success]=f(A_0,tau_0,t,x,y_true,options)

% multiply by scale factors to make everything around unity
A_factor=1e2;
tau_factor=1e-3;
theta_0=[A_factor*A_0;tau_factor*tau_0];
[theta,dummy,exitflag]=fmincon('fmincon_lpf_sse',theta_0,...
                               [],[],...  % linear inequlaity constraint
                               [],[],...  % linear equality constraint
                               [-Inf 0.1],[],...  % lower, upper bounds
                               [],...     % nonlin (in)equality constraints
                               options,...  % options
                               t,x,y_true);      % parameters passed directly

if (exitflag>0)
  success=logical(1);
  A=theta(1)/A_factor;
  tau=theta(2)/tau_factor;
  y_fit=lpf(A,tau,t,x);
else
  success=logical(0);
  A=NaN;
  tau=NaN;
  y_fit=repmat(NaN,size(x));
end
