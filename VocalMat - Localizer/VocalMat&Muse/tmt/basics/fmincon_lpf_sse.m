function sse = f(theta,t,x,y_true)

% divide by scale factors
A_factor=1e2;
tau_factor=1e-3;

% break out theta
A=theta(1)/A_factor;
tau=theta(2)/tau_factor;

% calculate sse
sse=lpf_sse(A,tau,t,x,y_true);
