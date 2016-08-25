function [Pxxs_os,f_os] = f(Pxxs_ts)

% turns a two-sided PSD into a one-sided
% works on the the cols of Pxx_ts
% doesn't work for ndims>3

% get the dims of Pxx_ts
[N,N_signals,K]=size(Pxxs_ts);

% fold the positive and negative frequencies together
% hpfi = 'highest positive frequency index'
% if N is even, drop the highest negative frequency index, since it
%   has no mate
hpfi=ceil(N/2);
if mod(N,2)==0  % if N_fft is even
  Pxxs_os=Pxxs_ts(1:hpfi,:,:) +...
          [zeros(1,N_signals,K) ; flipdim(Pxxs_ts(hpfi+2:N,:,:),1) ];
else  % if N_fft is odd
  Pxxs_os=Pxxs_ts(1:hpfi,:,:) + ...
          [zeros(1,N_signals,K) ; flipdim(Pxxs_ts(hpfi+1:N,:,:),1)];
end

% generate frequency base
f_os=(0:(hpfi-1))'/N;
