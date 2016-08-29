function Y = f(L)

L_prime=(L+16)/116; 
low=(L_prime<=0.206893);
high=~low;
Y=zeros(size(L_prime));
Y(low)=(L_prime(low)-16/116)/7.787;
Y(high)=L_prime(high).^3;
