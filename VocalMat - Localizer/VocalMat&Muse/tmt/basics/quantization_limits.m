function q_lim = f(d,method,varargin)

% this is a helper function used by many of the quantization
% functions.  The quantization functions are used to take an array of
% reals (encoded as doubles) and to quantize each element onto some
% discrete space, like uint8s.  Some of the quantization routines
% also convert reals into reals on some finite range, like [0,1) or
% [-1,+1).
%
% All quantization routines end up doing a linear (okay, affine)
% mapping from [q_min,q_max] onto the min and and max values in the
% quantized space.  This funtion determines q_min and q_max.  The
% values returned depend on the data, the chosen method (given as a
% strong), and possibly some optional arguments.  For instance, the
% 'min/max' returns the lowest element in d as q_min, and the highest
% as q_max.  The '5%/95%' method returns the 5th percentile as q_min,
% and the 95th percentile as q_max.  Other methods are documented
% below.

if nargin<2
  method='min/max';
end

switch method
  case 'min/max'
    q_min = min(d(:));
    q_max = max(d(:));
  case '-maxabs/+maxabs'
    % Takes the absolute value of all the elements in d, and assigns
    % the maximal one to q_max.  q_min=-q_max.
    q_max=max(abs(d(:)));
    q_min=-q_max;
  case '5%/95%'
    d_sorted=sort(d(:));
    n_els=prod(size(d));
    q_min=interp1(d_sorted,0.05*n_els);
    q_max=interp1(d_sorted,0.95*n_els);
  case 'percentile'
    % a generalization of '5%/95%'.  q_min is the (100*f_min)'th
    % percentile, and q_max is the (100*f_max)'th percentile.
    f_lim=varargin{1};
    f_min=f_lim(1); f_max=f_lim(2);
    d_sorted=sort(d(:));
    n_els=prod(size(d));
    q_min=interp1(d_sorted,f_min*n_els);
    q_max=interp1(d_sorted,f_max*n_els);
  case '90% symmetric'
    % takes the absolute value of all the elements in d.  q_max is
    % then the 90th percentile of the absolute-valued elements.
    % q_min=-q_max.
    d_abs_sorted=sort(abs(d(:)));
    n_els=prod(size(d));
    q_max=interp1(d_abs_sorted,0.90*n_els);
    q_min=-q_max;
  case 'percentile symmetric'
    % a generalization of '90% symmetric'.  q_max is the (100*f_max)'th
    % percentile of abs(d(:)).  q_min=-q_max.
    f_max=varargin{1};
    d_abs_sorted=sort(abs(d(:)));
    n_els=prod(size(d));
    q_max=interp1(d_abs_sorted,f_max*n_els);
    q_min=-q_max;
  case 'custom'
    % the user supplies her own q_min and q_max
    q_lim=varargin{1};
    q_min=q_lim(1); q_max=q_lim(2);
  otherwise
    error('unknown method');
end    
q_lim=[q_min q_max];

