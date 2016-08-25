function [x,fx,n_line_mins,n_fun_evals,x_lm,f_lm,warm_last] = ...
    f(fun,x0,...
      tunable,...
      x_lb,x_ub,...
      f_tol,...
      x_tol_abs_line_search,...
      alpha0,...
      max_parabolic_mag_brak,...
      max_iters_brak,...
      max_iters_line_min,...
      max_iters_hds,...
      max_starts,...
      method,...
      warm,...
      verbosity,...
      varargin)
    
% convert fun to inline function as needed
fun = fcnchk(fun,length(varargin));

% see if we're doing a warm start
cold_start=isempty(warm);
warm_start=~cold_start;

% init the accounting vars
n_fun_evals=0;
n_line_mins=0;

% get dimensions, etc.
n=length(x0);
n_tunable=sum(double(tunable));
i_tunable=find(tunable);

% init stuff
x=x0;
fx=feval(fun,x,varargin{:});
n_fun_evals=n_fun_evals+1;

% init x_lm, f_lm, which store x and f and the end of each line min
x_lm=zeros(n,max_iters_hds*n_tunable+1);
f_lm=zeros(1,max_iters_hds*n_tunable+1);
i_lm=1;
x_lm(:,i_lm)=x;
f_lm(i_lm)=fx;
i_lm=i_lm+1;

