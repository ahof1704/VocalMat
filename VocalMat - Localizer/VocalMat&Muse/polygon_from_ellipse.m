function r=polygon_from_ellipse(mu,a_vec,b)

% mu a vector indicating the center of the ellipse
% a_vec a vector pointing along the semi-major axis, with length
%   equal to the semi-major axis
% b a scalar, the length of the semi-minor axis

% draw the direllipse in the current axes
n_vertex=361;
phi=linspace(-pi,+pi,n_vertex);

% get the position vector for each vertex before rotation and scaling
a=norm(a_vec);
r_raw=zeros(2,n_vertex);
r_raw(1,:)=a*cos(phi);
r_raw(2,:)=b*sin(phi);

% rotate the position vectors
a_hat=a_vec/a;
b_hat=[-a_hat(2);a_hat(1)];  % rotate +90 deg
M=[a_hat b_hat];
r_cent=M*r_raw;

% translate the position vectors, break out into x and y for each vertex
r=bsxfun(@plus,mu,r_cent);

end
