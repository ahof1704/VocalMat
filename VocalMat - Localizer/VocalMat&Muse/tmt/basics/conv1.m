function y=f(x,filt,shape,i_origin)

% deal w/ args
n_filt=length(filt);
if nargin<3
  shape='full';
end
if nargin<4
  % If i_origin is not given, assume central element is origin.
  % If n_filt is even, then there are two possible choices for the
  % "central" element.  We choose the one closer to the end, to be
  % consistent with conv2.
  i_origin=floor(n_filt/2)+1;
end
% do the actual convolution
y_proto=conv(x,filt);
% do the post-processing
shape=lower(shape);
if strcmp(shape,'samenan')
  % NaN out the invalid elements
  y_proto(1:n_filt-1)=NaN;
  y_proto(end-n_filt+2:end)=NaN;
end  
if strcmp(shape,'full')
  y=y_proto;
elseif strcmp(shape,'same') || strcmp(shape,'samenan')
  % We want the result to be s.t. the first element is the one you get when
  % the first element of x is lined up w/ the origin of the filter.  To do
  % this, we delete the right number of elements from the start and the end
  % of the full convolution
  n_delete_start=i_origin-1;
  n_delete_end=n_filt-i_origin;
  % delete n_delete_start els from start, n_delete_end els from end
  y=y_proto(n_delete_start+1:end-n_delete_end);
elseif strcmp(shape,'valid')
  y=y_proto(n_filt:end-n_filt+1);
else
  error('Unrecognized shape argument');
end
