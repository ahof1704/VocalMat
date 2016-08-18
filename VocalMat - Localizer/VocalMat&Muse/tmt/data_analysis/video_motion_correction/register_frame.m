function frame_registered = register_frame(frame,A,b)

[n_y,n_x]=size(frame);
[x,y]=meshgrid(1:n_x,1:n_y);
x_prime=A(1,1)*x+A(1,2)*y+b(1);
y_prime=A(2,1)*x+A(2,2)*y+b(2);
frame_registered=interp2(x,y,frame,...
                         x_prime,y_prime,'*linear');
