function [ind,q_lim] = f(d,method,varargin)

% 'quantizes' the signal into the range [0,1].  Really, this
% function does normalization rather than quantization, but since
% it's used in many situations where quantization is also
% appropriate, we'll leave the name as-is

if nargin<2
  method='min/max';
end

q_lim=quantization_limits(d,method,varargin{:});
q_min=q_lim(1); q_max=q_lim(2);
ind=(d-q_min)/(q_max-q_min);  % q_min --> 0, q_max -->1, linear
ind=min(ind,1);  % truncate things that are out-of-range
ind=max(ind,0);
