% set optimization parameters
f_tol=1e-12;
x_tol=sqrt(f_tol);
dx_brak_max=0.01;
max_iters_hds=5000;
max_iters_line_min=1000;
max_parabolic_mag_brak=100;
max_iters_brak=100;
max_starts=10;
verbosity=1;

% get a bunch of points from the banana function
x_samples=-1.25:0.01:1.25;
y_samples=-1.25:0.01:1.25;
z=zeros(max(size(y_samples)),max(size(x_samples)));
for i=1:max(size(y_samples))
  for j=1:max(size(x_samples))
    z(i,j)=banana([x_samples(j);y_samples(i)]);
  end
end

% do the minimization from the traditional point
x0=[-1.2;1];
tunable=logical([1 1]');
x_lb=[-inf -inf]';
x_ub=[+inf +inf]';
[x_min,fx_min,n_line_mins,n_fun_evals,...
 x_trace,fx_trace,...
 warm]=...
  hds(@banana,...
       x0,...
       tunable,...
       x_lb,x_ub,...
       f_tol,...
       x_tol,...
       dx_brak_max,...
       max_parabolic_mag_brak,...
       max_iters_brak,...
       max_iters_line_min,...
       max_iters_hds,...
       max_starts,...
       'powell',...
       [],...
       verbosity);
x_min
fx_min
n_fun_evals

% do a contour plot
figure;
contour(x_samples,y_samples,z,[0.25:0.25:1.75 2:2:8 10:10:100]);
hold on;
plot(1,1,'+r');
hold off;
xlabel('x');
ylabel('y');
axis square;
drawnow;

% plot the sequence of values on the countour plot
hold on;
plot(x_trace(1,:),x_trace(2,:),'k.-');
hold off;

% plot the sequence of f vals
iter=(0:length(fx_trace)-1);
figure;
semilogy(iter,fx_trace);
ylabel('Objective value');
xlabel('Line search #');
