function [alpha_1,alpha_a,alpha_2,f_1,f_a,f_2,n_f_evals] = ...
  f(fun,x,s,...
    fx,...
    x_lb,x_ub,...
    alpha0,...
    max_parabolic_mag,...
    max_iters_bracket,...
    alpha_lb,alpha_ub,...
    verbosity,...
    varargin)

% This is a function to bracket the minimum of the function
% fun along the line defined by the point x and the
% direction s.  varargin holds any constant arguments to
% fun (i.e. ones that aren't being minimized along).
% This function is based on mnbrak from Numerical Recipes in C.  
% On exit, alpha_1, alpha_a, and alpha_2 define multipliers of s which 
% bracket
% the minimum, and f_1, f_a, f_2 are the values of fun
% at these points.  Because this version takes into account possible bounds
% on s, the returned bracket can be one of two kinds: "conventional" or
% "unconventional".  For a conventional bracket, alpha_1<alpha_a<alpha_2, 
% and f_1>f_a<f_2,
% where I really do mean < and >, not >= and <=.  For an unconventional
% bracket, either alpha_lb==alpha_1==alpha_a<alpha_2 or 
% alpha_1<alpha_a==alpha_2==alpha_ub.  In this case, the f
% value for the bracket end which is at the bound will have the value +Inf,
% and f_a will hold the true value of f for that value of s.  Thus it will 
% still be true that f_1>f_a<f_2.  This bracket,
% though strange, can be handled appropriately by 
% line_minimize_given_bracket.
% The function assumes that alpha_lb<alpha_ub (strictly).
% 
% alpha_a is supposed to be an abbreviation for "alpha_anchor", "anchor" 
% being my word for the point in the interior of the bracket

% check args
if ~(alpha_lb<alpha_ub)
  error('alpha_lb must be strictly less than alpha_ub');
end

% need the golden ratio
golden_ratio=1.618034;

% Convert fun to inline function as needed
fun = fcnchk(fun,length(varargin));

% init the accounting stuff
n_f_evals=0;

% bracket the minimum
% the triple (alpha_1,alpha_a,alpha_2) is the bracket
alpha_1=0;
f_1=fx;
if verbosity>=2
  line(alpha_1,f_1,'color','k','linestyle','none','marker','o');
  drawnow;
end
alpha_a=alpha0;  % use the initial alpha supplied
if alpha_1==alpha_ub
  alpha_a=-alpha_a;
  if alpha_a<alpha_lb
    alpha_a=(alpha_lb+alpha_ub)/2;  % why not?
  end
  f_a=feval(fun,bound(x+alpha_a*s,x_lb,x_ub),varargin{:});
  n_f_evals=n_f_evals+1;
  if verbosity>=2
    if isfinite(f_a)
      line(alpha_a,f_a,'color','k','linestyle','none','marker','o');
    else
      line(alpha_a,f_1,'color','k','linestyle','none','marker','p');
    end      
    drawnow;
  end
  if f_a>f_1
    % we're "backed into a corner"
    % this means that we have enough to make a bracket already
    % have to swap things around so that alpha_1<alpha_a==alpha_2==alpha_ub
    [alpha_1,alpha_a]=deal(alpha_a,alpha_1);  % swap
    alpha_2=alpha_ub;
    [f_1,f_a]=deal(f_a,f_1);  % swap
    f_2=+Inf;
    if verbosity>=2
      line([alpha_2 alpha_2],[f_a f_1],...
           'color','k','linestyle','-','marker','none');  
      drawnow;
    end
    return;
  end 
elseif alpha_a>=alpha_ub
  alpha_a=alpha_ub;
  f_a=feval(fun,bound(x+alpha_a*s,x_lb,x_ub),varargin{:});
  n_f_evals=n_f_evals+1;
  if verbosity>=2
    if isfinite(f_a)
      line(alpha_a,f_a,'color','k','linestyle','none','marker','o');
    else
      line(alpha_a,f_1,'color','k','linestyle','none','marker','p');
    end      
    drawnow;
  end
  if f_a<f_1
    alpha_2=alpha_ub;
    f_2=+Inf;
    if verbosity>=2
      line([alpha_2 alpha_2],[f_a f_1],...
           'color','k','linestyle','-','marker','none');  
      drawnow;
    end  
    return;
  end
else
  f_a=feval(fun,bound(x+alpha_a*s,x_lb,x_ub),varargin{:});
  n_f_evals=n_f_evals+1;
  if verbosity>=2
    if isfinite(f_a)
      line(alpha_a,f_a,'color','k','linestyle','none','marker','o');
    else
      line(alpha_a,f_1,'color','k','linestyle','none','marker','p');
    end      
    drawnow;
  end  
end
% since we want the putative anchor in alpha_a, we swap alpha_1 and 
% alpha_a if f_1 is less than f_a
if (f_a>f_1)
  [alpha_1,alpha_a]=deal(alpha_a,alpha_1);
  [f_1,f_a]=deal(f_a,f_1);
end
% want a sub to plot for inf vals
f_subs=[f_1 f_a];
f_subs=f_subs(isfinite(f_subs));
f_sub=max(f_subs);

%
% now we're ready to look for alpha_2, which will be "past" alpha_a, 
% coming from alpha_1
%
% if alpha_a is at a bound, there's nowhere to go, so we return
% with an "unconventional" bracket
if (alpha_a==alpha_ub)||(alpha_a==alpha_lb)
  alpha_2=alpha_a;
  f_2=+Inf;
  if verbosity>=2
    line([alpha_2 alpha_2],[f_a f_1],...
         'color','k','linestyle','-','marker','none');  
    drawnow;
  end  
  % put things in order
  if alpha_1>alpha_2
    [alpha_1,alpha_2]=deal(alpha_2,alpha_1);
    [f_1,f_2]=deal(f_2,f_1);
  end
  return;
end
alpha_2=alpha_a+golden_ratio*(alpha_a-alpha_1);  % the putative alpha_2
alpha_2=max(alpha_lb,min(alpha_2,alpha_ub));  % constrain to the bounds
f_2=feval(fun,bound(x+alpha_2*s,x_lb,x_ub),varargin{:});
n_f_evals=n_f_evals+1;
if verbosity>=2
    if isfinite(f_2)
      line(alpha_2,f_2,'color','k','linestyle','none','marker','o');
    else
      line(alpha_2,f_sub,'color','k','linestyle','none','marker','p');
    end      
  drawnow;
end  
i=1;
while (f_a>=f_2)   % loop until we bracket
  % check that we haven't iterated too much
  if i>max_iters_bracket
    error('failed to bracket minimum');
  end
  % calc values used in the parabolic extrapolation
  r=(alpha_a-alpha_1)*(f_a-f_2);
  q=(alpha_a-alpha_2)*(f_a-f_1);
  % alpha_u is based on a parabolic extrapolation from 
  % alpha_1,alpha_a,alpha_2
  %   it is the point where f should be equal to f_a based on this
  %   extrapolation (I worked this out to check for sure)
  % we won't use a parabolic-fit point beyond alpha_u_lim
  alpha_u_lim=alpha_a+max_parabolic_mag*(alpha_2-alpha_a);
  if ((q-r)==0)
    alpha_u=alpha_u_lim;
  else
    alpha_u=alpha_a-((alpha_a-alpha_2)*q-(alpha_a-alpha_1)*r)/(2*(q-r));  
      % parabolic extrapolation
  end
  % depending on where alpha_u is relative to alpha_1, alpha_a, alpha_2, 
  % and alpha_u_lim, act accordingly
  if ((alpha_a-alpha_u)*(alpha_u-alpha_2)>0)
    % i.e. if alpha_u is between alpha_a and alpha_2
    f_u=feval(fun,bound(x+alpha_u*s,x_lb,x_ub),varargin{:});
    n_f_evals=n_f_evals+1;
    if verbosity>=2
    if isfinite(f_u)
      line(alpha_u,f_u,'color','k','linestyle','none','marker','o');
    else
      line(alpha_u,f_sub,'color','k','linestyle','none','marker','p');
    end      
      drawnow;
    end  
    if (f_u<f_2)  % this means (alpha_a,alpha_u,alpha_2) is a bracket
      alpha_1=alpha_a;
      f_1=f_a;
      alpha_a=alpha_u;
      f_a=f_u;
      break;
    elseif (f_u>f_a)  % this means (alpha_1,alpha_a,alpha_u) is a bracket 
      alpha_2=alpha_u;
      f_2=f_u;
      break;
    end
    % if we get to here, alpha_u is between alpha_a and alpha_2, and
    % f(alpha_u) is between f(alpha_a) and f(alpha_2)
    % This means alpha_u is of no use, so we use resort to
    % the golden mean magnification, and do the main
    % loop again
    alpha_u=alpha_2+golden_ratio*(alpha_2-alpha_a);
    if ((alpha_lb<=alpha_u)&&(alpha_u<=alpha_ub))
      f_u=feval(fun,bound(x+alpha_u*s,x_lb,x_ub),varargin{:});
      n_f_evals=n_f_evals+1;
      if verbosity>=2
        if isfinite(f_u)
          line(alpha_u,f_u,'color','k','linestyle','none','marker','o');
        else
          line(alpha_u,f_sub,'color','k','linestyle','none','marker','p');
        end
        drawnow;
      end
    else
      alpha_u=max(alpha_lb,min(alpha_u,alpha_ub));
      f_u=+Inf;
      if verbosity>=2
        line([alpha_u alpha_u],[f_a f_1],...
             'color','k','linestyle','-','marker','none');  
        drawnow;
      end  
    end
  elseif ((alpha_2-alpha_u)*(alpha_u-alpha_u_lim)>0)  
    % i.e. alpha_u is between alpha_2 and alpha_u_lim
    if ((alpha_lb<=alpha_u)&&(alpha_u<=alpha_ub))
      % alpha_u is within the bounds
      f_u=feval(fun,bound(x+alpha_u*s,x_lb,x_ub),varargin{:});
      n_f_evals=n_f_evals+1;
      if verbosity>=2
        if isfinite(f_u)
          line(alpha_u,f_u,'color','k','linestyle','none','marker','o');
        else
          line(alpha_u,f_sub,'color','k','linestyle','none','marker','p');
        end
        drawnow;
      end
    else
      % alpha_u is out-of-bounds
      alpha_u=max(alpha_lb,min(alpha_u,alpha_ub));  
        % limit alpha_u to the bounds
      f_u=+Inf;
      if verbosity>=2
        line([alpha_u alpha_u],[f_a f_1],...
             'color','k','linestyle','-','marker','none');
        drawnow;
      end
    end
    if (f_u<f_2)  % i.e. (alpha_a,alpha_2,alpha_u) is _not_ a bracket
      % In this case, we set things up so that 
      % (alpha_2,alpha_u,alpha_2+goldenRatio*(alpha_2-alpha_a)) is the 
      % proto-bracket for the next round
      alpha_a=alpha_2; 
      alpha_2=alpha_u;
      alpha_u=alpha_2+golden_ratio*(alpha_2-alpha_a);
      f_a=f_2; f_2=f_u;
      if ((alpha_lb<=alpha_u)&&(alpha_u<=alpha_ub))
        f_u=feval(fun,bound(x+alpha_u*s,x_lb,x_ub),varargin{:});
        n_f_evals=n_f_evals+1;
        if verbosity>=2
          if isfinite(f_u)
            line(alpha_u,f_u,'color','k','linestyle','none','marker','o');
          else
            line(alpha_u,f_sub,'color','k','linestyle','none','marker','p');
          end
          drawnow;
        end
      else
        alpha_u=max(alpha_lb,min(alpha_u,alpha_ub));
        f_u=+Inf;
        if verbosity>=2
          line([alpha_u alpha_u],[f_a f_1],...
               'color','k','linestyle','-','marker','none');
          drawnow;
        end
      end
    end
  elseif ((alpha_u-alpha_u_lim)*(alpha_u_lim-alpha_2)>=0)  
    % i.e. alpha_u is beyond alpha_u_lim
    % Reign in alpha_u to alpha_u_lim, loop again
    alpha_u=alpha_u_lim;
    if ((alpha_lb<=alpha_u)&&(alpha_u<=alpha_ub))
      f_u=feval(fun,bound(x+alpha_u*s,x_lb,x_ub),varargin{:});
      n_f_evals=n_f_evals+1;
      if verbosity>=2
        if isfinite(f_u)
          line(alpha_u,f_u,'color','k','linestyle','none','marker','o');
        else
          line(alpha_u,f_sub,'color','k','linestyle','none','marker','p');
        end
        drawnow;
      end
    else
      alpha_u=max(alpha_lb,min(alpha_u,alpha_ub));
      f_u=+Inf;
      if verbosity>=2
        line([alpha_u alpha_u],[f_a f_1],...
             'color','k','linestyle','-','marker','none');
        drawnow;
      end
    end
  else  % i.e. alpha_u is 'behind' alpha_a
    % Set alpha_u to golden section search value
    alpha_u=alpha_2+golden_ratio*(alpha_2-alpha_a);
    if ((alpha_lb<=alpha_u)&&(alpha_u<=alpha_ub))
      f_u=feval(fun,bound(x+alpha_u*s,x_lb,x_ub),varargin{:});
      n_f_evals=n_f_evals+1;
      if verbosity>=2
        if isfinite(f_u)
          line(alpha_u,f_u,'color','k','linestyle','none','marker','o');
        else
          line(alpha_u,f_sub,'color','k','linestyle','none','marker','p');
        end
        drawnow;
      end
    else
      alpha_u=max(alpha_lb,min(alpha_u,alpha_ub));
      f_u=+Inf;
      if verbosity>=2
        line([alpha_u alpha_u],[f_a f_1],...
             'color','k','linestyle','-','marker','none');
        drawnow;
      end
    end
  end
  % If we get here, we haven't found an acceptable bracket this round
  % Also, at this point alpha_u will be past alpha_2, so 
  % (alpha_a,alpha_2,alpha_u) is our bracket for the next round
  alpha_1=alpha_a;  alpha_a=alpha_2;  alpha_2=alpha_u;
  f_1=f_a;  f_a=f_2;  f_2=f_u;
  % update counter
  i=i+1;
end

% we want alpha_1<alpha_2, so make this true
% it should never happen that alpha_1==alpha_2 at this point
if alpha_1>alpha_2
  [alpha_1,alpha_2]=deal(alpha_2,alpha_1);
  [f_1,f_2]=deal(f_2,f_1);
end

% if one of the bracket bounds is at one of the bounds bounds, want to 
% evaluate the function at that bound, and modify the bracket appropriately
if alpha_1==alpha_lb
  f_lb=feval(fun,bound(x+alpha_lb*s,x_lb,x_ub),varargin{:});
  n_f_evals=n_f_evals+1;
  if verbosity>=2
    if isfinite(f_lb)
      line(alpha_lb,f_lb,'color','k','linestyle','none','marker','o');
    else
      line(alpha_lb,f_sub,'color','k','linestyle','none','marker','p');
    end
    drawnow;
  end
  if f_lb<=f_a
    % want alpha_lb to be the anchor, with f_lb as its value
    % alpha_1 stays at alpha_lb, but with the "placeholder" function
    % value of +Inf
    alpha_a=alpha_lb;
    f_a=f_lb;
  else
    % turns out we can make a normal bracket, with alpha_lb at one end, and
    % with no infinities anywhere
    f_1=f_lb;
  end
elseif alpha_2==alpha_ub
  f_ub=feval(fun,bound(x+alpha_ub*s,x_lb,x_ub),varargin{:});
  n_f_evals=n_f_evals+1;
  if verbosity>=2
    if isfinite(f_ub)
      line(alpha_ub,f_ub,'color','k','linestyle','none','marker','o');
    else
      line(alpha_ub,f_sub,'color','k','linestyle','none','marker','p');
    end
    drawnow;
  end
  if f_ub<=f_a
    % want alpha_ub to be the anchor, with f_ub as its value
    % alpha_2 stays at alpha_ub, but with the "placeholder" function
    % value of +Inf
    alpha_a=alpha_ub;
    f_a=f_ub;
  else
    % turns out we can make a normal bracket, with alpha_ub at one end, and
    % with no infinities anywhere
    f_2=f_ub;
  end
end
