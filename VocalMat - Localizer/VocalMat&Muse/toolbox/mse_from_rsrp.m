function mse=mse_from_rsrp(rsrp,V_ss_per_mike,N,a)

% rsrp is n_r x 1, the reduced steered response power
% V_clip_ss is 1 x K, K the number of mics
%   it is the sum of squares of V_clip, summed only across freq
% a is 1 x K, and is the gain for each mic


A2=sum(a.^2);
sse= sum(V_ss_per_mike) - ...
     sum(a.^2 .* V_ss_per_mike)/A2 - ...
     2*N/A2*rsrp ;
% % all unity gain, reduces to:   
% sse=sum(V_clip_ss)-sum(V_clip_ss)/K-2*N/K*rsrp;
K=length(a);
mse=sse/(N^2*K);  % convert to time-domain SSE by dividing by N , and 
                  % then to MSE by dividing by N*K

end
