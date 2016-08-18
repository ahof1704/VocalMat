function y=f(x,template,i_origin_template)

% yes, I know, this is very slow
% x, template should be col vectors
n_x=length(x);
n_template=length(template);
if nargin<3
  % If i_origin_template is not given, choose the central element as
  % origin.  If n_template is even, there are two choices for the "central"
  % element.  We choose the one closer to the end, to be consistent with
  % conv1.
  i_origin_template=floor(n_template/2)+1;
end
x_padded=[zeros(i_origin_template-1,1) ; ...
          x ; ...
          zeros(n_template-i_origin_template,1)];
y=zeros(n_x,1);
for i=1:n_x
  x_this=x_padded(i:i+n_template-1);
  y(i)=sum((x_this-template).^2);
end
