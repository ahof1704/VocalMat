cmap=l75_circle(256);
figure;
colormap(cmap);
colorbar;
colorbar_axes_h=findobj(gcf,'Tag','Colorbar');
colorbar_image_h=findobj(colorbar_axes_h,'Tag','TMW_COLORBAR');
%set(colorbar_image_h,'CData',reshape(cmap,[256 1 3]));
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
text(0,0,'l75_circle',...
     'interpreter','none',...
     'horizontalalignment','center',...
     'verticalalignment','middle');
