function [t,r]=times_to_rate_gaussian(dt,T,t0,ts,sigma_t)

N=round(T/dt);
T=N*dt;  % make sure dt and T are consistent
t=(t0:dt:t0+T-dt)';  % timeline
is=floor((ts-t0)/dt)+1;  % index into t of each spike
is(is>N)=N;  % in case there's a ts(i)==T
% r_proto=zeros([N 1]);
% r_proto(is)=1;
sigma_i=sigma_t/dt;
rad=2*ceil(4*sigma_i);
kernel=1/dt*gaussian_kernel_1d(sigma_i,2*rad+1);
n_events=length(ts);
r=zeros([N 1]);
for j=1:n_events
  i=is(j);
  i_first=i-rad;
  i_last=i+rad;
  % make sure i_first doesn't fall off edge
  if i_first>=1
    k_first=1;
  else
    k_first=1-i+rad+1;
    i_first=1;
  end
  % make sure i_last doesn't fall off edge
  if i_last<=N
    k_last=2*rad+1;
  else
    k_last=N-i+rad+1;
    i_last=N;
  end
  % add in the kernel in the right place
  r(i_first:i_last)=r(i_first:i_last)+kernel(k_first:k_last);
end
% r=convn(r_proto,kernel,'same');
