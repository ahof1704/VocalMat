function [rout,g,b] = f(a,cm)

% based heavily on ind2rgb

if ~isa(a, 'double')
    a = double(a)+1;    % Switch to one based indexing
end

error(nargchk(2,2,nargin));

% quantize cm
cm=quantize_to_uint8(cm,'custom',0,1);

% Make sure A is in the range from 1 to size(cm,1)
a = max(1,min(a,size(cm,1)));

% Extract r,g,b components
% do it in such a way that we never create big double arrays
[n_rows,n_cols]=size(a);
r = uint8(zeros(1,1)); r(n_rows,n_cols)=0; r(:) = cm(a,1);
g = uint8(zeros(1,1)); g(n_rows,n_cols)=0; g(:) = cm(a,2);
b = uint8(zeros(1,1)); b(n_rows,n_cols)=0; b(:) = cm(a,3);

if nargout==3,
  rout = r;
else
  rout = uint8(zeros(1,1)); rout(n_rows,n_cols,3)=0;
  rout(:,:,1) = r;
  rout(:,:,2) = g;
  rout(:,:,3) = b;
end