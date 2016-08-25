function [alpha_min,f_min,n_f_evals,to_bound,alpha_evals,f_evals] = ...
    f(fun,x,s,...
      fx,...
      x_tol,...
      alpha0,...
      max_parabolic_mag_brak,...
      max_iters_brak,...
      max_iters,...
      x_lb,x_ub,...
      i_iter_major,...
      i_iter_minor,...
      verbosity,...
      varargin)

% calculate bounds on alpha, the multiplier of s ("step length")
temp=warning('query','MATLAB:divideByZero');
divbyzero_pre=temp.state;
warning off MATLAB:divideByZero;
  % some elements of s may be zero, but 
  % it doesn't matter if some of the bounds are at Inf
alpha_at_x_lb=(x_lb-x)./s;
alpha_at_x_ub=(x_ub-x)./s;
warning(divbyzero_pre,'MATLAB:divideByZero');
alpha_lb_each=min(alpha_at_x_lb,alpha_at_x_ub);
alpha_ub_each=max(alpha_at_x_lb,alpha_at_x_ub);
alpha_lb_each(s==0)=-Inf;
alpha_ub_each(s==0)=+Inf;
[alpha_lb,i_alpha_lb]=max(alpha_lb_each);
[alpha_ub,i_alpha_ub]=min(alpha_ub_each);

% set up for plotting, if appropriate
if verbosity>=2
  figure;
  axes;
  xlabel('\alpha');
  ylabel('Objective');
  if isempty(i_iter_minor)
    title(sprintf('Maj Iter: %d',i_iter_major));
  else
    title(sprintf('Maj Iter: %d, Min iter: %d',...
                  i_iter_major,i_iter_minor));
  end
  drawnow;
end

% check to see if the bracket is degenerate
if alpha_lb==alpha_ub
  % if it is, nothing to do
  alpha_min=0;
  f_min=fx;
  n_f_evals=0;
  to_bound=false(size(x));
  alpha_evals=zeros(1,0);
  f_evals=zeros(1,0);
  return;
end

% bracket the minimum
[alpha_lo,alpha_anchor,alpha_hi,...
 f_lo,f_anchor,f_hi,...
 n_f_evals_bracket]=...
    bracket_line_minimum(fun,x,s,...
                         fx,...
                         x_lb,x_ub,...
                         alpha0,...
                         max_parabolic_mag_brak,...
                         max_iters_brak,...
                         alpha_lb,alpha_ub,...
                         verbosity,...
                         varargin{:});

% given an initial bracket, shrink it until the tolerance is satisfied
[alpha_min,f_min,n_f_evals_line_min,alpha_evals_lm,f_evals_lm]=...
    line_minimize_given_bracket(fun,x,s,...
                                alpha_lo,alpha_anchor,alpha_hi,...
                                f_lo,f_anchor,f_hi,...
                                alpha_lb,alpha_ub,...
                                x_lb,x_ub,...
                                x_tol,...
                                max_iters,...
                                verbosity,...
                                varargin{:});
                              
% account for the function evals
n_f_evals=n_f_evals_bracket+n_f_evals_line_min;
  % this is generally >= length(f_evals), since evals outside the
  % bracket aren't returned
alpha_evals=[alpha_lo alpha_anchor alpha_hi alpha_evals_lm];
f_evals=[f_lo f_anchor f_hi f_evals_lm];
ok=isfinite(f_evals);
alpha_evals=alpha_evals(ok);
f_evals=f_evals(ok);

% figure out if any var is at the limiting bound that wasn't there before
to_bound=false(size(x));
if alpha_min~=0
  if alpha_min==alpha_lb
    to_bound(i_alpha_lb)=true;
  elseif alpha_min==alpha_ub
    to_bound(i_alpha_ub)=true;  
  end
end

% % plot the bracket and the function values along it
% if verbosity>=10
%   n_samps=50;
%   alpha=alpha_lo+(alpha_hi-alpha_lo)*linspace(0,1,n_samps);
%   f_alpha=zeros(size(alpha));
%   for j=1:n_samps
%     x_this=x+s*alpha(j);
%     f_alpha(j)=feval(fun,bound(x_this,x_lb,x_ub));
%   end
%   a_min=(x_min-x)'*s;
%   figure;
%   plot(alpha,f_alpha,'.');
%   hold on;
%   if ((alpha_lo<=alpha_lb)&&(alpha_lb<=alpha_hi))
%     plot([alpha_lb alpha_lb],[min(f_alpha) max(f_alpha)],'k');
%   end
%   if ((alpha_lo<=alpha_ub)&&(alpha_ub<=alpha_hi))
%     plot([alpha_ub alpha_ub],[min(f_alpha) max(f_alpha)],'k');
%   end
%   if isfinite(f_lo)
%     plot(alpha_lo,f_lo,'ro');
%   else
%     plot(alpha_lo,max(f_alpha),'ko');
%   end
%   plot(alpha_anchor,f_anchor,'co');
%   if isfinite(f_hi)
%     plot(alpha_hi,f_hi,'ro');
%   else
%     plot(alpha_hi,max(f_alpha),'ko');
%   end
%   plot(alpha_min,f_min,'go');
%   hold off;
% end
