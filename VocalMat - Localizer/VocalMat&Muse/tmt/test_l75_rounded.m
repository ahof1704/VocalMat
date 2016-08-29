% generate the full colormap
n=100;
x=linspace(0,1-1/n,n)';
l75_border_srgb=l75_border_of_theta(2*pi*(x-0.5)');
l75_border_lab=srgb2lab(l75_border_srgb);

% plot it in lab space
figure;
plot(l75_border_lab(:,2),l75_border_lab(:,3),'b.');
axis square;
xlim([-150,+150]);
ylim([-150,+150]);

% load in the rounded data
l75_rounded_srgb=load_tabular_data('l75_rounded_srgb.txt')';
l75_rounded_lab=srgb2lab(l75_rounded_srgb);

% plot it
hold on;
plot(l75_rounded_lab(:,2),l75_rounded_lab(:,3),'r.');
plot(l75_rounded_lab(1,2),l75_rounded_lab(1,3),'k.');

% make the rounded ring perceptually uniform
n=size(l75_rounded_lab,1);
[l75_rounded_lab_resamp,phase_resamp]=make_uniform(l75_rounded_lab,256);

% plot it
plot(l75_rounded_lab_resamp(:,2),l75_rounded_lab_resamp(:,3),'g.');

% make a colormap of it
cmap=max(0,min(1,lab2srgb(l75_rounded_lab_resamp)));

% show it
figure;
colormap(cmap);
colorbar;
colorbar_axes_h=findobj(gcf,'Tag','Colorbar');
colorbar_image_h=findobj(colorbar_axes_h,'Tag','TMW_COLORBAR');
set(colorbar_image_h,'YData',[-180 +180]);
set(colorbar_axes_h,'YLim',[-180 +180]);
set(colorbar_axes_h,'YTick',[-180 -90 0 +90 +180]);

% show the colormap a prettier way
theta=(-pi:pi/100:+pi)';
theta=repmat(theta,[1 2]);
r=repmat([0.8 1],[size(theta,1) 1]);
im_index=round(255*(((theta/pi)+1)/2))+1;
im_rgb=ind2rgb(im_index,cmap);
x=r.*cos(theta);
y=r.*sin(theta);
figure;
polar_grid_simple;
hold on;
surf(x,y,zeros(size(x)),...
     im_rgb,...
     'EdgeColor','none');
hold off;
text(0,0,'l75_rounded',...
     'interpreter','none',...
     'horizontalalignment','center',...
     'verticalalignment','middle');

% this doesn't seem to make much difference -- think I'm going to
% punt on this one



