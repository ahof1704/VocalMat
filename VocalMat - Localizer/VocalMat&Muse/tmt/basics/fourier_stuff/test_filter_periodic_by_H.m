dt=0.01;
n=1000;

t=(0:dt:(n-1)*dt)';
x=(t>=0.1)&(t<=2.1);

% f_sigma=2;  % Hz
% H=@(f)(lpf_gaussian(f,f_sigma));

f_corner=2;
H=@(f)(lpf_rc(f,f_corner));

plot_verbosity=1;
y=filter_periodic_by_H(t,x,H,plot_verbosity);

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
