function clr=f(x)

%  x is a col vector, on [0,1]

% calculates a color based on x, which goes from blue to cyan to green to
% yellow to red

% the four cases to be handled
x_frac=mod(6*x,1);
x_floor=floor(6*x)+1;
special=(x==1);
x_frac(special)=1;
x_floor(special)=6;

% make weights
n_x=length(x);
w=zeros(n_x,7);
for i=1:n_x
  w(i,x_floor(i)  )=1-x_frac(i);
  w(i,x_floor(i)+1)=  x_frac(i);
end

% the colors
C=[0 0 0;...
   0 0 1;...
   0 1 1;...
   0 1 0;...
   1 1 0;...
   1 0 0;...
   1 1 1];

% do the matrix mult
clr=w*C;
