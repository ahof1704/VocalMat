function [ind,q_lim] = f(d,method,varargin)

% 'quantizes' the signal into the range [-1,+1].  Really, this
% function does normalization rather than quantization, but since
% it's used in many situations where quantization is also
% appropriate, we'll leave the name as-is
if nargin<2
  method='-maxabs/+maxabs';
end

q_lim=quantization_limits(d,method,varargin{:});
q_min=q_lim(1); q_max=q_lim(2);
if q_min ~= -q_max
    warn('quantize_to_signed_double: Please be aware that the given q_min is ignored, and I assume that q_min=-q_max...');
end
ind=d/q_max;
% old way
%epsilon=1e-6;
%ind=(2-epsilon)*(d-q_min)/(q_max-q_min)-1;
ind=min(ind,+1);
ind=max(ind,-1);
