function rate=f(t,ts,T_sigma)

[n_t,t0,tf,T,dt,fs]=time_info(t);
is=round((ts-t0)/dt)+1;
k=gaussian_kernel_1d(T_sigma/dt)/dt;
r_k=(length(k)-1)/2;  % should be an integer
rate=zeros(size(t));
for j=1:length(is)
  i_center=is(j);
  i_start=i_center-r_k;
  i_end=i_center+r_k;
  if i_start>=1
    if i_end<=n_t
      % safe on both ends
      rate(i_start:i_end)=rate(i_start:i_end)+k;
    else
      % safe at start, not at end
      n_k=n_t-i_start+1;
      rate(i_start:end)=rate(i_start:end)+k(1:n_k);
    end
  else
    if i_end<=n_t
      % safe at end, not at start
      n_k=i_end;
      rate(1:i_end)=rate(1:i_end)+k(end-n_k+1:end);
    else
      error('kernel is bigger than timeline!');
    end
  end
end


      

