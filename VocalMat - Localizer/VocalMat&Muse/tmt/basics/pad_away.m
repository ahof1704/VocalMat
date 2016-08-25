function y=f(y_padded,n_endcap,n_reflect)

% this is a companion function to pad.m.  Once you've padded a signal
% and filtered it, this chops off the pad elements, so the output is
% the same size and in register with the original, unfiltered signal

y=y_padded(1+n_reflect*n_endcap:end-n_reflect*n_endcap,:);

