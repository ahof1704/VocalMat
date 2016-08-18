function [f,t,x_mean,P,x_mean_ci,P_ci,...
          N_fft,f_res_diam,K]=...
  powgram_mt(dt,x,T_window_want,dt_window_want,NW,K_want,F,...
             p_FFT_extra,conf_level)

% we assume x is a col vector of length N_total                      
                      
% On return:        
%   f is of shape [N_f 1]
%   t is of shape [n_windows 1]
%   x_mean is of shape [n_windows 1]
%   P is of shape [N_f n_windows]
%   x_mean_ci is of shape [n_windows 2]
%   P_ci is of shape [N_f n_windows 2]

% deal with args
if nargin<8 || isempty(p_FFT_extra)
  p_FFT_extra=2;
end
if nargin<9 || isempty(conf_level)
  conf_level=0;
end

% get dimensions
N_total=length(x);

% convert window size from time to elements 
N_window=round(T_window_want/dt);  % number of samples per window
di_window=round(dt_window_want/dt);
n_windows=floor((N_total-N_window)/di_window+1);  
  % n_windows is number of windows that will fit

% calculate realized T_window, dt_window
T_window=dt*N_window;
dt_window=dt*di_window;
  
% truncate data so we have integer number of windows
N_total=(n_windows-1)*di_window+N_window;
x=x(1:N_total);

% alloc the time base (these are the centers of each window)
i_t=zeros(n_windows,1);

% % figure out the dimensions of the output
% % will be N_f x n_windows
% N_fft=2^(ceil(log2(N_window))+p_FFT_extra);
% df=1/(N_fft*dt);
% N_f=ceil(F/df)+1;
% F=(N_f-1)*df;  % make consistent

% do it
x_mean=zeros(n_windows,1);
if conf_level>0
  x_mean_ci=zeros(n_windows,2);
else
  x_mean_ci=[];
end  
for j=1:n_windows
  i_start=(j-1)*di_window+1;
  i_end=i_start+N_window-1;
  i_t(j)=(i_start+i_end)/2-1;  % want zero-based
  x_this=x(i_start:i_end);
  x_this_mean=mean(x_this,1);
  x_this_cent=x_this-repmat(x_this_mean,[N_window 1]);
  [f,...
   P_this,...
   N_fft,f_res_diam,K,...
   P_ci_this]=...
    pow_mt(dt,x_this_cent,...
           NW,K_want,F,...
           p_FFT_extra,conf_level);  
  if j==1
    N_f=length(f);
    P=zeros(N_f,n_windows);
    if conf_level>0
      P_ci=zeros(N_f,n_windows,2);
    else
      P_ci=[];
    end
  end
  x_mean(j,:)=x_this_mean;
  P(:,j)=P_this;
  if conf_level>0
    x_this_mean_se=sqrt(0.5*P_this(1)/T_window);
      % P&W p189.  This is only an approx, but I don't know what else to 
      % use...
    ci_factor=norminv((1+conf_level)/2);
      % Seems like I should be using a T, not a normal, but I'm not clear
      % on how many degrees of freedom I'd use...
    x_mean_ci(j,1)=x_this_mean-ci_factor*x_this_mean_se;
    x_mean_ci(j,2)=x_this_mean+ci_factor*x_this_mean_se;
    P_ci(:,j,:)=P_ci_this;
  end
end
t=dt*i_t;
