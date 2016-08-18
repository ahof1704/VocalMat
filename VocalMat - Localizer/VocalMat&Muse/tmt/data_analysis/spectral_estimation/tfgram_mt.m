function [f,t,Hyx_mag,Hyx_phase,Hyx_mag_ci,Hyx_phase_ci,...
          N_fft,f_res_diam,K]=...
  tfgram_mt(dt,y,x,...
            T_window_want,dt_window_want,...
            NW,K_want,F,...
            p_FFT_extra,conf_level)

% we assume x,y are col vectors each of length N_total                      
                      
% On return:        
%   f is of shape [N_f 1]
%   t is of shape [n_windows 1]
%   Hyx_mag is of shape [N_f n_windows]
%   Hyx_phase is of shape [N_f n_windows]
%   Hyx_mag_ci is of shape [N_f n_windows 2]
%   Hyx_phase_ci is of shape [N_f n_windows 2]

% deal with args
if nargin<9 || isempty(p_FFT_extra)
  p_FFT_extra=2;
end
if nargin<10 || isempty(conf_level)
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

% do it
for j=1:n_windows
  i_start=(j-1)*di_window+1;
  i_end=i_start+N_window-1;
  i_t(j)=(i_start+i_end)/2-1;  % want zero-based
  x_this=x(i_start:i_end);
  y_this=y(i_start:i_end);
  x_this_mean=mean(x_this);
  y_this_mean=mean(y_this);
  x_this_cent=x_this-x_this_mean;
  y_this_cent=y_this-y_this_mean;  
  [f,...
   Hyx_mag_this,Hyx_phase_this,...
   N_fft,f_res_diam,K,...
   Hyx_mag_ci_this,Hyx_phase_ci_this]=...
    tf_mt(dt,y_this_cent,x_this_cent,...
          NW,K_want,F,...
          p_FFT_extra,conf_level);
  if j==1
    N_f=length(f);
    Hyx_mag=zeros(N_f,n_windows);
    Hyx_phase=zeros(N_f,n_windows);
    if conf_level>0
      Hyx_mag_ci=zeros(N_f,n_windows,2);
      Hyx_phase_ci=zeros(N_f,n_windows,2);
    else
      Hyx_mag_ci=[];
      Hyx_phase_ci=[];
    end  
  end    
  Hyx_mag(:,j)=Hyx_mag_this;
  Hyx_phase(:,j)=Hyx_phase_this;
  if conf_level>0
    Hyx_mag_ci(:,j,:)=Hyx_mag_ci_this;
    Hyx_phase_ci(:,j,:)=Hyx_phase_ci_this;
  end
end
t=dt*i_t;
