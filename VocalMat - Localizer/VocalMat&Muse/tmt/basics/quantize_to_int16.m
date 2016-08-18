function [ind,q_lim] = f(d,method,varargin)

if nargin<2
  method='-maxabs/+maxabs';
end

% note that q_lim(1) is pretty much ignored -- the 
% quantization is always symmetric
q_lim=quantization_limits(d,method,varargin{:});
q_min=q_lim(1);  q_max=q_lim(2);
if q_min ~= -q_max
    warn('quantize_to_int16: Please be aware that the given q_min is ignored, and I assume that q_min=-q_max (modulo the whole there-are-more-negative-than-positive int16s issue)...');
end
n=16;
Q=2^(n-1)-1;
ind=int16(round(Q/q_max*d));

% old version -- with a bug in it, to boot!
%epsilon=1e-6;
%ind=int16(floor((2^(n+1)-epsilon)*(d-q_min)/(q_max-q_min)-2^n));
