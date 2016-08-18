function r=mouse_shape_from_ellipse(mu,a_vec,b)

% mu a vector indicating the center of the ellipse
% a_vec a vector pointing along the semi-major axis, with length
%   equal to the semi-major axis
% b a scalar, the length of the semi-minor axis

% draw the direllipse in the current axes
n_vertex=361;
phi=linspace(-pi,+pi,n_vertex);

% get the position vector for each vertex before rotation and scaling
a=norm(a_vec);
r_raw_body=zeros(2,n_vertex);
r_raw_body(1,:)=a*cos(phi);
r_raw_body(2,:)=b*sin(phi);

% make a tail
n_cycles_in_tail=0.4;
n_vertices_in_tail=20*n_cycles_in_tail;
tail_length=a;
tail_amplitude=a/8;
x_tail_super_raw=linspace(0,-tail_length,n_vertices_in_tail);
y_tail_super_raw=tail_amplitude*sin(2*pi*n_cycles_in_tail*(x_tail_super_raw/tail_length));
r_raw_tail=zeros(2,n_vertices_in_tail);
r_raw_tail(1,:)=-a+x_tail_super_raw;
r_raw_tail(2,:)=   y_tail_super_raw;

% attach the tail to the body
r_raw=[r_raw_body r_raw_tail];

% rotate the position vectors
a_hat=a_vec/a;
b_hat=[-a_hat(2);a_hat(1)];  % rotate +90 deg
M=[a_hat b_hat];
r_cent=M*r_raw;

% translate the position vectors, break out into x and y for each vertex
r=bsxfun(@plus,mu,r_cent);

end
