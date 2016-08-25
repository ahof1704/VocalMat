function [edges,n_highs,n_lows] = f(signal)

% signal is a logical signal of some kind, TTL or whatever
% edges is an array which is
% zero where there's no edge, +1 for a rising edge, and -1 for a falling
% edge.  the elements of edges correspond with the spaces between the
% elements of signal.  i.e. edge(i) tells about the edginess of the
% transition from signal(i) to signal(i+1).  thus edges is of length
% length(signal)-1

bool_signal=(signal>(min(signal)+max(signal))/2);
n_samples=max(size(signal));
bool_signal_shifted=bool_signal(2:n_samples);
edges=bool_signal_shifted-bool_signal(1:n_samples-1);
n_highs=sum(edges==1)+bool_signal(1);
n_lows=sum(edges==(-1))+(1-bool_signal(1));
