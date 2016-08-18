% test the on_edge funtions
L=90;
n_colors=64;
x=linspace(0,1,n_colors)';

blue_on_srgb=blue_on_edge(L,x);
red_on_srgb=red_on_edge(L,x);
blue_off_srgb=blue_off_edge(L,x);
red_off_srgb=red_off_edge(L,x);

blue_on_lab=srgb2lab(blue_on_srgb);
red_on_lab=srgb2lab(red_on_srgb);
blue_off_lab=srgb2lab(blue_off_srgb);
red_off_lab=srgb2lab(red_off_srgb);

% plot the curvy square formed by border of the sRGB gamut for this L
figure;
plot(blue_on_lab(:,2),blue_on_lab(:,3));
hold on;
plot(red_on_lab(:,2),red_on_lab(:,3));
plot(blue_off_lab(:,2),blue_off_lab(:,3));
plot(red_off_lab(:,2),red_off_lab(:,3));
hold off;
axis square;
xlim([-150,+150]);
ylim([-150,+150]);

% generate the full colormap
n_colors=256;
x=linspace(0,1,n_colors+1)';
x=x(1:end-1);
cmap=l75_border_of_x(x);

% show it
figure;
colormap(cmap);
colorbar;
colorbar_axes_h=findobj(gcf,'Tag','Colorbar');
colorbar_image_h=findobj(colorbar_axes_h,'Tag','TMW_COLORBAR');
set(colorbar_image_h,'YData',[-180 +180]);
set(colorbar_axes_h,'YLim',[-180 +180]);
set(colorbar_axes_h,'YTick',[-180 -90 0 +90 +180]);

% looks okay, but definitely not perceptually smooth

% make a colormap with inter-color spacings equal to circum/n_colors
n_colors=256;
cmap=l75_border(n_colors);

% show the colormap
figure;
colormap(cmap);
colorbar;
colorbar_axes_h=findobj(gcf,'Tag','Colorbar');
colorbar_image_h=findobj(colorbar_axes_h,'Tag','TMW_COLORBAR');
set(colorbar_image_h,'YData',[-180 +180]);
set(colorbar_axes_h,'YLim',[-180 +180]);
set(colorbar_axes_h,'YTick',[-180 -90 0 +90 +180]);
% looks somewhat better

% convert to lab
clr_lab=srgb2lab(cmap);

% plot these points on the edges -- should be evenly spaced on each seg
figure;
plot(blue_on_lab(:,2),blue_on_lab(:,3));
hold on;
plot(red_on_lab(:,2),red_on_lab(:,3));
plot(blue_off_lab(:,2),blue_off_lab(:,3));
plot(red_off_lab(:,2),red_off_lab(:,3));
plot(clr_lab(:,2),clr_lab(:,3),'r.');
hold off;
axis square;
xlim([-150,+150]);
ylim([-150,+150]);

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
text(0,0,'l75_border',...
     'interpreter','none',...
     'horizontalalignment','center',...
     'verticalalignment','middle');
