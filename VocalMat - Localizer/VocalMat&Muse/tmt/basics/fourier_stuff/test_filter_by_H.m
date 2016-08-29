dt=0.001;
n=10000;

t=(0:dt:(n-1)*dt)';
x=(t>=4)&(t<=6);

f_sigma=2;  % Hz
H=@(f)(lpf_gaussian(f,f_sigma));

T_radius=4*1/(2*pi*f_sigma)
y=filter_by_H(t,x,H,T_radius,T_radius);

figure;
subplot(3,1,1);
plot(t,x,'b');
ylim([-0.1 1.1]);
ylabel('x');
subplot(3,1,2);
plot(t,x,'b',t,y,'r');
ylim([-0.1 1.1]);
ylabel('x+y');
subplot(3,1,3);
plot(t,y,'r');
ylim([-0.1 1.1]);
ylabel('y');
xlabel('t (s)');
tl(t(1),t(end));
