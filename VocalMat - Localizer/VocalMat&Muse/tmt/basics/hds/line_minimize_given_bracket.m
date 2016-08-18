function [alpha_min,f_min,n_f_evals,alpha_evals,f_evals] = ...
  f(fun,x0,s,...
    alpha_1,alpha_a,alpha_2,...
    f_1,f_a,f_2,...
    alpha_lb,alpha_ub,...
    x_lb,x_ub,...
    x_tol,...
    max_iters,...
    verbosity,...
    varargin)

% This function does line minimization using Brent's algorithm
% fun is the objective function
% x0 is the origin point of the line search
% s is the direction in which the search is being done
% alpha_1, alpha_a, and alpha_2 are scaling factors for s that
%     bracket the line minimum initially
% x_rel_tol is the relative tolerance on the line minimum
% x_scale (a vector) sets the scale of "typical" x's.  For example, if 
%     the change in x between two iterations is dx, and one of the x's is
%     x0, then dx_rel=dx/max(abs(x0),x_scale) is the expression we 
%     would typically use for the relative change in f
% max_iters is the maximum number of iterations to do before giving up

% Convert fun to inline function as needed
fun = fcnchk(fun,length(varargin));

% need 1-1/golden_ratio
c_golden=0.381966;

% plot the initial bracket, if called for
if verbosity>=2
  f_subs=[f_1 f_a f_2];
  f_subs=f_subs(isfinite(f_subs));
  f_sub=max(f_subs);
  if isfinite(f_1)
    line(alpha_1,f_1,'color','r','linestyle','none','marker','o');
  else
    line(alpha_1,f_sub,'color','r','linestyle','none','marker','p');
  end
  line(alpha_a,f_a,'color','r','linestyle','none','marker','o');
  if isfinite(f_2)
    line(alpha_2,f_2,'color','r','linestyle','none','marker','o');
  else
    line(alpha_2,f_sub,'color','r','linestyle','none','marker','p');
  end
  drawnow;
end

% init accounting vars
n_f_evals=0;
alpha_evals=zeros(0,1);
f_evals=zeros(0,1);

% want (alpha_neg,alpha_pos) to be the bracket, w/ alpha_neg<alpha_pos
if (alpha_1<alpha_2)
  alpha_neg=alpha_1;  alpha_pos=alpha_2;
else
  alpha_neg=alpha_2;  alpha_pos=alpha_1;
end  

% action starts here 
alpha_min=alpha_a;  alpha_2nd=alpha_a;  alpha_2nd_prev=alpha_a;
f_min=f_a;
f_2nd=f_min; f_2nd_prev=f_min;
dalpha_penult=0;  
  % dalpha_penult will be the distance moved on the step before last
temp=warning('query','MATLAB:divideByZero');
divbyzero_pre=temp.state;
warning off MATLAB:divideByZero;
  % some elements of s may be zero, but the
  % min() gets rid of the Infs that
  % result
alpha_tol=min(x_tol./abs(s));
warning(divbyzero_pre,'MATLAB:divideByZero');
n_iters=0;  % number of iterations completed so far
while true
  alpha_mid=(alpha_neg+alpha_pos)/2;  % need the midpoint of the bracket
  %x_min=x0+alpha_min*s;
  dalpha=abs(alpha_min-alpha_mid)+(alpha_pos-alpha_neg)/2;
  if ( dalpha<2*alpha_tol )
    % this is the normal exit point -- f_min is aleady set to the min
