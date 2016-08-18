function [area,CE_x,CE_y] = fn_plot_chunks2(saving_dir,video_fname_prefix,C,i,mm,coords_mouse2,coords_mouse,Xrange,Yrange,Xrange_m,Yrange_m,corners_x,corners_y,coords_chunks,outliers_k,p,subplot_options,num_mice)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
% var1 = subplot_options.on_off;
% rows = subplot_options.num_rows;
% cols = subplot_options.num_cols;
vis = subplot_options.vis;
% max_size = subplot_options.max_size;

color_values = [0 0 0;0 0.5 0;0.5 0 0.5;0 1 1];%mouse 1 = black, mouse 2 = green, mouse 3 = purple, mouse 4 = cyan

figure('color','w','Position',get(0,'screenSize'),'visible',vis)
subplot(2,2,1)
plot(corners_x,corners_y,'k')
axis equal
ylim([min(corners_y)*0.8 max(corners_y)*1.2])
xlim([min(corners_x)*0.8 max(corners_x)*1.2])
hold on

for j = 1:size(coords_mouse,3)
    plot(coords_mouse(1,:,j),coords_mouse(2,:,j),'o-',...
        'markerfacecolor',color_values(j,:),...
        'MarkerEdgeColor',color_values(j,:),...
        'MarkerSize',4)
end
scatter(coords_chunks(1,:),coords_chunks(2,:),4,'filled','r')
plot(mm(1),mm(2),'bo', 'MarkerFace','b')
scatter(coords_mouse2(1,:,1),coords_mouse2(2,:,1),'g')
[h,area,CE_x,CE_y] = error_ellipse(C,mm,0.95);

if num_mice == 1
    title(sprintf('%d; %.2e',i, p(1,1)))
elseif num_mice == 2
    title(sprintf('%d; %.2e, %.2e',i, p(1,1), p(2,1)))
elseif num_mice == 3
    title(sprintf('%d; %.2e, %.2e, %.2e',i, p(1,1), p(2,1), p(3,1)))
elseif num_mice == 4
    title(sprintf('%d; %.2e, %.2e, %.2e, %.2e',i, p(1,1), p(2,1), p(3,1), p(4,1)))
elseif num_mice == 5
    title(sprintf('%d; %.2e, %.2e, %.2e, %.2e, %.2e',i, p(1,1), p(2,1), p(3,1), p(4,1) , p(5,1)))
end
if isempty(outliers_k) == 0
    plot(coords_chunks(1,outliers_k),coords_chunks(2,outliers_k),'ko')
end

%plotting
subplot(2,2,2)
F = mvnpdf([Xrange_m(:) Yrange_m(:)],mm,C);
F = reshape(F,length(Xrange_m),length(Xrange_m));
surf(Xrange,Yrange,F);
caxis([min(F(:))-.5*range(F(:)),max(F(:))]);
% axis([-3 3 -3 3 0 .4])
xlabel('x'); ylabel('y'); zlabel('Probability Density');

% saves pdf
cd (saving_dir)
page_number = fn_numPad(i,5);
saveas(gcf,sprintf('%s_chunk_ssl_plots_segment%s',video_fname_prefix,page_number),'jpg')
% print(gcf,'-dpdf','-r600','-painters',sprintf('%s_chunk_ssl_plots_segment%s',video_fname_prefix,page_number));
close all

end

