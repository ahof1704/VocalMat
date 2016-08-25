function [edges,n_highs,n_lows] = f(signal)

% This function is deprecated.  Use ttl_edges instead.

warning('find_edges is deprecated.  Use ttl_edges instead.');
[edges,n_highs,n_lows] = ttl_edges(signal);