%     if alpha_min==0  && alpha_lb~=0 && alpha_ub~=0 
%       warning('Jittering line_minimize_given_bracket() return value...');
%       alpha_min=rand(1)*(alpha_pos-alpha_neg)+alpha_neg;
%       f_min=feval(fun,bound(x0+alpha_min*s,x_lb,x_ub),varargin{:});
%       alpha_evals(end+1)=alpha_min;
%       f_evals(end+1)=f_min;
%       n_f_evals=n_f_evals+1;
%     end
    if verbosity>=2
      line(alpha_min,f_min,...
           'color',[0.5 0 0.75],'linestyle','none','marker','+');
    end
    break;
  end
  % this tests whether conditions are good for trying a parabolic step
  if (abs(dalpha_penult)>alpha_tol)
    % construct a trial parabolic fit
    r=(alpha_min-alpha_2nd)*(f_min-f_2nd_prev);
    q=(alpha_min-alpha_2nd_prev)*(f_min-f_2nd);
    p=(alpha_min-alpha_2nd_prev)*q-(alpha_min-alpha_2nd)*r;
    q=2*(q-r);
    if (q>0) p=(-p); end
    q=abs(q);
    dalpha_penult_temp=dalpha_penult;
    dalpha_penult=d;
    % test whether the parabolic fit is good
    if isnan(p) || isnan(q) || abs(p)>=abs(0.5*q*dalpha_penult_temp) || ...
       (p<=q*(alpha_neg-alpha_min)) || (p>=q*(alpha_pos-alpha_min))
      % parabolic fit no good, do a golden section step
      if (alpha_min>=alpha_mid)
        dalpha_penult=alpha_neg-alpha_min;
      else
        dalpha_penult=alpha_pos-alpha_min;
      end
      d=c_golden*dalpha_penult;
    else
      % parabolic fit is good, use it
      d=p/q;
      alpha_probe=alpha_min+d;
      if ( (alpha_probe-alpha_neg<2*alpha_tol) || ...
           (alpha_pos-alpha_probe<2*alpha_tol) )
        d=abs(alpha_tol)*sign(alpha_mid-alpha_min);
      end
    end
  else
    % don't even try a parabolic step
    if (alpha_min>=alpha_mid)
      dalpha_penult=alpha_neg-alpha_min;
    else
      dalpha_penult=alpha_pos-alpha_min;
    end
    d=c_golden*dalpha_penult;
  end
  % this checks to make sure we're not doing a function eval very close
  % to alpha_min, which would be wasteful
  if (abs(d)>=alpha_tol)
    alpha_probe=alpha_min+d;
  else
    alpha_probe=alpha_min+abs(alpha_tol)*sign(d);
  end
  % eval the function
  if isnan(alpha_probe)
    error('alpha_probe is NaN');
  end
  f_probe=feval(fun,bound(x0+alpha_probe*s,x_lb,x_ub),varargin{:});
  alpha_evals(end+1)=alpha_probe;
  f_evals(end+1)=f_probe;
  n_f_evals=n_f_evals+1;
  if verbosity>=2
    if isfinite(f_probe)
      line(alpha_probe,f_probe,'color','b','linestyle','none','marker','.');
    else
      line(alpha_probe,f_sub,'color','b','linestyle','none','marker','p');
    end
    drawnow;
  end

  % now decide how to modify the bracket, given f_probe
  if (f_probe<=f_min)
    % alpha_probe is the best point found so far, so alpha_min becomes one of
    % the bracket borders, and alpha_probe becomes the new alpha_min
    if (alpha_probe>=alpha_min)
      alpha_neg=alpha_min;
    else
      alpha_pos=alpha_min;
    end
    % housekeeping
    alpha_2nd_prev=alpha_2nd; alpha_2nd=alpha_min; alpha_min=alpha_probe;
    f_2nd_prev=f_2nd; f_2nd=f_min; f_min=f_probe;
  else
    % alpha_min is better than alpha_probe, so alpha_probe becomes one of the
    % bracket borders
    if (alpha_probe<alpha_min)
      alpha_neg=alpha_probe;
    else
      alpha_pos=alpha_probe;
    end
    % housekeeping
    if ( (f_probe<=f_2nd) || (alpha_2nd==alpha_min) )
      alpha_2nd_prev=alpha_2nd;
      alpha_2nd=alpha_probe;
      f_2nd_prev=f_2nd;
      f_2nd=f_probe;
    elseif ( (f_probe<=f_2nd_prev) || ...
             (alpha_2nd_prev==alpha_min) || ...
             (alpha_2nd_prev==alpha_2nd) ) 
      alpha_2nd_prev=alpha_probe;
      f_2nd_prev=f_probe;
    end
  end
  % update the number of iterations, error if too many
  n_iters=n_iters+1;
  if n_iters==max_iters
    error('Too many iterations in line_minimize_given_bracket');
  end
end  % while true

