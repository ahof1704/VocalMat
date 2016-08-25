function h=fnDrawDirellipse(de,varargin)

% de a "directed ellipse", a 5x1 vector with elements x, y, a, b, theta, 
% in that order

% unpack direllipse
x=de(1);
y=de(2);
a=de(3);
b=de(4);
theta=de(5);

% draw the direllipse in the current axes
nVertex=61;
phi=linspace(-pi,+pi,nVertex);

% get the position vector for each vertex before rotation and scaling
rRaw=zeros(2,nVertex);
rRaw(1,:)=a*cos(phi);
rRaw(2,:)=b*sin(phi);

% rotate the position vectors
A=[cos(theta) -sin(theta) ; ...
   sin(theta)  cos(theta) ];
rCent=A*rRaw;

% translate the position vectors, break out into x and y for each vertex
xVertex=x+rCent(1,:);
yVertex=y-rCent(2,:);  % image y-axis convention

% add a vertex for the tail
xVertex=[xVertex x+2*a*cos(theta+pi)];
yVertex=[yVertex y-2*a*sin(theta+pi)];

% draw the line
h=line(xVertex,yVertex,varargin{:});

end
