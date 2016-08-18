function X_padded=pad_at_high_freqs(X,N_padded)

% This is used to do sinc interpolation in the freq domain.  Basically, 
% we pad X with lots of zeros and very high pos freqs and very high-magnitude 
% neg freqs, producing an output with N_padded elements.

% we assume X has the DC component in element 1, as is usual

N=length(X);
r=(N_padded/N);
N_nonneg=ceil(N/2);  % number of elements at nonnegative freqs
N_neg=N-N_nonneg;
X_nonneg_freq=X(1:N_nonneg);
X_neg_freq=X(N_nonneg+1:end);

X_padded=zeros(N_padded,1);
X_padded(1:N_nonneg)=r*X_nonneg_freq;  
X_padded(end-N_neg+1:end)=r*X_neg_freq;
  % have to scale by r b/c of the (1/N) factor when you do ifft()
  
end