% do restarts until done
really_converged=false;
for i_start=1:max_starts
  % init stuff for this restart
  converged=false;
  if i_start==1
    if warm_start
      % first start of warm start
      S_tunable=warm.S_tunable;
      x_pre=warm.x_pre;
      fx_pre=warm.fx_pre;
    else
      % first start of cold start
      S_tunable=eye(n_tunable);
    end
  else
    % second or later start
    % want a random basis
    % there's probably a better way to do this...
    S_tunable_proto=normrnd(0,1,n_tunable,n_tunable);
    [S_tunable,dummy]=qr(S_tunable_proto);
  end

  % init x_tunable_hess, f_hess, which store the set of function evaluations 
  % used to estimate the Hessian
  % we want to store the evals involved in n_tunable^2 line
  % minimizations
  n_lms_max=n_tunable^2;
  % n_lms_max=1+2*n_tunable+(n_tunable*(n_tunable-1))/2;
  %   % just enough to fully constraint the model function
  if ~( warm_start && i_start==1 )
    % normal case
    if strcmp(method,'fitting')
      x_tunable_hess=cell(n_lms_max,1);
      f_hess=cell(n_lms_max,1);
      n_lms_stored=0;
      i_lms=1;  % the next slot to store a set of line min evals in
    end
  else
    % first start of warm start
    if strcmp(method,'fitting')
      x_tunable_hess=warm.x_tunable_hess;
      f_hess=warm.f_hess;
      n_lms_stored=warm.n_lms_stored;
      i_lms=warm.i_lms;
    end
  end
  % loop -- each iter involves n_tunable orthogonal line minimizations
  for i=1:max_iters_hds

    % save the current vals, unless this is the first iter of a warm start
    if ~( warm_start && i_start==1 && i==1 )
      x_pre=x;  fx_pre=fx;
    end

    % do line minimizations along each var
    if ~( warm_start && i_start==1 && i==1 )
      j_vals=[1:n_tunable];
    else
      % i.e. if i_start==1, i==1, and it's a warm start
      % j_warm is the last j completed
      if warm.j<n_tunable
        j_vals=[warm.j+1:n_tunable];
      else
        j_vals=[1:n_tunable];
      end
    end

    % j indexes over vectors in the direction set
    for j=j_vals

      % set the search dir
      s=zeros(n,1);
      s(tunable)=S_tunable(:,j);

      % calc the step "length" -- the mult of s that minimizes f along s
      [a,fa,n_fun_evals_line_min,to_bound,...
       a_hess_this,f_hess_this]=...
        line_minimize(fun,x,s,...
                      fx,...
                      x_tol_abs_line_search,...
                      alpha0,...
                      max_parabolic_mag_brak,...
                      max_iters_brak,...
                      max_iters_line_min,...
                      x_lb,x_ub,...
                      i,j,...
                      verbosity,...
                      varargin{:});
      n_line_mins=n_line_mins+1;
      n_fun_evals=n_fun_evals+n_fun_evals_line_min;

      % update x, fx
      x=bound(x+a*s,x_lb,x_ub);
      fx=fa;

      % output stuff
      if verbosity>=1
        fprintf(1,'Iter: %3d     Var: %3d     ',i,i_tunable(j));
        fprintf(1,'Obj: %12.6f     ',fa);
        fprintf(1,'n_fun_evals_line_min: %3d\n',n_fun_evals_line_min);
      end

      % append to the per-line-min trace
      x_lm(:,i_lm)=x;
      f_lm(i_lm)=fx;
      i_lm=i_lm+1;

      % update the Hessian-related evals
      if strcmp(method,'fitting')
        x_tunable_hess_this=...
          bound(repmat(x,[1 length(a_hess_this)])+s*a_hess_this,...
                x_lb,...
                x_ub);
        x_tunable_hess{i_lms}=x_tunable_hess_this(tunable,:);
        f_hess{i_lms}=f_hess_this;
        if i_lms<n_lms_max
          i_lms=i_lms+1;
        else
          i_lms=1;  % wrap
        end
        if n_lms_stored<n_lms_max
          % if we haven't filled the circular buffer, update the number stored
          n_lms_stored=n_lms_stored+1;
        end
      end

      % save in case of crash
      if strcmp(method,'fitting')
        warm_last=struct('x_tunable_hess',{x_tunable_hess},...
                         'f_hess',{f_hess},...
                         'i_lms',i_lms,...
                         'n_lms_stored',n_lms_stored,...
                         'S_tunable',S_tunable,...
                         'j',j,...
                         'x_pre',x_pre,...
                         'fx_pre',fx_pre);
      else
        warm_last=struct('S_tunable',S_tunable,...
                         'j',j,...
                         'x_pre',x_pre,...
                         'fx_pre',fx_pre);
      end
      dir_out=dir;
      dir_filenames={dir_out.name};
      if any(strcmp('hds-last.mat',dir_filenames))
        copyfile('hds-last.mat','hds-last-last.mat');
      end
      save 'hds-last.mat' x fx x_pre fx_pre warm_last;

    end  % for j=1:n_tunable

    % check for convergence
    if ( (fx_pre-fx)<f_tol*(1+abs(fx)) && ...
         all(abs(x-x_pre)<sqrt(f_tol)*(1+abs(x)) ) )
      converged=true;
      break;
    end

    % modify S_tunable
    if strcmp(method,'powell')
      s_tunable_new=hat(x(tunable)-x_pre(tunable));
      % need to take into account the fact that some params may be
      % at bounds before we update the direction set
      free=tunable&(x~=x_lb)&(x~=x_ub);
      n_free=sum(free);
        % a param is free if it is tunable and not at a bound
      free_tunable=free(tunable);  % want free, but with n_tunable elements  
      S_free_new_proto=...
        [s_tunable_new(free_tunable) S_tunable(free_tunable,1:n_free-1)];
      [S_free_new,R_free_new]=qr(S_free_new_proto);
      S_tunable_new_proto=zeros(n_tunable,n_free);
      S_tunable_new_proto(free_tunable,:)=S_free_new;
      I_tunable=eye(n_tunable);
      S_tunable_new=[S_tunable_new_proto I_tunable(:,~free_tunable)];
      S_tunable=S_tunable_new;
    elseif strcmp(method,'fixed');
      % leave S_tunable alone
    elseif strcmp(method,'fitting')
      % fit a model of the function based on all the function evals stored
      % unpack all the x's, f's
      K=0;
      for l=1:n_lms_stored
        K=K+length(f_hess{l});
      end
      x_tunable_hess_flat=zeros(n_tunable,K);
      f_hess_flat=zeros(1,K);
      l_flat=1;
      for l=1:n_lms_stored
        n_evals_this=length(f_hess{l});
        x_tunable_hess_flat(:,l_flat:l_flat+n_evals_this-1)=x_tunable_hess{l};
        f_hess_flat(l_flat:l_flat+n_evals_this-1)=f_hess{l};
        l_flat=l_flat+n_evals_this;
      end
      x_sum=sum(x_tunable_hess_flat,2);
      f_sum=sum(f_hess_flat,2);
      X_sum=zeros(n_tunable,n_tunable);
      xX_vec_sum=zeros(n_tunable,n_tunable^2);
      X_vec_X_vec_sum=zeros(n_tunable^2,n_tunable^2);
      fx_sum=zeros(n_tunable,1);
      fX_vec_sum=zeros(n_tunable^2,1);
      for k=1:K
        x_k=x_tunable_hess_flat(:,k);
        X_k=x_k*x_k';  % outer prod
        X_sum=X_sum+X_k;
        X_k_vec=reshape(X_k,[n_tunable^2 1]);
        xX_vec_sum=xX_vec_sum+x_k*X_k_vec';
        X_vec_X_vec_sum=X_vec_X_vec_sum+X_k_vec*X_k_vec';
        fx_sum=fx_sum+f_hess_flat(k)*x_k;
        fX_vec_sum=fX_vec_sum+f_hess_flat(k)*X_k_vec;
      end
      X_vec_sum=reshape(X_sum,[n_tunable^2 1]);
      A_f=[ K          x_sum'       0.5*X_vec_sum'      ; ...
            x_sum      X_sum        0.5*xX_vec_sum      ; ...
            X_vec_sum  xX_vec_sum'  0.5*X_vec_X_vec_sum ];
      b_f=[ f_sum ; fx_sum ; fX_vec_sum ];
      A_f_star=pinv(A_f);
      cgH_tunable=A_f_star*b_f;
      c_tunable=cgH_tunable(1);
      g_tunable=cgH_tunable(2:n_tunable+1);
      H_tunable=reshape(cgH_tunable(n_tunable+2:end),[n_tunable n_tunable]);
      H_tunable=(H_tunable+H_tunable')/2;   % make symmetric
      % need to take into account the fact that some params may be
      % at bounds before we do the eigenanalysis
      free=tunable&(x~=x_lb)&(x~=x_ub);
        % a param is free if it is tunable and not at a bound
      free_tunable=free(tunable);  % want free, but with n_tunable elements  
      H_free=H_tunable(free_tunable,free_tunable);
      [S_free,Lambda]=eig(H_free);
      S_tunable=eye(n_tunable);
      S_tunable(free_tunable,free_tunable)=S_free;
      fprintf(1,'\n');  
    else
      error('Unknown method for updating direction set');
    end  % method switch
  end  % for i=1:max_iters_hds

  % check for _true_ convergence
  if converged && i==1
    % if i==1, it means convergence was acheived on the first hds iter --
    % i.e. no significant progress was made on the start.
    % Now that's convergence!
    really_converged=true;
    break;
  end
  
  % check for running out of hds iters
  if ~converged && i==max_iters_hds
    break;
  end
end
  
% trim the trace
n_lm=i_lm-1;
x_lm=x_lm(:,1:n_lm);
f_lm=f_lm(1:n_lm);

