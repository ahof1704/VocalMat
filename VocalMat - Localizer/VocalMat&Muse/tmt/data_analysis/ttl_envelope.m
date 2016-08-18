function env = f(signal,n_env)

% signal is a logical signal of some kind, TTL or whatever

bool_signal=(signal>(min(signal)+max(signal))/2);
n_samples=length(signal);
env=zeros(size(bool_signal));
j=1;
while j<n_samples
  if bool_signal(j)
    env(j:min(j+n_env-1,n_samples))=1;
    j=j+n_env;
  else
    j=j+1;
  end
end
