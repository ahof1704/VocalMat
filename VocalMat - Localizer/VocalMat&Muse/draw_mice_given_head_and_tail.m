function draw_mice_given_head_and_tail(axes_handle,r_head,r_tail,z,clr,varargin)

% Draws mouse shapes into the given axes.  r_head and r_tail should be
% 2 x n_mice.  On return, line_handles will be n_mice x 1, and will hold the
% line handles.  z (optional) is a scalar and gives the z
% plane for all mouse lines.

n_mice=size(r_head,2);
if ~exist('z','var') || isempty(z) ,
  z=0;
end

if ~exist('clr','var') || isempty(clr) ,
  clr=zeros(n_mice,3);
end

r_center=(r_head+r_tail)/2;
a_vec=r_head-r_center;  % vectors in cols
a=normcols(a_vec);
b=a/2;  % 1 x n_mice, and a guess at the half-width of each mouse
theta=atan2(a_vec(2,:),a_vec(1,:));
line_handles=zeros(n_mice,1);
do_draw_center=false;
for i_mouse=1:n_mice
  mouse_body_alt(axes_handle, ...
                 [r_center(1,i_mouse) ...
                  r_center(2,i_mouse) ...
                  a(i_mouse) ...
                  b(i_mouse) ...
                  theta(i_mouse)], ...
                 z, ...
                 do_draw_center, ...
                 'color',clr(i_mouse,:), ...
                 varargin{:});
%   r_mouse_shape=mouse_shape_from_ellipse(r_center(:,i_mouse),a_vec(:,i_mouse),b(i_mouse));
%   n_points=size(r_mouse_shape,2);
%   z_but_bigger=repmat(z,[1 n_points]);
%   line_handles(i_mouse)= ...
%     line('parent',axes_handle, ...
%          'xdata',100*r_mouse_shape(1,:), ...
%          'ydata',100*r_mouse_shape(2,:), ...
%          'zdata',z_but_bigger, ...
%          'color','k');
end

end