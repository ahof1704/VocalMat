function h=fnDrawEllipseGT(ellipse,varargin)

% Draws an ellipse (without tail) in the current axes.
% ellipse an ellipse, a 1x1 structure with fields:
%   m_fX, m_fY, m_fA, m_fB, m_fTheta
% OR, ellipse can be a 5x1 vector holding the ellipse parameters, in the 
% order x, y, a, b, theta

% unpack ellipse
if isstruct(ellipse)
  strctEllipse=ellipse;
  x=strctEllipse.m_fX;
  y=strctEllipse.m_fY;
  a=strctEllipse.m_fA;
  b=strctEllipse.m_fB;
  theta=strctEllipse.m_fTheta;
else
  afEllipse=ellipse;
  x=afEllipse(1);
  y=afEllipse(2);
  a=afEllipse(3);
  b=afEllipse(4);
  theta=afEllipse(5);
end
  
% draw the ellipse in the current axes
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

% draw the line
h=line(xVertex,yVertex,varargin{:});

end
