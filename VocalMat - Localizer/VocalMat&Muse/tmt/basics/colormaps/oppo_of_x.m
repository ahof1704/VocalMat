function clr=f(x)

%  x is a col vector

% normalize x
x=mod(x,1);

% the four cases to be handled
ry= x<0.25 ;
yg= x>=0.25 & x<0.5 ;
gb= x>=0.5 & x<0.75 ;
br= x>=0.75 ;

% interpolate between the 'landmark' colors
clr=zeros(length(x),3);
if any(ry~=0)
  y=4*x(ry); r=1-y;
  clr_ry=y*[1 1 0]+r*[1 0 0];  % linear
  clr(ry,:)=clr_ry;
end
if any(yg~=0)
  g=4*x(yg)-1; y=1-g;
  clr_yg=g*[0 1 0]+y*[1 1 0];  % linear
  clr(yg,:)=clr_yg;
end
if any(gb~=0)
  b=4*x(gb)-2; g=1-b;
  % do this one nonlinear so the middle doesn't look dark
  clr_gb=sin(pi/2*b)*[0 0 1]+sin(pi/2*g)*[0 1 0];
  clr(gb,:)=clr_gb;
end
if any(br~=0)
  r=4*x(br)-3; b=1-r;
  % do this one nonlinear so the middle doesn't look dark
  clr_br=sin(pi/2*r)*[1 0 0]+sin(pi/2*b)*[0 0 1];
  clr(br,:)=clr_br;
end
