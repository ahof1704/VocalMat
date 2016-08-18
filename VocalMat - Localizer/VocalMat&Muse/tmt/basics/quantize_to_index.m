function [ind,q_lim] = f(d,n_indices,method,varargin)

% takes an array of
% reals (encoded as doubles) and quantizes each element onto the
% range 1..n_indices.  Linearly maps the reals on [q_min,q_max] onto 
% the integers
% on [1,n_indices].  q_min and q_max are determined by the data, the method
% given, and possibly some optional arguments.  For the 'min/max'
% method, q_min is the least element in d, q_max is the greatest.
% Other methods more involved.  See docs for quantization_limits.

if nargin<2
  method='min/max';
end
q_lim=quantization_limits(d,method,varargin{:});
q_min=q_lim(1); q_max=q_lim(2);
% new method -- 7/16/03
ind=round((n_indices-1)*(d-q_min)/(q_max-q_min))+1;

% epsilon=1e-6;
% ind=floor((n_indices-1-epsilon)*(d-q_min)/(q_max-q_min))+1;
ind(ind>n_indices)=n_indices;
ind(ind<1)=1;

