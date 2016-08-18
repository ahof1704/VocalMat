function [ind,q_lim] = f(d,method,varargin)

% takes an array of
% reals (encoded as doubles) and quantizes each element onto the
% uint8s.  Linearly maps the reals on [q_min,q_max] onto the integers
% on [0,255].  q_min and q_max are determined by the data, the method
% given, and possibly some optional arguments.  For the 'min/max'
% method, q_min is the least element in d, q_max is the greatest.
% Other methods more involved.  See docs for quantization_limits.

if nargin<2
  method='min/max';
end
q_lim=quantization_limits(d,method,varargin{:});
q_min=q_lim(1); q_max=q_lim(2);
n=8;
% changed to the 'modified horse sense' method 7/13/03
Q=2^n-1;
ind=uint8(round(Q*(d-q_min)/(q_max-q_min)));
% this is the old method -- see ~/notes/quantization.doc for more on this
%epsilon=1e-6;
%ind=uint8(floor((2^n-epsilon)*(d-q_min)/(q_max-q_min)));
